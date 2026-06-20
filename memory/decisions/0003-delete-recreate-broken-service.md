---
id: 0003
type: decision
scope: global
title: DELETE + recréer un service cassé plutôt que le debugger
tags: [service, recovery, delete-recreate, debug, exited]
date: 2026-06-20
status: active
related: [cookbook/0003, cookbook/0002, decisions/0001]
---

## Contexte

Un Service Coolify reste bloqué (état `exited` permanent, conteneurs qui ne remontent pas) après
un déploiement ou un changement de config.

## Décision

> **Si un Service est cassé, `DELETE /services/<uuid>` + recréer proprement est plus rapide que
> debugger.**

(Pour une **Application**, au contraire, inspecter `/deployments/<uuid>` suffit en général —
ne pas supprimer par réflexe.)

## Pourquoi / Conséquences

Les Services Coolify portent beaucoup d'état implicite (réseau, volumes préfixés UUID, secrets
auto-générés). Quand l'état diverge, le remettre d'équerre à la main coûte plus cher qu'une
recréation propre depuis le compose (qu'on a déjà). Procédure : `cookbook/0003`. Recréation :
`cookbook/0002`.
