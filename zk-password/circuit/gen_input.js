#!/usr/bin/env node
// Computes Poseidon(pwd) over the BLS12-381 scalar field using the
// circuit's own WASM, then writes input.json.
//
// Usage:  node circuit/gen_input.js <password>
//         node circuit/gen_input.js          # defaults to "12345"

const { readFileSync, writeFileSync } = require("fs");
const path = require("path");

const password = process.argv[2] ?? "12345";

// If the argument is a plain integer string use it directly as a field element;
// otherwise encode the UTF-8 bytes as a big-endian integer.
function toFieldElement(s) {
  if (/^\d+$/.test(s)) return BigInt(s);
  return BigInt("0x" + Buffer.from(s, "utf8").toString("hex"));
}

const pwd = toFieldElement(password);

async function main() {
  // poseidon_hash.circom compiles pwd -> hash with no === constraint,
  // so the witness generator runs cleanly and witness[1] = Poseidon(pwd).
  const buildWC = require("./poseidon_hash_js/witness_calculator.js");
  const wasm    = readFileSync(path.join(__dirname, "poseidon_hash_js", "poseidon_hash.wasm"));
  const wc      = await buildWC(wasm);

  const witness = await wc.calculateWitness({ pwd }, true);
  const hash    = witness[1]; // output signal is always at index 1

  const input   = { hash: hash.toString(), pwd: pwd.toString() };
  const outPath = path.join(__dirname, "input.json");
  writeFileSync(outPath, JSON.stringify(input, null, 2));

  console.log("password :", password);
  console.log("hash     :", hash.toString());
  console.log("written  :", outPath);
}

main().catch(err => { console.error(err); process.exit(1); });
