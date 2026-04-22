#!/usr/bin/env node
// Reads proof.json (snarkjs, uncompressed BLS12-381 points) and writes
// compressed_proof.json with 48-byte G1 and 96-byte G2 hex strings.
//
// Usage:  node circuit/compress_proof.js [proof_path] [out_path]
//         node circuit/compress_proof.js   # defaults shown below

const { readFileSync, writeFileSync } = require("fs");
const path = require("path");

const proofPath = process.argv[2] ?? path.join(__dirname, "..", "proof.json");
const outPath   = process.argv[3] ?? path.join(__dirname, "..", "compressed_proof.json");

async function main() {
  const { bls12_381 } = await import("@noble/curves/bls12-381.js");
  const G1 = bls12_381.G1.Point;
  const G2 = bls12_381.G2.Point;

  const proof = JSON.parse(readFileSync(proofPath, "utf8"));

  function compressG1([x, y]) {
    const pt = G1.fromAffine({ x: BigInt(x), y: BigInt(y) });
    return Buffer.from(pt.toBytes(true)).toString("hex");
  }

  function compressG2([[x0, x1], [y0, y1]]) {
    const pt = G2.fromAffine({
      x: { c0: BigInt(x0), c1: BigInt(x1) },
      y: { c0: BigInt(y0), c1: BigInt(y1) },
    });
    return Buffer.from(pt.toBytes(true)).toString("hex");
  }

  const compressed = {
    pi_a: compressG1(proof.pi_a),
    pi_b: compressG2(proof.pi_b),
    pi_c: compressG1(proof.pi_c),
  };

  writeFileSync(outPath, JSON.stringify(compressed, null, 2));
  console.log("pi_a   :", compressed.pi_a);
  console.log("pi_b   :", compressed.pi_b);
  console.log("pi_c   :", compressed.pi_c);
  console.log("written:", outPath);
}

main().catch(err => { console.error(err); process.exit(1); });
