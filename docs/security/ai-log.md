# Journal des décisions assistées par IA

Trace de ce que l'IA a proposé, ce qui a été vérifié, ce qui a été accepté ou rejeté.

**À quoi ça sert.** Un agent qui se trompe une fois n'est pas un problème ; un agent qui se trompe
toujours de la même façon sans qu'on s'en aperçoive en est un. Ce journal rend le taux d'erreur
visible, et sert de preuve d'une revue humaine en cas d'audit.

**Qui le remplit.** Les colonnes *Périmètre*, *Verdict IA* et *Findings* sont remplies par l'agent
à la fin d'un `/security-review` ou d'un `/threat-model`. Les colonnes *Vérifié par* et *Décision*
sont remplies **par un humain** — c'est tout l'intérêt. Une ligne sans décision humaine est une
tâche en cours, pas une tâche terminée.

| Date | Périmètre | Outil / agent | Verdict IA | Findings retenus | Findings rejetés (et pourquoi) | Vérifié par | Décision |
|---|---|---|---|---|---|---|---|
| AAAA-MM-JJ | `git diff main...HEAD` | `/security-review` | Bloquant | IDOR sur `GET /orders/:id` | « CORS trop permissif » — faux positif, l'API est interne | *(initiales)* | Corrigé + test `test_order_ownership` |

## Ce qu'il faut noter, et qui se perd sinon

- Ce que l'analyse IA a **bien vu** que la revue humaine aurait manqué.
- Ce qu'il a fallu **corriger** dans son analyse (contrôle existant signalé à tort comme gap,
  menace hors sujet, IP de reverse proxy prise pour celle d'un attaquant).
- Ce qu'elle **n'a pas pu vérifier** — la liste des angles morts vaut souvent plus que les findings.
