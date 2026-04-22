use aiken/crypto/bls12_381/scalar.{Scalar}
use cardano/transaction.{OutputReference, Transaction}
use zk_password/groth16.{Proof, VerificationKey, groth16_verify}

// What gets locked on-chain when you create the UTxO.
// credential_hash = Poseidon(password), encoded as a BLS12-381 scalar (ByteArray).
// vk              = the compressed Groth16 verification key for circuit.circom.
pub type Datum {
  credential_hash: Scalar,
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
    // The only public input is the credential hash stored in the datum.
    // The prover's private input (the password) never appears on-chain.
    groth16_verify(d.vk, redeemer.proof, [d.credential_hash])
  }

  else(_) {
    False
  }
}
