# ZK from Zero on Cardano: eBook

> An open-source educational eBook on Zero-Knowledge Proofs for Cardano developers.

[![Fund 14 Catalyst](https://img.shields.io/badge/Catalyst-Fund%2014-%231D44A4?logo=cardano&logoColor=white)](https://projectcatalyst.io/funds/14/cardano-open-ecosystem/zk-from-zero-on-cardano-ebook-by-elraulito)
[![License: AFL-3.0](https://img.shields.io/badge/License-AFL--3.0-orange.svg)](LICENSE)

---

## Project Scope

**Project ID:** #1400129, Cardano Open: Ecosystem, Fund 14
**Status:** Complete; all 9 chapters delivered ([close-out report](docs/close-out-report.md))
**Budget:** 60,000 ADA
**Duration:** 8 months

Material for writing ZK DApps on Cardano is hard to find and developers are
struggling to build zero-knowledge applications on Cardano. This eBook bridges
that gap with a free, open-source, hands-on guide, from the mathematical
foundations of ZK proofs all the way to working smart contracts on Cardano.

---

## Contents

107 pages, nine chapters plus a sitography of the whole ZK-on-Cardano landscape:

| # | Chapter | Topic |
|---|---------|-------|
| 1 | Introduction to Zero-Knowledge Proofs | Principles, interactive vs non-interactive |
| 2 | The History of ZK | GMR 1985 -> practical SNARKs |
| 3 | ZK in the Wild | Zcash, Monero, rollups |
| 4 | Performance, Privacy and Trade-offs | Compression, proof size, proving time |
| 5 | Circom, snarkjs, and Aiken | The toolchain, R1CS, trusted setup |
| 6 | Password-Locked UTxO with Groth16 | A working ZK contract, start to finish |
| 7 | Implementing Off-Chain Logic for ZK in Cardano | Provers, Plutus Data encoding, MeshJS transactions |
| 8 | Tornado Cash on Cardano: A Case Study | Academic analysis of why it isn't possible today |
| 9 | Final Thoughts and Future Directions | Missing primitives, ecosystem, ethics |
| 10 | Sitography: The ZK on Cardano Landscape | Every project, tool, CIP and paper, with clickable links |

---

## Key Findings

Measured on mainnet parameters (epoch 646) and reproducible from this repository:

| Finding | Value |
|---|---|
| Compiled Groth16 verifier size | **570 bytes** of Plutus Core |
| Cost to verify a proof on-chain | **2,005,373,690 CPU steps**, approx. **0.147 ADA** |
| ...and that cost is | **constant in circuit size** |
| Max proof verifications per transaction | **4** (CPU-bound) |
| Cost floor per elementary Plutus operation | approx. **2 x 10^5 CPU steps**: interpreter overhead, not operand width |
| On-chain Poseidon vs `blake2b_256` | approx. **1,500x more expensive** |
| Depth-20 on-chain Poseidon Merkle insertion | **120% of CPU** and **173% of memory** budget: does not fit |

The headline conclusion: **Cardano verifies zero-knowledge proofs cheaply and
elegantly, but cannot yet maintain ZK-friendly cryptographic state on-chain.**
Chapter 8 quantifies exactly why, and Chapter 9 identifies a Poseidon builtin as
the single highest-leverage fix.

Reproduce the numbers:

```bash
cd zk-password
aiken check              # validator + proof verification tests
aiken check -m bench     # on-chain cost benchmarks (Chapter 8)
```

---

## How to Build

The eBook is written in LaTeX and compiled with LuaLaTeX. Two themes are
available: light and dark.

**Requirements:** TeX Live 2024 or later with LuaLaTeX.

```bash
# Light theme
cd eBook
lualatex light.tex

# Dark theme
lualatex dark.tex
```

Output PDFs are written to `eBook/light.pdf` and `eBook/dark.pdf`.

---

## Authorship & Tools

| Role | Person / Tool |
|------|--------------|
| **Written by** | Raul Rosa: [elRaulito](https://www.raul.it/) |
| **AI reviewer** | [Claude Code](https://claude.ai/claude-code) by Anthropic |
| **Typesetting** | LaTeX (LuaLaTeX + TikZ) |
| **License** | AFL-3.0 (free and open source) |

Community contributions are welcome via GitHub pull requests.

---

## Delivery Milestones

| Milestone | Target | Content | Status |
|-----------|--------|---------|--------|
| ZK Intro | Month 2 | Chapters 1-2: foundations and history | Done |
| Web3 & Use Cases | Month 4 | Chapters 3-4: real-world applications | Done |
| ZK on Cardano | Month 6 | Chapters 5-7: on-chain implementation | Done |
| Final Chapter | Month 8 | Chapters 8-9: advanced topics and ethics | Done |
| Close-out | Month 8 | [Report](https://github.com/elRaulito/ZK-from-zero-on-Cardano/blob/main/close-out-report.pdf) + [video](https://youtu.be/FS40K_45CWQ?is=ghFRD01mewreEUtB) | Done |

---

## Reference Implementation

`zk-password/` is a complete, runnable ZK contract, the subject of Chapters 6-7.

```
zk-password/
+-- circuit/
|   +-- circuit.circom          # Poseidon password-lock constraint circuit
|   +-- poseidon_hash.circom    # BLS12-381 hash helper (avoids the BN254 trap)
|   +-- gen_input.js            # password -> input.json
|   +-- compress_vk.js          # verification key -> Cardano's 48/96-byte format
|   +-- compress_proof.js       # proof points -> compressed form
+-- lib/zk_password/
|   +-- groth16.ak              # Groth16 verifier (BLS12-381 builtins)
|   +-- password_tests.ak       # proof verification tests
|   +-- bench_onchain.ak        # on-chain cost benchmarks (Chapter 8)
+-- validators/
    +-- password.ak             # the on-chain validator
```

---

## Links

- **Catalyst proposal:** https://projectcatalyst.io/funds/14/cardano-open-ecosystem/zk-from-zero-on-cardano-ebook-by-elraulito
- **Close-out report:** [report PDF](https://github.com/elRaulito/ZK-from-zero-on-Cardano/blob/main/close-out-report.pdf)
- **Author:** https://www.raul.it/
- **Twitter/X:** [@elRaulito](https://twitter.com/elRaulito)
- **Closeout Video** https://youtu.be/FS40K_45CWQ?is=ghFRD01mewreEUtB


### Prior work credited in the book

- [Janus Wallet](https://github.com/leobel/janus-wallet), the most complete open-source ZK application on Cardano
- [aiken-zk (Eryx)](https://github.com/eryxcoop/cardano-zk-aiken), `offchain` blocks, circuit and redeemer generation
- [Modulo-P ak-381](https://github.com/Modulo-P/ak-381) and [Cardano-Semaphore](https://github.com/Modulo-P/Cardano-Semaphore)
- [cardano-foundation/bls](https://github.com/cardano-foundation/bls), BLS12-381 examples in Aiken
