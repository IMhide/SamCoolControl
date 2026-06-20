---
id: 0001
type: architecture
scope: global
title: Pattern de déploiement d'une app Lovable SSR (TanStack) via repo de build dédié
tags: [lovable, tanstack, ssr, nitro, cloudflare-worker, dockerfile, gitlab, supabase, patch-nitro]
date: 2026-06-04
status: active
related: [cookbook/0005]
---

## Contexte

Les apps **Lovable récentes** sont des apps **TanStack Start (SSR)**, PAS des SPA statiques. Elles
buildent par défaut vers un **Cloudflare Worker** (`@lovable.dev/vite-tanstack-config` hardcode le
preset `cloudflare`). Conséquences :

- `dist/server/server.js` est un bundle **Worker**, pas un serveur Node → `node dist/server/server.js`
  part en crash-loop.
- `build_pack: static` sert un nginx vide (le build SSR ne produit pas d'`index.html`).
- `NITRO_PRESET=node_server` passé en env est **ignoré** par le plugin.

Et il ne faut **jamais modifier le repo Lovable** (sync bidirectionnel : toute modif serait écrasée
ou polluerait l'app). On adapte donc le **build**, pas l'app.

## Montage

**Un repo de déploiement partagé** (`lovable-deploy`) avec un **Dockerfile multi-stage** qui :

1. clone le repo Lovable **non modifié** via un **deploy token GitLab read-only** (HTTPS) ;
2. injecte **transitoirement** `nitro: { preset: "node_server" }` dans une *copie conteneur* de
   `vite.config.ts` (script `patch-nitro.mjs`) ;
3. `bun run build` → produit un vrai serveur Node **`dist/server/index.mjs`** ;
4. runtime `node:20-slim` : `node dist/server/index.mjs` (SSR sur le port 3000).

Flux complet :

```
Lovable --(sync GitLab)--> app repo (intact)
                               │  (webhook push)
                               ▼
        GitLab pipeline trigger (repo lovable-deploy) --> Coolify API /deploy
                               │
Coolify build (Dockerfile depuis lovable-deploy):
   clone app repo (deploy token) -> patch nitro node_server -> bun build -> dist/server/index.mjs
   -> conteneur Node SSR (:3000) -- process.env.SELF_SUPABASE_* --> Supabase Kong self-hosted
```

Supabase est lu **côté serveur** (`process.env.SELF_SUPABASE_URL` / `SELF_SUPABASE_ANON_KEY`, dans
les server functions `.functions.ts`), donc en **runtime** — l'anon key ne fuit pas dans le bundle
client. L'auth (GoTrue) doit connaître le domaine de l'app (`GOTRUE_SITE_URL` /
`GOTRUE_URI_ALLOW_LIST`) sinon les redirections login cassent.

## Pourquoi / Conséquences

Ce montage découple « ce que Lovable génère » de « ce que Coolify exécute » sans toucher au repo
source. Il est **réutilisable** pour toutes les apps Lovable : seuls le domaine, le projet Coolify
et le deploy token changent (procédure pas-à-pas : `cookbook/0005`). Le **concret** d'un serveur
donné (URL du repo `lovable-deploy`, `private_key_uuid`, IDs de pipeline) est consigné par infra
dans `infras/<nom>/architecture/`.

Limites : Lovable + Supabase self-hosted casse les features IA backend de Lovable (migrations/edge
functions cloud) ; le runtime fonctionne, mais migrations/RLS se font à la main.
