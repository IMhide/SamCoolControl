---
id: 0002
type: habit
scope: global
title: instant_deploy:false, vérifier les envs, puis démarrer
tags: [instant-deploy, envs, workflow, deploy, safety]
date: 2026-06-20
status: active
related: [cookbook/0001, cookbook/0002, cookbook/0005]
---

## Contexte

Les endpoints de création (`/applications/*`, `/services`) acceptent `instant_deploy:true` pour
déployer dans la foulée. Mais la ressource n'a alors ni domaine, ni volumes, ni env vars corrects
au premier boot.

## Règle

> **Créer avec `instant_deploy:false`**, configurer (domaine, volumes, env vars), **vérifier les
> envs**, **puis** démarrer/déployer explicitement (`app:start` / `service:start` / `deploy`).

## Pourquoi / Conséquences

Déployer avant d'avoir posé les env vars et le domaine produit un premier déploiement raté (ou un
conteneur mal configuré) qu'il faut de toute façon refaire. Séparer création et démarrage rend
chaque étape vérifiable et évite les faux départs. S'applique aux Applications, aux Services, et
au pattern Lovable (`cookbook/0005`).
