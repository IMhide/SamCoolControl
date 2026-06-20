---
id: 0005
type: cookbook
scope: global
title: Héberger une app Lovable (SSR TanStack) sur Coolify
tags: [lovable, tanstack, ssr, gitlab, dockerfile, deploy-token, supabase, build-args]
date: 2026-06-04
status: active
related: [architecture/0001, cookbook/0001, habits/0002]
---

## Contexte

Déployer une app **Lovable** (TanStack Start, **SSR**) sur Coolify, sans jamais modifier le repo
Lovable. Le **pattern** complet (pourquoi, flux, pièges de fond) est dans `architecture/0001` ;
cette fiche est la **procédure réutilisable**. Le concret d'un serveur donné (repo de déploiement,
`private_key_uuid`, tokens) vit dans `infras/<nom>/architecture/`.

## Pré-requis (one-time)

1. **Lovable → GitLab** : Settings > Git > GitLab.com, OAuth, choisir le namespace. Sync sur
   `main`. (Lovable **exporte** vers un repo neuf ; ne peut pas importer un repo existant.)
2. **Deploy key SSH** dans Coolify (Keys & Tokens → `private_key_uuid`), clé publique en Deploy Key
   sur le repo de déploiement partagé `lovable-deploy`.
3. **Supabase server-side** : les apps Lovable TanStack lisent Supabase **côté serveur** via
   `process.env.SELF_SUPABASE_URL` / `SELF_SUPABASE_ANON_KEY` (server functions `.functions.ts`),
   PAS via `VITE_*`. Donc ces vars sont **runtime**, et l'anon key ne fuit pas dans le bundle.

## Procédure (nouvelle app)

```bash
APP_NAME="mon-app"
DOMAIN="https://mon-app.example.tld"
PROJECT="<projet-coolify-lovable-apps-uuid>"

# 1. Deploy token read-only sur le repo de l'app (pour le clone pendant le build)
glab api --method POST "projects/<group%2Fproject>/deploy_tokens" \
  --field "name=coolify-build" --field "scopes=read_repository"
#   → note username (gitlab+deploy-token-NNN) et token (gldt-…)

# 2. Créer l'app Coolify depuis le repo lovable-deploy (build_pack dockerfile)
./scripts/coolify raw POST /applications/private-deploy-key "$(jq -n --arg n "$APP_NAME" --arg p "$PROJECT" '{
  name:$n, git_repository:"git@gitlab.com:<group>/lovable-deploy.git", git_branch:"main",
  project_uuid:$p, environment_name:"production", server_uuid:"<SERVER_UUID>",
  private_key_uuid:"<PRIVATE_KEY_UUID>", build_pack:"dockerfile",
  ports_exposes:"3000", instant_deploy:false }')"
#   → APP_UUID

# 3. Domaine
./scripts/coolify raw PATCH /applications/<APP_UUID> "{\"domains\":\"$DOMAIN\"}"

# 4. Build args (bulk PATCH /applications/<APP_UUID>/envs/bulk avec {data:[…]}) :
#    REPO_HOST/REPO_PATH/REPO_REF/GIT_TOKEN_USER/GIT_TOKEN → build-only (is_build_time:true,is_runtime:false)
#    SELF_SUPABASE_URL/SELF_SUPABASE_ANON_KEY               → runtime

# 5. Deploy
./scripts/coolify deploy <APP_UUID>

# 6. Auth Supabase pour le domaine (sinon redirections login cassées — voir architecture/0001)
./scripts/coolify raw PATCH /services/<supabase-uuid>/envs "{\"key\":\"GOTRUE_SITE_URL\",\"value\":\"$DOMAIN\"}"
# GOTRUE_URI_ALLOW_LIST → "$DOMAIN/**" (POST si absent, PATCH si présent)
./scripts/coolify service:restart <supabase-uuid>

# 7. Auto-deploy : var CI APP_UUID sur lovable-deploy + webhook push sur le repo de l'app →
#    https://gitlab.com/api/v4/projects/<lovable-deploy-id>/trigger/pipeline?token=<trig>&ref=main
```

## Pièges (checklist)

- **Build = Docker (lovable-deploy), PAS static/nixpacks.** Static sert un nginx vide ; nixpacks
  échoue (Node 18 EOL, `npm ci` sans lockfile car repo en **bun**).
- **Supabase = `SELF_SUPABASE_*` en RUNTIME** (`process.env`), pas `VITE_*` build-time. Vérifier
  dans `src/lib/*.functions.ts` quelles vars l'app lit réellement.
- **Secrets build-only** : `GIT_TOKEN`/`REPO_*` → `is_build_time:true, is_runtime:false` (le deploy
  token ne doit pas traîner dans le conteneur ; clone dans un stage isolé).
- **Dockerfile buildpack ne supporte pas `--secret` de façon fiable** → clone via deploy token
  HTTPS en build-arg, pas via secret SSH.
- **Webhook Coolify natif inutilisable** (il matche le repo configuré = lovable-deploy, pas l'app
  repo) → pipeline trigger GitLab.
- **GitLab bloque les trigger variables** selon le rôle → mettre `APP_UUID` en variable CI du repo
  lovable-deploy (1 app = 1 var ; multi-app = 1 repo/branche de trigger par app, ou var par trigger).
- **Lovable + Supabase self-hosted** casse les features IA backend de Lovable (migrations/edge
  functions cloud). Runtime OK. Migrations/RLS à la main.

## Pourquoi / Conséquences

Voir `architecture/0001` pour le **pourquoi** (preset Cloudflare hardcodé, patch nitro
`node_server`, Dockerfile multi-stage). Cette procédure est stable et réutilisable d'une app
Lovable à l'autre ; seuls le domaine, le projet et le deploy token changent.
