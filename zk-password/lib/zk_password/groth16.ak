// Groth16 verifier over BLS12-381.
// Mirrors the approach used in Janus Wallet (github.com/leobel/janus-wallet).

use aiken/builtin.{
  bls12_381_final_verify, bls12_381_miller_loop,
  bls12_381_mul_miller_loop_result,
}
use aiken/crypto/bls12_381/g1
use aiken/crypto/bls12_381/g2
use aiken/crypto/bls12_381/scalar.{Scalar}

// Compressed verification key (all points in BLS12-381 compressed form).
// G1 points are 48 bytes; G2 points are 96 bytes.
pub type VerificationKey {
  // G1 — 48 bytes
  alpha: ByteArray,
  // G2 — 96 bytes
  beta: ByteArray,
  // G2 — 96 bytes
  gamma: ByteArray,
  // G2 — 96 bytes
  delta: ByteArray,
  // List of G1 points: ic[0] is the constant term, ic[i+1] corresponds to
  // public_input[i]. Length must be num_public_inputs + 1.
  ic: List<ByteArray>,
}

// Groth16 proof (all points in BLS12-381 compressed form).
pub type Proof {
  // G1 — 48 bytes
  pi_a: ByteArray,
  // G2 — 96 bytes
  pi_b: ByteArray,
  // G1 — 48 bytes
  pi_c: ByteArray,
}

// Recursively compute vk_x = IC[0] + Σ (public_input[i] · IC[i+1])
fn derive(
  ic_rest: List<ByteArray>,
  public: List<Scalar>,
  acc,
) {
  when ic_rest is {
    [] -> acc
    [ic, ..rest_ic] ->
      when public is {
        [] -> fail
        [sc, ..rest_public] ->
          derive(
            rest_ic,
            rest_public,
            g1.add(acc, g1.scale(g1.decompress(ic), sc)),
          )
      }
  }
}

// Verify a Groth16 proof.
//
// Checks the pairing equation:
//   e(π_A, π_B) == e(α, β) · e(vk_x, γ) · e(π_C, δ)
//
// public_inputs must be passed as BLS12-381 scalars (ByteArray in little-endian
// scalar form). The length must match the number of public signals in the circuit.
pub fn groth16_verify(
  vk: VerificationKey,
  proof: Proof,
  public_inputs: List<Scalar>,
) -> Bool {
  let a = g1.decompress(proof.pi_a)
  let b = g2.decompress(proof.pi_b)
  let c = g1.decompress(proof.pi_c)

  // vk_x = IC[0] + Σ (public_input[i] · IC[i+1])
  let vk_x =
    when vk.ic is {
      [] -> fail @"vk.ic must not be empty"
      [ic0, ..rest] -> derive(rest, public_inputs, g1.decompress(ic0))
    }

  let e_ab = bls12_381_miller_loop(a, b)
  let e_alpha_beta =
    bls12_381_miller_loop(g1.decompress(vk.alpha), g2.decompress(vk.beta))
  let e_x_gamma = bls12_381_miller_loop(vk_x, g2.decompress(vk.gamma))
  let e_c_delta = bls12_381_miller_loop(c, g2.decompress(vk.delta))

  // Accumulate the right-hand side miller loops
  let rhs =
    bls12_381_mul_miller_loop_result(
      bls12_381_mul_miller_loop_result(e_alpha_beta, e_x_gamma),
      e_c_delta,
    )

  // Final pairing check: e(A,B) == e(α,β)·e(vk_x,γ)·e(C,δ)
  bls12_381_final_verify(e_ab, rhs)
}
