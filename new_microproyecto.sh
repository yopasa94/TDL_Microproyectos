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

# 2. Install base Jupyter kernel support + any requirements.txt + extra packages
EXTRA_PKGS=("$@")
REQ_PKGS=()
if [[ -f "requirements.txt" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(echo "$line" | xargs)"
        if [[ -n "$line" ]]; then
            # Strip strict == pins so packages created on older Python versions resolve on 3.15
            pkg_name="${line%%[=<>!~]*}"
            REQ_PKGS+=("$pkg_name")
        fi
    done < "requirements.txt"
fi

ALL_EXTRA=(${REQ_PKGS[@]+"${REQ_PKGS[@]}"} ${EXTRA_PKGS[@]+"${EXTRA_PKGS[@]}"})
echo "==> Installing dependencies (ipykernel, jupyter${ALL_EXTRA[*]:+, ${ALL_EXTRA[*]}})..."
uv add ipykernel jupyter ${ALL_EXTRA[@]+"${ALL_EXTRA[@]}"}

# Ensure macOS Apple Silicon vnode code-signature cache is not stale (prevents SIGKILL / exit 137)
if [[ -L ".venv/bin/python" ]]; then
    REAL_PY="$(python3 -c 'import os; print(os.path.realpath(".venv/bin/python"))')"
    if ! .venv/bin/python --version >/dev/null 2>&1; then
        echo "==> Refreshing macOS code-signature inode for ${REAL_PY}..."
        cp "$REAL_PY" "${REAL_PY}.tmp"
        rm -f "$REAL_PY"
        mv "${REAL_PY}.tmp" "$REAL_PY"
        codesign --force --sign - "$REAL_PY" >/dev/null 2>&1 || true
    fi
fi

# 3. Register the Jupyter kernel (both user-level and inside the virtualenv sys-prefix)
echo "==> Registering Jupyter kernel: '${DISPLAY_NAME}' (${KERNEL_NAME})..."
uv run python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$DISPLAY_NAME"
uv run python -m ipykernel install --sys-prefix --name "$KERNEL_NAME" --display-name "$DISPLAY_NAME"
uv run python -m ipykernel install --sys-prefix --name "python3" --display-name "$DISPLAY_NAME"

# 4. Update kernelspec metadata in any existing .ipynb files inside this microproject
python3 - "$KERNEL_NAME" "$DISPLAY_NAME" <<'PYEOF'
import json, sys
from pathlib import Path

kernel_name = sys.argv[1]
display_name = sys.argv[2]

for nb_path in Path(".").glob("*.ipynb"):
    try:
        nb = json.loads(nb_path.read_text(encoding="utf-8"))
        meta = nb.setdefault("metadata", {})
        ks = meta.setdefault("kernelspec", {})
        if ks.get("name") != kernel_name or ks.get("display_name") != display_name:
            ks["name"] = kernel_name
            ks["display_name"] = display_name
            ks["language"] = "python"
            nb_path.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
            print(f"  Updated kernelspec in {nb_path.name} -> {display_name}")
    except Exception as exc:
        print(f"  Warning: could not update {nb_path}: {exc}", file=sys.stderr)
PYEOF

# 5. Ensure .vscode/settings.json is updated for this microproject
cd "$REPO_ROOT"
mkdir -p .vscode
python3 - "$PROJECT_DIR" <<'PYEOF'
import json, sys
from pathlib import Path

project_dir = sys.argv[1]
ws_project_dir = f"${{workspaceFolder}}/{project_dir}"
settings_path = Path(".vscode/settings.json")
try:
    data = json.loads(settings_path.read_text(encoding="utf-8"))
except Exception:
    data = {}

data["python.defaultInterpreterPath"] = f"{ws_project_dir}/.venv/bin/python"

# Clean up any hardcoded absolute paths and ensure ${workspaceFolder}/microproyecto_N is present
folders = data.setdefault("python.venvFolders", [])
normalized_folders = []
for f in folders:
    if f.endswith(f"/{project_dir}") and not f.startswith("${workspaceFolder}"):
        f = ws_project_dir
    if f not in normalized_folders:
        normalized_folders.append(f)
if ws_project_dir not in normalized_folders:
    normalized_folders.append(ws_project_dir)
data["python.venvFolders"] = normalized_folders

projects = data.setdefault("python-envs.pythonProjects", [])
if not any(p.get("path") == project_dir for p in projects):
    projects.append({
        "path": project_dir,
        "envManager": "ms-python.python:venv",
        "packageManager": "ms-python.python:pip",
    })

settings_path.write_text(json.dumps(data, indent=4) + "\n", encoding="utf-8")
PYEOF

echo ""
echo "Done! ${PROJECT_DIR} is ready:"
echo "  - Folder:         ${REPO_ROOT}/${PROJECT_DIR}"
echo "  - Virtualenv:     ${REPO_ROOT}/${PROJECT_DIR}/.venv"
echo "  - Jupyter Kernel: ${DISPLAY_NAME}"

