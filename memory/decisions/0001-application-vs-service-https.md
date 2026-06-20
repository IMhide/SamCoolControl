---
id: 0001
type: decision
scope: global
title: Application plutôt que Service pour un conteneur unique en HTTPS
tags: [application, service, traefik, https, docker-image, docker-compose]
date: 2026-03-26
status: active
related: [cookbook/0001, cookbook/0002]
---

## Contexte

Sur Coolify, deux façons de déployer via l'API : **Application** (`/applications/dockerimage`,
mono-conteneur) ou **Service** (`/services`, Docker Compose, multi-conteneur). Pour un conteneur
unique qui doit être servi en HTTPS via Traefik, lequel choisir ?

## Décision

| | Application (dockerimage) | Service (docker-compose) |
|---|---|---|
| Traefik HTTPS | **Fonctionne nativement via l'API** | **503 via l'API**, nécessite l'UI |
| Volumes | via `custom_docker_run_options` | via le compose (préfixes auto) |
| Env vars | POST individuels ou bulk | `${SERVICE_PASSWORD_*}` auto-générés |
| Multi-conteneur | Non | Oui |
| Deployments | File `/deployments` | Pas de file, statut direct |

> **Règle : Application pour un conteneur unique avec domaine HTTPS ; Service pour du
> multi-conteneur.**

## Pourquoi / Conséquences

Le point décisif est **Traefik via l'API** : pour un Service, l'API renvoie systématiquement 503
sur la config HTTPS (il faut passer par l'UI Coolify). Une Application câble Traefik + Let's
Encrypt automatiquement via l'API. Donc dès qu'on veut un domaine HTTPS scripté pour un seul
conteneur → Application. Détails et contournements Service : `cookbook/0002`.
