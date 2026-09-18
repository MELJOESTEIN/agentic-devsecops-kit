#!/usr/bin/env bash
# PostToolUse hook (matcher: Edit|Write)
# Après chaque écriture de fichier, lance Semgrep (règles OWASP) sur ce fichier et
# remonte les findings à Claude comme avertissement. Ne bloque pas (le fichier est déjà écrit) :
# c'est le pipeline CI et la branch protection qui bloquent. Ici on rend le problème visible tout de suite.

set -u
INPUT="$(cat)"
FILE="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"
[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

# Ne scanner que le code source
case "$FILE" in
  *.py|*.js|*.ts|*.tsx|*.jsx|*.go|*.java|*.rb|*.php|*.yml|*.yaml|*.tf|Dockerfile|*/Dockerfile) ;;
  *) exit 0 ;;
esac

# Alerte immédiate si le fichier écrit ressemble à un secret / clé (protection défensive supplémentaire)
case "$FILE" in
  *.env|*/.env|*.pem|*.key|*id_rsa*|*.tfstate)
    echo "WARNING: écriture dans un fichier sensible ($FILE). Vérifie qu'il est dans .gitignore et qu'aucun secret réel n'y figure." >&2 ;;
esac

command -v semgrep >/dev/null 2>&1 || exit 0

# Semgrep rapide, sortie compacte, uniquement les findings
OUT="$(semgrep scan --config p/owasp-top-ten --config p/secrets --quiet --error --no-git-ignore "$FILE" 2>/dev/null)" && exit 0
COUNT="$(printf '%s\n' "$OUT" | grep -c '❯❯' || true)"
{
  echo "SEMGREP: findings potentiels dans $FILE (règles OWASP Top 10 / secrets). Traite-les ou justifie-les explicitement — ne les masque pas avec 'nosemgrep' sans accord humain."
  printf '%s\n' "$OUT" | head -n 40
} >&2
exit 0
