---
id: 0001
type: cookbook
scope: global
title: Déployer une image Docker avec domaine HTTPS (Traefik)
tags: [docker-image, https, traefik, application, deploy, volumes, ports]
date: 2026-03-26
status: active
related: [decisions/0001, decisions/0002, habits/0001, habits/0002, cookbook/0003]
---

## Contexte

Déployer un **conteneur unique** (image Docker) avec un domaine **HTTPS via Traefik**. C'est la
méthode la plus fiable via l'API pour obtenir Traefik + HTTPS automatique. On crée une
**Application** (pas un Service) — voir `decisions/0001`.

## Procédure

```bash
# 1. Créer l'application (jq pour le body — voir habits/0001)
./scripts/coolify raw POST /applications/dockerimage "$(jq -n '{
  name: "mon-app",
  description: "Description",
  server_uuid: "<SERVER_UUID>",
  project_uuid: "<PROJECT_UUID>",
  environment_name: "production",
  docker_registry_image_name: "image/name",
  docker_registry_image_tag: "latest",
  ports_exposes: "8080",          # port interne pour Traefik
  ports_mappings: "9000:9000",    # ports directs host:container (optionnel)
  instant_deploy: false           # voir habits/0002
}')"
# → retourne { uuid, domains }

# 2. Configurer le domaine — champ "domains" en PATCH (PAS "fqdn" → 422, voir decisions/0002)
./scripts/coolify raw PATCH /applications/<uuid> '{"domains":"https://mon-app.example.tld"}'

# 3. Volumes persistants
./scripts/coolify raw PATCH /applications/<uuid> \
  '{"custom_docker_run_options":"-v mon-app-data:/data -v mon-app-logs:/logs"}'

# 4. Env vars (un par un, ou bulk via /envs/bulk)
./scripts/coolify raw POST /applications/<uuid>/envs "$(jq -n '{key:"MA_CLE",value:"ma_valeur"}')"

# 5. Déployer
./scripts/coolify app:start <uuid>

# 6. Vérifier (~60s)
./scripts/coolify app <uuid> | jq '{status, fqdn}'
curl -s https://mon-app.example.tld/ -o /dev/null -w "%{http_code}\n"
```

## Paramètres clés

- **`ports_exposes`** : port interne qui reçoit le trafic HTTPS via Traefik.
- **`ports_mappings`** : ports exposés directement sur le host (`host:container`), accès sans Traefik.
- **`domains`** : champ PATCH pour le FQDN (`fqdn` est rejeté en 422 — voir `decisions/0002`).
- **`custom_docker_run_options`** : volumes, security opts, flags Docker.
- **`force_domain_override: true`** : à ajouter au PATCH `domains` si conflit 409.

## Pourquoi / Conséquences

Application + image Docker = Traefik HTTPS qui marche nativement via l'API, volumes via
`custom_docker_run_options`, env vars par POST/bulk. Pour du multi-conteneur, c'est un Service
(voir `cookbook/0002`), mais Traefik n'y marche pas via l'API (voir `decisions/0001`).
