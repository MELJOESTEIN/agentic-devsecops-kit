#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# Bloque `git commit` / `git push` si Gitleaks détecte un secret dans les fichiers stagés.
# Reçoit sur stdin le JSON {"tool_name":"Bash","tool_input":{"command":"..."}}.
# Exit 0 = laisser passer · Exit 2 = bloquer (le message stderr est renvoyé à Claude).

set -u
INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

# Ne s'applique qu'aux commits et pushes
case "$CMD" in
  *"git commit"*|*"git push"*) ;;
  *) exit 0 ;;
esac

# Refuser explicitement le contournement des hooks Git
if printf '%s' "$CMD" | grep -Eq -- '--no-verify|(^| )-n( |$)'; then
  echo "BLOCKED: '--no-verify' est interdit dans ce dépôt (règle DevSecOps n°5). Retire l'option et corrige la cause." >&2
  exit 2
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "WARNING: gitleaks n'est pas installé — le contrôle des secrets avant commit n'a pas pu s'exécuter. Installe-le (https://github.com/gitleaks/gitleaks)." >&2
  exit 0
fi

# Scanner uniquement ce qui est stagé (rapide), en masquant les valeurs
if ! OUT="$(gitleaks protect --staged --redact --no-banner 2>&1)"; then
  echo "BLOCKED: Gitleaks a détecté un secret dans les fichiers stagés. Un secret commité est un secret compromis : externalise-le (variable d'environnement / GitHub Secrets), retire-le du staging, puis fais-le tourner (rotation)." >&2
  echo "$OUT" | tail -n 25 >&2
  exit 2
fi

exit 0
