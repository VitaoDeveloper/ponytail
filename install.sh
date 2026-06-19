#!/usr/bin/env bash
# ponytail: install.sh — install ponytail for supported agents
set -euo pipefail

PONYTAIL_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── helpers ──────────────────────────────────────────────────────────

green()  { printf '\033[32m%s\033[0m\n' "$*"; }
dim()    { printf '\033[2m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m' "$*"; }
err()    { printf '\033[31m%s\033[0m\n' "$*" >&2; }
header() { printf '\n\033[1;36m%s\033[0m\n' "$*"; }

prompt_yn() {
  # $1: prompt text, returns 0 for yes, 1 for no
  local ans
  printf "%s [Y/n] " "$1" >&2
  read -r ans
  [[ -z "$ans" || "$ans" =~ ^[Yy] ]]
}

# ── agents ───────────────────────────────────────────────────────────

AGENTS=()
INSTALL=()
TOGGLE=()

register_agent() {
  # usage: register_agent <name> <detect_cmd> <install_cmd> <label>
  local name="$1"; shift
  local detect_cmd="$1"; shift
  local install_cmd="$1"; shift
  local label="$*"

  AGENTS+=("$name")
  # store detect + install as eval-able strings
  eval "detect_${name}() { $detect_cmd; }"
  eval "install_${name}() { $install_cmd; }"
  # store label for menu
  eval "label_${name}='$label'"
}

# ── Agent: Claude Code ──────────────────────────────────────────────

register_agent "claude" \
  'command -v claude &>/dev/null' \
  'claude /plugin marketplace add DietrichGebert/ponytail 2>/dev/null || true
   claude /plugin install ponytail@ponytail 2>/dev/null || true
   green "  ✓ Claude Code: plugin installed. If using the desktop app, install from the UI instead (see README)."' \
  "Claude Code"

# ── Agent: Codex ─────────────────────────────────────────────────────

register_agent "codex" \
  'command -v codex &>/dev/null' \
  'codex plugin marketplace add DietrichGebert/ponytail 2>/dev/null || true
   green "  ✓ Codex: plugin marketplace added. Open Codex, go to /plugins, install Ponytail, then review hooks at /hooks."' \
  "Codex"

# ── Agent: Copilot CLI ─────────────────────────────────────────────

register_agent "copilot" \
  'command -v copilot &>/dev/null' \
  'copilot plugin marketplace add DietrichGebert/ponytail 2>/dev/null || true
   copilot plugin install ponytail@ponytail 2>/dev/null || true
   green "  ✓ Copilot CLI: plugin installed. Use /ponytail:ponytail to switch levels."' \
  "Copilot CLI"

# ── Agent: Gemini CLI ──────────────────────────────────────────────

register_agent "gemini" \
  'command -v gemini &>/dev/null' \
  'gemini extensions install https://github.com/DietrichGebert/ponytail 2>/dev/null || true
   green "  ✓ Gemini CLI: extension installed. Runs ponytail as always-on context."' \
  "Gemini CLI"

# ── Agent: Antigravity CLI ──────────────────────────────────────────

register_agent "antigravity" \
  'command -v agy &>/dev/null' \
  'agy plugin install https://github.com/DietrichGebert/ponytail 2>/dev/null || true
   green "  ✓ Antigravity CLI: extension installed. Use /ponytail commands in chat."' \
  "Antigravity CLI"

# ── Agent: Pi ────────────────────────────────────────────────────────

register_agent "pi" \
  'command -v pi &>/dev/null' \
  'pi install git:github.com/DietrichGebert/ponytail 2>/dev/null || true
   green "  ✓ Pi: extension installed."' \
  "Pi"

# ── Agent: OpenClaw ──────────────────────────────────────────────────

register_agent "openclaw" \
  'command -v clawhub &>/dev/null' \
  'clawhub install ponytail 2>/dev/null || true
   green "  ✓ OpenClaw: skill installed."' \
  "OpenClaw"

# ── File-copy helpers ───────────────────────────────────────────────

copy_rule() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$PONYTAIL_DIR/$src" "$dst"
  green "  ✓ $3"
}

# ── Agent: Cursor ────────────────────────────────────────────────────

register_agent "cursor" \
  'return 0' \
  'copy_rule ".cursor/rules/ponytail.mdc" ".cursor/rules/ponytail.mdc" "Cursor: rule copied to .cursor/rules/ponytail.mdc"' \
  "Cursor"

# ── Agent: Windsurf ──────────────────────────────────────────────────

register_agent "windsurf" \
  'return 0' \
  'copy_rule ".windsurf/rules/ponytail.md" ".windsurf/rules/ponytail.md" "Windsurf: rule copied to .windsurf/rules/ponytail.md"' \
  "Windsurf"

# ── Agent: Cline ─────────────────────────────────────────────────────

register_agent "cline" \
  'return 0' \
  'copy_rule ".clinerules/ponytail.md" ".clinerules/ponytail.md" "Cline: rule copied to .clinerules/ponytail.md"' \
  "Cline"
