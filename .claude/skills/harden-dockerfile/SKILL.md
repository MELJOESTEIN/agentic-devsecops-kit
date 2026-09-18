---
name: harden-dockerfile
description: Durcir un Dockerfile selon les 4 principes (minimal, non-root, pinned, scanned), avec preuve Trivy avant/après et vérification que l'application tourne toujours. À utiliser quand l'utilisateur demande de sécuriser une image, corriger des CVE d'image, ou avant de publier une image sur un registry.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, Agent
---

# /harden-dockerfile — Durcir une image

## Étapes
1. **Baseline** : `docker build -t app:before .` puis `trivy image --severity HIGH,CRITICAL app:before | tee docs/security/trivy-before.txt` ; `docker run --rm app:before whoami` ; `docker history app:before` (repérer `COPY . .`, secrets, couches inutiles). Noter taille (`docker images app:before`).
2. **Diagnostic** contre les 4 principes :
   - *Minimal* : base `-slim`/`alpine`/distroless adaptée ; pas d'outils de build dans l'image finale (multi-stage).
   - *Non-root* : `USER` avec UID fixe ≥ 10000 ; fichiers `--chown`.
   - *Pinned* : tag précis (ou digest) pour la base, versions épinglées des dépendances, pas de `latest`.
   - *Scanned* : Trivy en CI avec `exit-code: 1` sur CRITICAL.
   Plus : `.dockerignore` (`.git`, `.env`, tests, docs, `*.db`), pas de secret en `ARG`/`ENV`, `--no-cache-dir`, `HEALTHCHECK` si pertinent.
3. **Appliquer** les corrections (déléguer à `pipeline-hardener` si le changement est large), avec un commentaire par choix non évident.
4. **Prouver** : `docker build -t app:after .` ; `trivy image --severity HIGH,CRITICAL app:after | tee docs/security/trivy-after.txt` ; `docker run --rm app:after whoami` (≠ root) ; démarrer l'app et appeler son endpoint de santé ; si possible `docker run --read-only --cap-drop ALL` et vérifier qu'elle répond.
5. **Résumer** : tableau avant/après (taille, nb CRITICAL/HIGH, utilisateur), CVE restantes sans correctif upstream (à accepter explicitement), et rappel d'ajouter/garder le job `image-scan` bloquant en CI.

## Interdits
Ne pas ignorer une CVE via un fichier d'exclusion sans justification écrite. Ne pas casser l'application pour faire baisser le score : chaque durcissement est vérifié par un démarrage réel.
