---
name: dependency-check
description: Vérifier les dépendances du projet — existence réelle sur le registre (anti-hallucination / slopsquatting), réputation, vulnérabilités connues (SCA), épinglage des versions, SBOM. À utiliser avant d'ajouter une dépendance, quand une dépendance est suggérée (par l'IA ou un humain), ou pour un audit périodique des composants tiers.
allowed-tools: Read, Grep, Glob, Bash, Write
---

# /dependency-check — Vérifier ce qu'on embarque

## A. Avant d'ajouter UNE dépendance (mode ciblé)
Pour chaque package proposé :
1. **Existence** : `pip index versions <pkg>` / `npm view <pkg> version` (ou consulter la page PyPI/npm). Introuvable → **stop** : probable hallucination, proposer une alternative établie.
2. **Réputation** : dépôt source lié, dernière publication, nombre de mainteneurs, téléchargements, typosquatting possible (nom proche d'un package connu ?).
3. **Vulnérabilités** : `pip-audit` / `npm audit` sur la version envisagée ; licence compatible.
4. **Épinglage** : proposer la version exacte à écrire dans `requirements.txt` / `package.json` (+ lockfile).
5. Conclure : *Acceptable* / *À éviter* + justification en une ligne, à copier dans la PR.

## B. Audit périodique du projet (mode complet)
1. **Inventaire** : arbre des dépendances directes et transitives (`pip list` / `pipdeptree`, `npm ls --all`).
2. **SBOM** : `syft dir:. -o spdx-json > sbom.json` (ou sur l'image : `syft <image>`), à archiver comme artefact de build.
3. **SCA** : `pip-audit -r requirements.txt` / `npm audit --audit-level=high` ; `trivy fs .` pour une vue croisée.
4. **Triage** (ne pas se fier au seul score CVSS) : pour chaque finding HIGH/CRITICAL, répondre à *exploitable dans notre usage ? composant exposé ? correctif disponible ?* et classer : corriger maintenant / planifier / accepter (justifié).
5. **Épinglage & hygiène** : versions flottantes, packages inutilisés, doublons.
6. **Rapport** dans `docs/security/dependencies-<date>.md` + rappel des gates CI (`pip-audit`/`npm audit` bloquants, Trivy image, Dependabot activé).

## Interdits
Ne jamais exécuter `pip install` / `npm install` d'un package dont l'existence n'a pas été vérifiée. Ne pas résoudre une alerte en la masquant (`--ignore-vuln`, `audit-level` relevé) sans justification écrite et datée.
