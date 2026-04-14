# ARC-7 Panel

**ARC-7** is an elite architectural decision panel featuring 7 specialized AI personas. It implements multi-model cognitive diversity, structured debate with governance, blind voting for critical decisions, and formal conflict resolution — grounded in ensemble learning principles and adversarial review dynamics.

## Overview

The panel operates in three modes:
1. **Conversation Review (`/ARC-7`)**: Reviews the current context of a conversation (proposals, designs, decisions discussed so far).
2. **Document Review (`/ARC-7 <document>`)**: Reviews a specific document or proposal via file path or inline content.
3. **Codebase Review (`/ARC-7 <github-url>`)**: Clones and reviews a full repository to evaluate systemic patterns, architectural choices, and structural tech debt.

## The Panel Members

| Role | Focus | Recommended Model |
|---|---|---|
| **Context Master** | Orchestration, synthesis, model assignment | `gemini-3-pro-preview` |
| **The Architect** | System design, API contracts, tech selection | `claude-opus-4.6` |
| **Security Sentinel**| OWASP A01-A10, STRIDE, threat modeling | `gpt-4o` |
| **Product Visionary**| ROI, metrics, user value, MVP scope | `gpt-5.2` |
| **Creative Strategist**| Alternatives, simplification, UX innovation | `gpt-5.3-codex` |
| **The Optimizer** | Performance, parallelization, cost | `gpt-5.3-codex` |
| **The Naysayer** | Risk, failure modes, edge cases, groupthink | `claude-opus-4.6` |

## Tool-Agnostic Architecture

This repository is strictly designed to be **tool and provider agnostic**.

### Directory Structure

The core logic (the "source of truth") is kept in generic, tool-agnostic directories:
- `skills/ARC-7/` — The master skill definition and orchestration logic (`SKILL.md`).
- `agents/ARC-7/` — The persona definitions and system prompts (`arc7-*.md`).
- `commands/` — The user interface command definitions.

### Tool-Specific Symlinks

To support a wide variety of agent execution environments (like `opencode`, Aider, or custom MCP servers), the root contains hidden folders (`.opencode/`, `.agents/`) with symbolic links pointing back to the core files. This ensures your tool natively picks up the configurations without requiring duplicate maintenance.

### Provider-Agnostic Models

Models are declared as **`recommended_model`** in the YAML frontmatter of the agent markdown files. This prevents execution environments from crashing if they attempt to parse a provider-specific string. 

To map these recommended models to your specific AI provider (OpenAI, Anthropic, GitHub Copilot, OpenRouter), see `model-mappings.example.json` and copy the relevant configuration into your tool's global config file (e.g., `~/.config/opencode/opencode.json`).

## Usage

Once installed in your tool's environment:

```
/ARC-7                # Review current conversation context
/ARC-7 <document>     # Review specific document (e.g. /ARC-7 docs/architecture.md)
/ARC-7 <github-url>   # Review entire codebase
/ARC-7 help           # Show usage instructions
```