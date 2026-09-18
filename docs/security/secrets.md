# Gestion des secrets

Modèle à compléter pour votre projet. Aucun secret ne figure ici : **ce fichier décrit où ils
vivent, pas ce qu'ils valent.**

## Inventaire

| Secret | À quoi il sert | Où il vit | Qui y accède | Rotation | Dernière rotation |
|---|---|---|---|---|---|
| `DATABASE_URL` | connexion PostgreSQL | env de déploiement | service applicatif | 90 j | AAAA-MM-JJ |
| `ANTHROPIC_API_KEY` | revue de PR en CI | GitHub Actions secrets | workflow uniquement | 180 j | AAAA-MM-JJ |

## Règles

1. **Jamais dans le dépôt** — ni code, ni test, ni fixture, ni log, ni message de commit, ni
   capture d'écran de README. Le kit bloque le commit (Gitleaks) et interdit la lecture de `.env`,
   `*.pem`, `*.key`, `*.tfstate` par l'agent.
2. **Variables d'environnement** en local (`.env`, non versionné, présent dans `.gitignore`),
   **GitHub Secrets** en CI, gestionnaire dédié en production (Vault, SSM, Secret Manager).
3. **Un `.env.example`** versionné, avec les clés et des valeurs factices évidentes — c'est la
   documentation de ce qu'il faut fournir, sans fournir quoi que ce soit.
4. **Portée minimale** : un token par usage, avec les droits strictement nécessaires. Un token de
   CI n'a pas besoin des droits d'administration de l'organisation.

## Un secret a fuité — que faire, dans cet ordre

Un secret commité est un secret **compromis**, même si le commit est supprimé une minute plus tard :
il est dans le reflog, dans les forks, dans les caches, et sur GitHub public il est scanné par des
bots en quelques secondes.

1. **Révoquer d'abord.** La rotation passe avant le nettoyage de l'historique. Un secret révoqué et
   toujours présent dans Git est inoffensif ; un secret retiré de Git mais toujours valide ne l'est
   pas.
2. **Émettre le nouveau secret** et le déployer.
3. **Chercher l'usage abusif** dans les logs entre la date du commit et la révocation — c'est un
   incident : voir `/incident-report`.
4. **Nettoyer l'historique** si nécessaire (`git filter-repo`), en prévenant l'équipe : les hashes
   changent.
5. **Ajouter la détection** qui aurait évité la fuite (hook, gate CI) et noter la leçon.

## Vérifier

```bash
gitleaks git --redact --no-banner      # historique complet
gitleaks git --staged --redact         # avant un commit (ce que fait le garde-fou du kit)
```
