# Coolify Control - Claude Code Guide

## Project Overview

Ce projet est une **plateforme agentique multi-infra** pour piloter des serveurs **Coolify**
(PaaS auto-hébergé, type Heroku/Vercel) via leur API REST. Il combine :
- des **scripts CLI** (`scripts/coolify`, `scripts/infra`, `scripts/memory`) ;
- une **mémoire typée** lue en RAG avant chaque réponse (`memory/` + `infras/<nom>/`) ;
- un **agent** (`.claude/agents/coolify-ops.md`) et des **skills** (`.claude/skills/`) ;
- une boucle d'apprentissage **`/learn`** qui capitalise le savoir au fil de l'eau.

## IMPORTANT: Read API_REFERENCE.md

**Before any Coolify operation, you MUST read `API_REFERENCE.md` at the project root.** It contains
the exhaustive API documentation: every endpoint, every parameter (name, type, required/optional,
defaults), request/response schemas, and multi-step workflow recipes. This is your source of truth
for building API calls.

Always `Read API_REFERENCE.md` at the start of a conversation that involves Coolify operations.

## Multi-infra (profils)

Une **infra** = un serveur Coolify, représenté par un dossier **local** `infras/<nom>/`
(`.env`, `infra.yaml`, `facts.md`, `registry.md`, mémoire spécifique). Voir `infras/README.md`.

- **Infra active** résolue dans cet ordre : `COOLIFY_PROFILE` (env) → `infras/.current` (fichier)
  → fallback `.env` racine (rétrocompat mono-serveur).
- **Cibler une infra** pour un appel : `./scripts/coolify --infra <nom> <commande>`.
- **Gérer les profils** : `./scripts/infra list | current | use <nom> | show <nom> | new <nom>`.
- **CONFIRMER la cible avant toute écriture/déploiement/suppression** : annoncer le nom de l'infra
  + son `base_url` et obtenir un go. Jamais d'écriture sur une infra ambiguë.
