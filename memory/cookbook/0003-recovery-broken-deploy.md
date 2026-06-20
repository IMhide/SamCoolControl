---
id: 0003
type: cookbook
scope: global
title: Récupérer après un déploiement cassé
tags: [recovery, deployment, debug, service, delete-recreate]
date: 2026-06-20
status: active
related: [decisions/0003, cookbook/0001, cookbook/0002]
---

## Contexte

Un déploiement échoue ou un conteneur reste en état cassé. Comment diagnostiquer et repartir
proprement.

## Procédure

```bash
# Application : inspecter le déploiement
./scripts/coolify raw GET /deployments/<deployment-uuid> | jq '{status, logs}'

# Service bloqué en "exited" permanent : supprimer puis recréer
./scripts/coolify raw DELETE /services/<uuid>
sleep 10
# … recréer proprement (voir cookbook/0002)
```

## Pourquoi / Conséquences

**Règle d'or** : si un **service** est cassé, `DELETE` + recréer est plus rapide que debugger
(voir `decisions/0003`). Pour une **Application**, les logs de déploiement (`/deployments/<uuid>`)
suffisent généralement à identifier la cause avant de relancer.
