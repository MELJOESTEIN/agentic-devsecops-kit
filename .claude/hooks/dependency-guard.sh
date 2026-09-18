#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# Anti-hallucination de dépendance (« slopsquatting ») : avant `pip install X` / `npm install X`,
# vérifie que X existe sur le registre officiel. Bloque si le package est introuvable.
# Exit 0 = laisser passer · Exit 2 = bloquer.

set -u
INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

check_url() {  # $1 = url ; renvoie 0 si HTTP 200
  if command -v curl >/dev/null 2>&1; then
    [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 "$1")" = "200" ]
  else
    python3 - "$1" <<'PY'
import sys, urllib.request
try:
    urllib.request.urlopen(urllib.request.Request(sys.argv[1], headers={"User-Agent": "dep-guard"}), timeout=8)
    sys.exit(0)
except Exception:
    sys.exit(1)
PY
  fi
}

block() {
  echo "BLOCKED: le package '$1' est introuvable sur $2. Il s'agit peut-être d'une dépendance hallucinée (slopsquatting) — un attaquant peut publier un package sous ce nom. Vérifie le nom exact, la réputation (téléchargements, dépôt source, mainteneurs) et propose une alternative connue." >&2
  exit 2
}

# ---- pip / pip3 / python -m pip install <pkgs>
if printf '%s' "$CMD" | grep -Eq '(^|[;&| ])(pip3?|python3? -m pip) install'; then
  # ignorer les installs depuis un fichier de requirements ou un chemin local
  if printf '%s' "$CMD" | grep -Eq -- ' -r | --requirement |\./|^\.|/'; then exit 0; fi
  PKGS="$(printf '%s' "$CMD" | sed -E 's/.*pip3?( install| -m pip install)//; s/python3? -m pip install//' | tr ' ' '\n' | grep -Ev '^(-|$)' )"
  for p in $PKGS; do
    name="$(printf '%s' "$p" | sed -E 's/[<>=!~\[].*$//' | tr '[:upper:]' '[:lower:]')"
    [ -z "$name" ] && continue
    check_url "https://pypi.org/pypi/${name}/json" || block "$name" "PyPI"
  done
fi

# ---- npm install / npm i / pnpm add / yarn add <pkgs>
if printf '%s' "$CMD" | grep -Eq '(^|[;&| ])(npm (install|i|add)|pnpm add|yarn add)'; then
  PKGS="$(printf '%s' "$CMD" | sed -E 's/.*(npm (install|i|add)|pnpm add|yarn add)//' | tr ' ' '\n' | grep -Ev '^(-|$)')"
  for p in $PKGS; do
    name="$(printf '%s' "$p" | sed -E 's/@[^/]*$//')"   # retire @version (garde les scopes @org/pkg)
    [ -z "$name" ] && continue
    enc="$(printf '%s' "$name" | sed 's#/#%2F#g')"
    check_url "https://registry.npmjs.org/${enc}" || block "$name" "npm"
  done
fi

exit 0
