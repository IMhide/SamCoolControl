---
name: infra-switch
description: List, show, or switch the active Coolify infra/profile. Use when the user wants to see which infras exist, which is active, or change the active one.
---

# /infra-switch — gérer le profil d'infra actif

Lister les infras, voir l'active, en changer.

## Procédure

- **Lister** : `./scripts/infra list` (marque l'active d'un `*`).
- **Voir l'active** : `./scripts/infra current`.
- **Détails d'une infra** : `./scripts/infra show <nom>` (affiche `infra.yaml` + résumé
  `facts.md`/`registry.md` ; ne montre que les *clés* du `.env`, jamais les valeurs).
- **Changer l'active** : `./scripts/infra use <nom>`.
  - Vérifie d'abord que l'infra existe (`infra list`).
  - **Confirme le changement** : annonce la nouvelle infra active + son `base_url` (depuis
    `infra.yaml`), pour que l'utilisateur sache sur quelle cible porteront les prochaines commandes.
  - Si l'infra n'a pas de `.env`, préviens qu'il faut le remplir avant tout appel API.

> Rappel : on peut aussi cibler ponctuellement une infra sans changer l'active, via
> `./scripts/coolify --infra <nom> <cmd>`.
