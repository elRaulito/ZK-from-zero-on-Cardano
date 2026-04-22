pragma circom 2.1.6;

// circomlib must be installed: npm install -D circomlib
include "../node_modules/circomlib/circuits/poseidon.circom";

// Prove knowledge of a password whose Poseidon hash matches a public commitment.
//
// Public inputs  (visible on-chain in the datum):
//   hash  -- Poseidon(pwd)
//
// Private inputs (never leave the prover's device):
//   pwd   -- the password
//
template PasswordLock() {
    signal input hash;   // public
    signal input pwd;    // private

    component h = Poseidon(1);
    h.inputs[0] <== pwd;

    // Constraint: the hash of the private pwd must equal the public hash.
    // If this is violated, no valid proof can be generated.
    hash === h.out;
}

component main {public [hash]} = PasswordLock();
