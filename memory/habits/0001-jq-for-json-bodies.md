---
id: 0001
type: habit
scope: global
title: Toujours construire les bodies JSON de l'API avec jq
tags: [jq, json, api, escaping, base64]
date: 2026-06-20
status: active
related: [cookbook/0001, cookbook/0002]
---

## Contexte

Les appels d'écriture (`POST`/`PATCH`) prennent un body JSON. L'écrire à la main en shell mène vite
à des doubles-échappements cassés, surtout avec des valeurs contenant des guillemets, des sauts de
ligne ou du base64.

## Règle

> **Construire le JSON avec `jq -n`** (et `--arg` / `--argjson` pour injecter les valeurs), plutôt
> que de concaténer des chaînes.

```bash
./scripts/coolify raw POST /services "$(jq -n --arg raw "$B64" '{
  name:"X", docker_compose_raw:$raw, instant_deploy:false }')"
```

## Pourquoi / Conséquences

`jq` gère l'échappement correctement (guillemets, multiligne, base64). Indispensable pour
`docker_compose_raw` (blob base64) et `custom_labels`. Évite les 400/422 dus à un JSON malformé.
Convention transverse à tout ce projet.