- `infras/` est **gitignoré** (secrets + savoir serveur), sauf `infras/README.md` et
  `infras/_TEMPLATE/`. **À sauvegarder hors git** (voir l'avertissement backup dans le README).

Infra #1 : **baijobu** (`https://control.baijobu.net`, wildcard `*.baijobu.net`).

## Mémoire typée + RAG

Le savoir vit en **fiches atomiques typées**, en **5 types × 2 portées** :

| Type | Quoi | GLOBAL (`memory/`) | INFRA (`infras/<nom>/`) |
|------|------|--------------------|--------------------------|
| **decisions** | choix + pourquoi | `memory/decisions/` | `infras/<nom>/decisions/` |
| **architecture** | câblage de composants | `memory/architecture/` | `infras/<nom>/architecture/` |
| **habits** | convention répétée | `memory/habits/` | `infras/<nom>/habits/` |
| **cookbook** | procédure rejouable | `memory/cookbook/` | `infras/<nom>/cookbook/` |
| **incidents** | casse + fix | `memory/incidents/` | `infras/<nom>/incidents/` |

- **Portée** : présence d'un **UUID/IP/domaine/credential** → `infra:<nom>` ; sinon → `global`.
  **Secrets : jamais dans `memory/` (versionné)** ; uniquement dans `infras/<nom>/` (local).
- Chaque dossier a un **`INDEX.md`** (tableau résumé) = couche RAG légère lue en premier.
- Détail du format et du fonctionnement : **`memory/README.md`**.

**Protocole RAG (avant de répondre à toute tâche Coolify)** :
1. Résoudre l'infra active (`./scripts/infra current`).
2. Lire les INDEX légers (`memory/*/INDEX.md` + `infras/<actif>/*/INDEX.md` + `facts.md` + `registry.md`).
3. Cibler avec `./scripts/memory search <termes>`.
4. Ouvrir **uniquement** les fiches pertinentes.
5. Répondre en **citant** les fiches utilisées (`type/scope/id`).

## Boucle `/learn` (mémoire = responsabilité partagée)

`/learn` enrichit la mémoire. **3 voies** :
- **① AUTO (agent)** — décision tranchée / archi figée / incident résolu avec fix → l'agent écrit la
  fiche **seul** et signale en 1 ligne corrigeable (`🧠 mémorisé : decision/global/0007 — …`).
- **② RAPPEL (agent)** — matière probable mais ambiguë → ligne discrète `💡 /learn pour acter ça ?`
  (n'écrit pas).
- **③ MANUEL (user)** — l'utilisateur lance `/learn` quand il le décide.

> La mémoire est une responsabilité partagée : l'agent déclenche `/learn` quand l'apprentissage est
> net et le suggère quand il est probable, mais `/learn` manuel reste à la main de l'utilisateur.
> Le récap est toujours corrigeable a posteriori.

## Scripts

- `scripts/coolify` — CLI haut niveau (lecture, lifecycle, `raw`). Flag global `--infra <nom>`.
- `scripts/coolify-api.sh` — wrapper bas niveau de l'API (résout le profil + charge le bon `.env`).
- `scripts/infra` — gérer les profils d'infra (`list`/`current`/`use`/`show`/`new`).
- `scripts/memory` — moteur RAG (`search`/`new`/`reindex`).

### CLI usage

```bash
./scripts/coolify status                    # Dashboard (de l'infra active)
./scripts/coolify --infra baijobu servers   # Cibler une infra
./scripts/coolify deploy <uuid>             # Déployer
./scripts/coolify raw GET /path             # Appel API brut
./scripts/infra list                        # Lister les infras
./scripts/memory search traefik             # Chercher dans la mémoire
```

### Using the API wrapper in scripts

```bash
source scripts/coolify-api.sh
coolify_api GET /servers
coolify_api POST /applications '{"name":"my-app"}'
```

## How to assist the user with Coolify operations

1. **Run the RAG protocol** (résoudre l'infra active, lire les INDEX, `scripts/memory search`).
2. **`Read API_REFERENCE.md`** pour l'endpoint, les paramètres et le workflow exacts.
3. Utiliser `./scripts/coolify` pour les opérations simples ;
   `./scripts/coolify [--infra <nom>] raw <METHOD> <PATH> '<JSON>'` pour create/update/delete.
4. **Confirmer l'infra cible** avant toute écriture. Enchaîner les appels pour les workflows
   complexes (cf. cookbook + "Common Multi-Step Workflows" de `API_REFERENCE.md`).
5. **Consigner** les ressources créées dans `infras/<actif>/registry.md` et **`/learn`** ce qui
   mérite de l'être.

### Complex operations (use raw API)

```bash
# Créer une base PostgreSQL
./scripts/coolify raw POST /databases/postgresql '{"server_uuid":"...","project_uuid":"...","environment_name":"production","name":"my-db","instant_deploy":true}'

# Créer une app depuis une image Docker
./scripts/coolify raw POST /applications/dockerimage '{"server_uuid":"...","project_uuid":"...","environment_name":"production","name":"my-app","docker_registry_image_name":"nginx","ports_exposes":"80","instant_deploy":true}'

# Bulk set env vars
./scripts/coolify raw PATCH /applications/{uuid}/envs/bulk '[{"key":"K1","value":"V1"},{"key":"K2","value":"V2"}]'

# Mettre à jour la config d'une app (domaine via "domains", pas "fqdn")
./scripts/coolify raw PATCH /applications/{uuid} '{"domains":"https://new.example.com"}'
```

### Key patterns

- Bodies JSON construits avec **`jq`** (`Content-Type: application/json`).
- Préférer `instant_deploy:false` puis configurer puis démarrer.
- UUIDs renvoyés dans les réponses de création.
- `force_domain_override:true` pour contourner un 409 de conflit de domaine.
- Domaine via PATCH **`domains`** (pas `fqdn` → 422).
- Application pour un conteneur unique HTTPS ; Service pour du multi-conteneur.
- (Tous ces patterns sont aussi des fiches mémoire : `./scripts/memory search …`.)

## Agent

L'agent **`coolify-ops`** (`.claude/agents/coolify-ops.md`) encapsule tout ce fonctionnement :
RAG avant de répondre, routage multi-infra avec confirmation, boucle `/learn` (Option B), règles de
tri de la mémoire, et règles de sécurité (secrets locaux uniquement).

## Skills

Les skills (`.claude/skills/`) sont la **source unique** des commandes (l'ancien `.claude/commands/`
a été supprimé) :

| Skill | Description |
|-------|-------------|
| `/status` | Dashboard de l'infra active |
| `/servers` | Lister les serveurs |
| `/apps` | Lister les applications |
| `/deploy` | Déployer une application |
| `/inspect` | Inspecter une ressource en détail |
| `/manage` | start/stop/restart d'une ressource |
| `/envs` | Gérer les variables d'environnement |
| `/create-app` | Assistant de création d'application |
| `/create-db` | Assistant de création de base de données |
| `/api` | Appel API brut |
| `/learn` | Mémoriser un savoir (auto-classé, récap corrigeable) |
| `/recall` | Interroger la mémoire (lecture seule, synthèse citée) |
| `/infra-switch` | Lister / voir / changer l'infra active |
| `/onboard-infra` | Enregistrer & valider une nouvelle infra |
| `/provision` | Créer une ressource proprement (RAG → exécuter → consigner → learn) |

## Dépendances

Voir la section **Dépendances** du `README.md` (curl, jq, bash 4+, coreutils, iconv, et
optionnellement `glab`, `terminal-notifier`).
