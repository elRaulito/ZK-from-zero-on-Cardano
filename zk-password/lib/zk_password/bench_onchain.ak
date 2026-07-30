//// On-chain cost benchmarks referenced in Chapter 8 of the eBook.
////
//// Purpose: establish, by measurement rather than assertion, what a
//// ZK-friendly hash (Poseidon) would cost if computed *on-chain* in Aiken,
//// versus Cardano's builtin hash functions.
////
//// Method: every benchmark is a tail-recursive loop of N iterations. Each
//// loop has a matching `nop` baseline with the identical shape and arity,
//// so subtracting the baseline and dividing by N yields the marginal cost
//// of one operation. Run with:
////
////     aiken check -m bench
////
//// Aiken v1.1.19, stdlib v2.1.0. Compare against the live mainnet budget of
//// 10,000,000,000 CPU steps and 16,500,000 memory units per transaction.

use aiken/builtin
use aiken/crypto/bls12_381/scalar.{Scalar}

/// The BLS12-381 scalar field prime.
const p: Int =
  52435875175126190479447740508185965837690552500527637822603658699938581184513

const leaf: ByteArray =
  #"0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"

// ─────────────────────────────────────────────────────────────────────────────
// Baselines: loop overhead only.
// ─────────────────────────────────────────────────────────────────────────────

fn nop2(acc: Int, n: Int) -> Int {
  if n <= 0 {
    acc
  } else {
    nop2(acc, n - 1)
  }
}

fn nop3(acc: Int, k: Int, n: Int) -> Int {
  if n <= 0 {
    acc
  } else {
    nop3(acc, k, n - 1)
  }
}

fn nop_scalar(acc: Scalar, k: Scalar, n: Int) -> Scalar {
  if n <= 0 {
    acc
  } else {
    nop_scalar(acc, k, n - 1)
  }
}

fn nop_bytes(acc: ByteArray, n: Int) -> ByteArray {
  if n <= 0 {
    acc
  } else {
    nop_bytes(acc, n - 1)
  }
}

test bench_nop_int_1000() {
  nop2(7, 1000) != 0
}

test bench_nop_int3_1000() {
  nop3(p - 7, p - 3, 1000) != 0
}

test bench_nop_scalar_1000() {
  expect Some(k) = scalar.new(p - 1)
  expect Some(a) = scalar.new(p - 7)
  nop_scalar(a, k, 1000) != scalar.zero
}

test bench_nop_bytes_1000() {
  nop_bytes(leaf, 1000) == leaf
}

// ─────────────────────────────────────────────────────────────────────────────
// Interpreter overhead: bare arithmetic on small operands.
//
// Establishes that the dominant cost is the CEK machine's per-operation
// overhead, not the width of the numbers.
// ─────────────────────────────────────────────────────────────────────────────

fn add_only(acc: Int, n: Int) -> Int {
  if n <= 0 {
    acc
  } else {
    add_only(acc + 3, n - 1)
  }
}

fn mod_only(acc: Int, n: Int) -> Int {
  if n <= 0 {
    acc
  } else {
    mod_only(acc % p, n - 1)
  }
}

test bench_add_only_1000() {
  add_only(7, 1000) != 0
}

test bench_mod_only_1000() {
  mod_only(p - 7, 1000) != 0
}

// ─────────────────────────────────────────────────────────────────────────────
// Field arithmetic, two ways: via the stdlib `Scalar` type, and via raw Int
// modular arithmetic. Both are measured to show the opaque-type wrapper is
// not the source of the cost.
// ─────────────────────────────────────────────────────────────────────────────

fn scalar_mul_loop(acc: Scalar, k: Scalar, n: Int) -> Scalar {
  if n <= 0 {
    acc
  } else {
    scalar_mul_loop(scalar.mul(acc, k), k, n - 1)
  }
}

fn scalar_add_loop(acc: Scalar, k: Scalar, n: Int) -> Scalar {
  if n <= 0 {
    acc
  } else {
    scalar_add_loop(scalar.add(acc, k), k, n - 1)
  }
}

fn raw_modmul_loop(acc: Int, k: Int, n: Int) -> Int {
  if n <= 0 {
    acc
  } else {
    raw_modmul_loop(acc * k % p, k, n - 1)
  }
}

fn raw_modadd_loop(acc: Int, k: Int, n: Int) -> Int {
  if n <= 0 {
    acc
  } else {
    raw_modadd_loop(( acc + k ) % p, k, n - 1)
  }
}

test bench_scalar_mul_1000() {
  expect Some(k) = scalar.new(p - 1)
  expect Some(a) = scalar.new(p - 7)
  scalar_mul_loop(a, k, 1000) != scalar.zero
}

test bench_scalar_add_1000() {
  expect Some(k) = scalar.new(p - 1)
  expect Some(a) = scalar.new(p - 7)
  scalar_add_loop(a, k, 1000) != scalar.zero
}

test bench_raw_modmul_1000() {
  raw_modmul_loop(p - 7, p - 3, 1000) != 0
}

test bench_raw_modadd_1000() {
  raw_modadd_loop(p - 7, p - 3, 1000) != 0
}

// ─────────────────────────────────────────────────────────────────────────────
// Builtin hash functions, for comparison. One iteration = one 2-to-1
// compression of two 32-byte values, i.e. one Merkle tree level.
// ─────────────────────────────────────────────────────────────────────────────

fn blake2b_loop(acc: ByteArray, n: Int) -> ByteArray {
  if n <= 0 {
    acc
  } else {
    blake2b_loop(builtin.blake2b_256(builtin.append_bytearray(acc, acc)), n - 1)
  }
}

fn sha2_loop(acc: ByteArray, n: Int) -> ByteArray {
  if n <= 0 {
    acc
  } else {
    sha2_loop(builtin.sha2_256(builtin.append_bytearray(acc, acc)), n - 1)
  }
}

test bench_blake2b_1000() {
  blake2b_loop(leaf, 1000) != #""
}

test bench_sha2_1000() {
  sha2_loop(leaf, 1000) != #""
}

/// A full depth-20 Merkle path recomputation with a builtin hash --- the
/// operation Chapter 8 needs on the deposit side of a mixer. Reported as an
/// absolute figure (no baseline subtraction) so it can be compared directly
/// against the per-transaction budget.
test bench_blake2b_depth20() {
  blake2b_loop(leaf, 20) != #""
}
