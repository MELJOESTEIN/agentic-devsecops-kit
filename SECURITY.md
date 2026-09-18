# Politique de sécurité

## Ce que ce dépôt est — et ce qu'il n'est pas

Ce kit est une **configuration d'agent** : des règles, des prompts, des permissions, des garde-fous
et des workflows CI. Il n'y a ni service exposé, ni données utilisateur, ni dépendance applicative.

Il ne rend pas votre code sûr. Il rend plus difficile, pour un agent comme pour un humain pressé,
de commiter un secret, d'installer une dépendance qui n'existe pas, ou de désactiver un contrôle
pour faire passer un pipeline. La preuve reste le rôle des scanners et des tests ; la décision
reste celle d'un humain.

**Les permissions et les garde-fous de ce kit ne sont pas un bac à sable.** Ils réduisent la
surface d'erreur d'un agent coopératif. Ils n'arrêtent pas quelqu'un qui contrôle déjà la machine,
et ils ne remplacent ni la revue de code, ni la branch protection, ni le principe du moindre
privilège sur vos vrais secrets.

## Signaler une vulnérabilité

Ce qui nous intéresse en priorité :

- un garde-fou **contournable** (hook ou plugin qu'on peut faire passer avec un secret dedans) ;
- une règle de permission qui **n'applique pas** ce qu'elle prétend appliquer ;
- une **prompt injection** efficace contre un des prompts d'agent du kit ;
- un exemple de configuration qui serait dangereux si on le copiait tel quel.

Merci d'utiliser **Security → Report a vulnerability** (GitHub Private Vulnerability Reporting)
plutôt qu'une issue publique, et d'inclure : le fichier concerné, la façon de reproduire, et ce
qu'un attaquant y gagnerait.

Délai de réponse visé : 7 jours. Ce dépôt est maintenu à titre personnel, sans astreinte.

## Ce qui n'est pas une vulnérabilité ici

- « L'agent a proposé du code vulnérable. » C'est attendu : c'est précisément pourquoi le kit
  impose un test, un scan et une relecture humaine avant merge.
- « Un scanner remonte un faux positif. » Ouvrez une issue normale.
- Les exemples volontairement non sécurisés utilisés pour démontrer un blocage — la clé
  `AKIAIOSFODNN7EXAMPLE` de la documentation est l'exemple public d'AWS, pas un secret réel.
