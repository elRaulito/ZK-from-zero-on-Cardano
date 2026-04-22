#!/usr/bin/env node
// Reads verification_key.json (snarkjs, uncompressed BLS12-381 points) and
// writes compressed_vk.json with 48-byte G1 and 96-byte G2 hex strings
// ready for embedding in the Aiken on-chain datum.
//
// Usage:  node circuit/compress_vk.js [vk_path] [out_path]
//         node circuit/compress_vk.js   # defaults shown below

const { readFileSync, writeFileSync } = require("fs");
const path = require("path");

const vkPath  = process.argv[2] ?? path.join(__dirname, "..", "verification_key.json");
const outPath = process.argv[3] ?? path.join(__dirname, "..", "compressed_vk.json");

// @noble/curves uses ESM — load it via dynamic import inside an async wrapper.
async function main() {
  const { bls12_381 } = await import("@noble/curves/bls12-381.js");
  const G1 = bls12_381.G1.Point;
  const G2 = bls12_381.G2.Point;

  const vk = JSON.parse(readFileSync(vkPath, "utf8"));

  // snarkjs stores affine coordinates as decimal strings: [x, y, "1"]
  function compressG1([x, y]) {
    const pt = G1.fromAffine({ x: BigInt(x), y: BigInt(y) });
    return Buffer.from(pt.toBytes(true)).toString("hex");
  }

  // G2 affine: [[x0, x1], [y0, y1], ["1", "0"]]
  // noble/curves Fp2 convention: c0 + c1*u  (matches snarkjs ordering)
  function compressG2([[x0, x1], [y0, y1]]) {
    const pt = G2.fromAffine({
      x: { c0: BigInt(x0), c1: BigInt(x1) },
      y: { c0: BigInt(y0), c1: BigInt(y1) },
    });
    return Buffer.from(pt.toBytes(true)).toString("hex");
  }

  const compressed = {
    vk_alpha1: compressG1(vk.vk_alpha_1),
    vk_beta2:  compressG2(vk.vk_beta_2),
    vk_gamma2: compressG2(vk.vk_gamma_2),
    vk_delta2: compressG2(vk.vk_delta_2),
    vk_ic:     vk.IC.map(compressG1),
  };

  writeFileSync(outPath, JSON.stringify(compressed, null, 2));
  console.log("alpha1 :", compressed.vk_alpha1);
  console.log("beta2  :", compressed.vk_beta2);
  console.log("gamma2 :", compressed.vk_gamma2);
  console.log("delta2 :", compressed.vk_delta2);
  compressed.vk_ic.forEach((ic, i) => console.log(`ic[${i}]  :`, ic));
  console.log("written:", outPath);
}

main().catch(err => { console.error(err); process.exit(1); });
