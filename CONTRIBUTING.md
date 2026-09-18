# Contribuer

Le kit s'adresse à deux outils (Claude Code et opencode) à partir d'une seule source. Quelques
règles suffisent à ce qu'il le reste.

## La règle qui compte

**`.claude/` est la source de vérité. `.opencode/agents/` et `.opencode/commands/` sont générés.**

```bash
./scripts/sync-opencode.sh          # après toute modification de .claude/agents ou .claude/skills
./scripts/sync-opencode.sh --check  # ce que la CI vérifie
```

N'éditez jamais un fichier portant l'en-tête « Fichier GÉNÉRÉ » : votre modification sera écrasée
à la prochaine synchronisation, et pendant ce temps les deux outils n'appliqueront pas les mêmes
règles — ce qui est exactement le problème que ce dépôt cherche à éviter.

Les seules exceptions, écrites à la main : `.opencode/plugins/devsecops-guards.js` et
`.claude/hooks/*.sh`. Ils implémentent les mêmes contrôles pour deux runtimes : **modifiez les deux
ensemble**, ou dites explicitement dans la PR pourquoi un seul change.

## Avant d'ouvrir une PR

1. `./scripts/sync-opencode.sh --check` passe.
2. `bash -n` passe sur chaque script modifié ; les fichiers JSON et le frontmatter YAML parsent.
3. Si vous touchez à un garde-fou, **montrez la preuve qu'il bloque encore** : la commande, et sa
   sortie. Un contrôle sans démonstration est une intention, pas un contrôle.
4. Si vous ajoutez un agent, ajoutez son profil de permissions dans `profile_for()`. Le script
   échoue sinon — volontairement : aucun agent ne doit hériter de permissions par défaut.
5. Aucun secret, même factice, même « juste pour tester ». Utilisez `AKIAIOSFODNN7EXAMPLE`,
   l'exemple public d'AWS, si vous devez démontrer une détection.

## Ce qui sera refusé

- Affaiblir un contrôle pour faire passer la CI : `continue-on-error`, `soft_fail: true`,
  `# nosec`, `# nosemgrep`, `--no-verify`, suppression d'un job de scan. Si un gate est mauvais,
  argumentez pour le corriger, pas pour le contourner.
- Un tag d'action flottant (`@latest`, `@master`) : épinglez, et vérifiez que la version existe.
- Une dépendance dont l'existence n'a pas été vérifiée sur le registre officiel.
- Une règle qui ne correspond à rien. Une permission qui ne matche jamais donne une fausse
  assurance ; c'est pire que pas de règle du tout.

## Style

Français pour la documentation et les prompts, termes techniques en anglais (OWASP, STRIDE,
Broken Access Control). Les commentaires expliquent **pourquoi**, pas quoi.
