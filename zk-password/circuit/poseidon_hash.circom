pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/poseidon.circom";

// Helper: computes hash = Poseidon(pwd) with no constraints.
// Used only by gen_input.js to produce the correct field-element hash.
template HashOnly() {
    signal input  pwd;
    signal output hash;
    component h = Poseidon(1);
    h.inputs[0] <== pwd;
    hash <== h.out;
}

component main = HashOnly();
