# ZK from Zero on Cardano — eBook

> An open-source educational eBook on Zero-Knowledge Proofs for Cardano developers.

[![Fund 14 Catalyst](https://img.shields.io/badge/Catalyst-Fund%2014-%231D44A4?logo=cardano&logoColor=white)](https://projectcatalyst.io/funds/14/cardano-open-ecosystem/zk-from-zero-on-cardano-ebook-by-elraulito)
[![License: AFL-3.0](https://img.shields.io/badge/License-AFL--3.0-orange.svg)](LICENSE)

---

## Project Scope

**Project ID:** #1400129 — Cardano Open: Ecosystem, Fund 14
**Status:** In Progress
**Budget:** 60,000 ADA
**Duration:** 8 months

Material for writing ZK DApps on Cardano is hard to find and developers are
struggling to build zero-knowledge applications on Cardano. This eBook bridges
that gap with a free, open-source, hands-on guide — from the mathematical
foundations of ZK proofs all the way to working smart contracts on Cardano.

---

## Contents

The eBook is structured in nine chapters:

| # | Chapter |
|---|---------|
| 1 | Zero-Knowledge Proof introduction and principles |
| 2 | Historical development of ZK technology |
| 3 | ZK applications in Web3 (Zcash, Monero, and other protocols) |
| 4 | Data compression and privacy applications |
| 5 | ZK circuits and verification mechanisms |
| 6 | Smart contract implementation on Cardano |
| 7 | Off-chain logic architecture |
| 8 | Case study: mixer-style protocols (academic purposes only) |
| 9 | Future directions and ethical considerations |

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
| **Written by** | Raul Rosa — [elRaulito](https://www.raul.it/) |
| **AI reviewer** | [Claude Code](https://claude.ai/claude-code) by Anthropic |
| **Typesetting** | LaTeX (LuaLaTeX + TikZ) |
| **License** | AFL-3.0 (free and open source) |

Community contributions are welcome via GitHub pull requests.

---

## Delivery Milestones

| Milestone | Target | Content |
|-----------|--------|---------|
| ZK Intro | Month 2 | Chapters 1–2: foundations and history |
| Web3 & Use Cases | Month 4 | Chapters 3–4: real-world applications |
| ZK on Cardano | Month 6 | Chapters 5–7: on-chain implementation |
| Final Chapter | Month 8 | Chapters 8–9: advanced topics and ethics |

---

## Links

- **Catalyst proposal:** https://projectcatalyst.io/funds/14/cardano-open-ecosystem/zk-from-zero-on-cardano-ebook-by-elraulito
- **Author:** https://www.raul.it/
- **Twitter/X:** [@elRaulito](https://twitter.com/elRaulito)
