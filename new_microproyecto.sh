#!/usr/bin/env bash
set -euo pipefail

# Move to the repository root (where this script lives)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

PYTHON_VERSION="3.15"

# Determine N automatically (or use first argument if numeric)
if [[ $# -ge 1 && "$1" =~ ^[0-9]+$ ]]; then
    N="$1"
    shift
else
    # Check if there is an existing uninitialized microproyecto_K directory first,
    # otherwise pick max(N) + 1
    MAX_N=0
    UNINITIALIZED_N=""
    for dir in microproyecto_*; do
        if [[ -d "$dir" && "$dir" =~ ^microproyecto_([0-9]+)$ ]]; then
            num="${BASH_REMATCH[1]}"
            if [[ ! -f "$dir/pyproject.toml" && -z "$UNINITIALIZED_N" ]]; then
                UNINITIALIZED_N="$num"
            fi
            if (( num > MAX_N )); then
                MAX_N="$num"
            fi
        fi
    done

    if [[ -n "$UNINITIALIZED_N" ]]; then
        N="$UNINITIALIZED_N"
    else
        N=$(( MAX_N + 1 ))
    fi
fi

PROJECT_DIR="microproyecto_${N}"
KERNEL_NAME="microproyecto-${N}"
DISPLAY_NAME="Python ${PYTHON_VERSION} (${PROJECT_DIR})"

echo "==> Setting up ${PROJECT_DIR}..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 1. Initialize uv project if pyproject.toml does not exist
if [[ ! -f "pyproject.toml" ]]; then
    uv init --python "$PYTHON_VERSION" --name "$KERNEL_NAME"
fi

# 2. Install base Jupyter kernel support + any extra packages passed as arguments
EXTRA_PKGS=("$@")
echo "==> Installing dependencies (ipykernel, jupyter${EXTRA_PKGS:+, ${EXTRA_PKGS[*]}})..."
uv add ipykernel jupyter "${EXTRA_PKGS[@]}"

# 3. Register the Jupyter kernel
echo "==> Registering Jupyter kernel: '${DISPLAY_NAME}' (${KERNEL_NAME})..."
uv run python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$DISPLAY_NAME"

# 4. Ensure .vscode/settings.json includes this folder in python.venvFolders
cd "$REPO_ROOT"
if [[ -f ".vscode/settings.json" ]]; then
    python3 - "$PROJECT_DIR" <<'PYEOF'
import json, sys
from pathlib import Path

project_dir = sys.argv[1]
settings_path = Path(".vscode/settings.json")
try:
    data = json.loads(settings_path.read_text())
except Exception:
    data = {}

folders = data.setdefault("python.venvFolders", [])
if project_dir not in folders:
    folders.append(project_dir)
    settings_path.write_text(json.dumps(data, indent=4) + "\n")
PYEOF
fi

echo ""
echo "Done! ${PROJECT_DIR} is ready:"
echo "  - Folder:         ${REPO_ROOT}/${PROJECT_DIR}"
echo "  - Virtualenv:     ${REPO_ROOT}/${PROJECT_DIR}/.venv"
echo "  - Jupyter Kernel: ${DISPLAY_NAME}"

