---
id: 0002
type: cookbook
scope: global
title: Déployer un service multi-conteneur (Docker Compose)
tags: [service, docker-compose, multi-conteneur, base64, traefik, ports]
date: 2026-06-20
status: active
related: [decisions/0001, cookbook/0001, habits/0001, habits/0002]
---

## Contexte

Déployer un **service composé de plusieurs conteneurs** (app + db, par ex.) via Docker Compose.
Si c'est un **conteneur unique avec HTTPS**, préférer une Application (voir `cookbook/0001` et
`decisions/0001`).

## Procédure

```bash
# 1. Préparer le compose puis l'encoder base64
B64=$(cat mon-compose.yml | base64)

# 2. Créer le service (jq pour le JSON — voir habits/0001)
./scripts/coolify raw POST /services "$(jq -n --arg raw "$B64" '{
  name: "MonService",
  description: "Description",
  server_uuid: "<SERVER_UUID>",
  project_uuid: "<PROJECT_UUID>",
  environment_name: "production",
  docker_compose_raw: $raw,
  instant_deploy: false          # voir habits/0002
}')"

# 3. Vérifier les env vars
./scripts/coolify service:envs <uuid>

# 4. Démarrer
./scripts/coolify service:start <uuid>

# 5. Vérifier (60-90s)
./scripts/coolify raw GET /services/<uuid> | jq .status
```

## Domaines HTTPS pour les services — ATTENTION

**Traefik ne fonctionne PAS pour les services déployés via l'API (503 systématique).**
Voir `decisions/0001`.

Ne marchent **pas** via l'API :
- `SERVICE_FQDN_*` dans le compose
- `urls` PATCH sur le service
- Labels Traefik custom dans le compose
- Réseau `coolify: external: true`
- `connect_to_docker_network: true`

Marchent :
- Accès direct via `ports:` (`http://IP:PORT`)
- FQDN configuré depuis l'**UI Coolify** (l'UI gère la connectivité réseau)
- **Mieux** : déployer en Application si conteneur unique (`cookbook/0001`)

## Astuces / Conséquences

- `instant_deploy:false` pour vérifier les env vars avant de démarrer (`habits/0002`).
- `${SERVICE_PASSWORD_XXX}` dans le compose = Coolify auto-génère des secrets.
- Volumes préfixés automatiquement avec l'UUID du service.
- Mettre à jour une env var : `PATCH /services/<uuid>/envs '{"key":"K","value":"V"}'`.
