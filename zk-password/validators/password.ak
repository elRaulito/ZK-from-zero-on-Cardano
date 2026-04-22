use aiken/crypto/bls12_381/scalar
use cardano/transaction.{OutputReference, Transaction}
use zk_password/groth16.{Proof, VerificationKey, groth16_verify}

// What gets locked on-chain when you create the UTxO.
// credential_hash = Poseidon(password) as a field element integer (< scalar.field_prime).
// vk              = the compressed Groth16 verification key for circuit.circom.
pub type Datum {
  credential_hash: Int,
  vk: VerificationKey,
}

// What the spender must provide to unlock the funds.
// proof = the Groth16 proof that they know a pwd such that Poseidon(pwd) == credential_hash.
pub type Redeemer {
  proof: Proof,
}

// Unlock funds if and only if the spender can provide a valid Groth16 proof
// that they know the password whose Poseidon hash matches the stored credential.
validator password_lock {
  spend(
    datum: Option<Datum>,
    redeemer: Redeemer,
    _self: OutputReference,
    _ctx: Transaction,
  ) {
    expect Some(d) = datum
    // Convert the stored integer back to a Scalar at runtime.
    // scalar.new fails if the value is out of range, which prevents malformed datums.
    expect Some(hash_scalar) = scalar.new(d.credential_hash)
    groth16_verify(d.vk, redeemer.proof, [hash_scalar])
  }

  else(_) {
    False
  }
}
