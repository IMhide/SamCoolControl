# Coolify Control

> **Un agent d'ops Coolify multi-infra, à mémoire typée (RAG fichiers).**
> Pilote un ou plusieurs serveurs [Coolify](https://coolify.io) (PaaS auto-hébergé) depuis le
> terminal **et** depuis Claude Code, avec une mémoire persistante qui apprend au fil des
> déploiements.

Ce projet est davantage qu'un wrapper d'API : c'est une petite **plateforme agentique**. Elle
combine des scripts CLI, une **mémoire typée** lue automatiquement avant chaque réponse (RAG sur
fichiers Markdown, sans embeddings), un **agent** Claude Code dédié, des **skills**, et une boucle
d'apprentissage **`/learn`** qui capitalise décisions, recettes et incidents.

---

## ✨ En bref

- **Multi-infra** — chaque serveur Coolify est un « profil » (`infras/<nom>/`). On cible une infra
  avec `--infra <nom>`, l'agent confirme la cible avant toute écriture.
- **Mémoire typée 5 × 2** — 5 types de savoir (decisions, architecture, habits, cookbook,
  incidents) × 2 portées (global réutilisable / spécifique à un serveur).
- **RAG fichiers** — des `INDEX.md` légers + un moteur de recherche (`scripts/memory search`) ;
  100 % fichiers Markdown, lisibles et versionnables.
- **`/learn` quasi-autonome** — l'agent classe et écrit le savoir lui-même, avec un récap
  corrigeable. Zéro friction.
- **Secrets jamais versionnés** — tout ce qui est spécifique à un serveur (creds, UUIDs) reste
  **local** (gitignoré) ; seul le savoir universel est commité.

---

## 🚀 Quickstart

```bash
# 1. Dépendances (macOS)
brew install jq        # curl + bash sont déjà sur macOS (voir § Dépendances)

# 2. Enregistrer votre premier serveur Coolify comme infra
./scripts/infra new monserveur
#   → édite infras/monserveur/.env        (COOLIFY_BASE_URL + COOLIFY_API_TOKEN)
#   → édite infras/monserveur/infra.yaml  (base_url, server_uuid, ip, wildcard…)

# 3. L'activer et valider la connexion
./scripts/infra use monserveur
./scripts/coolify --infra monserveur version
./scripts/coolify --infra monserveur servers

# 4. Tableau de bord
./scripts/coolify status
```

Le **token API** se génère depuis l'UI Coolify : **Keys & Tokens > API tokens** (scopes `read`,
`write`, `deploy`).

> Astuce : sans profil configuré, l'outil retombe sur un `.env` à la racine (mode mono-serveur
> historique) — voir `.env.example`.

---

## 🧠 La mémoire typée (le cœur du projet)

Le savoir vit en **fiches atomiques** Markdown avec frontmatter, organisées en **5 types × 2
portées** :

| Type | Quoi | Exemple |
|------|------|---------|
| **decisions** | un choix + son *pourquoi* | « Application plutôt que Service : Traefik 503 via l'API » |
| **architecture** | comment des composants sont câblés | flux Lovable → GitLab → Coolify → Supabase |
| **habits** | une convention répétée | « `instant_deploy:false`, vérifier les envs, puis démarrer » |
| **cookbook** | une procédure rejouable | « déployer une image Docker en HTTPS » |
| **incidents** | ce qui a cassé + le fix | « Supabase degraded → restart » |

…et **2 portées** :

- **GLOBAL** (`memory/`) — vrai pour *tout* Coolify, **sans secret** → **versionné**.
- **INFRA** (`infras/<nom>/`) — spécifique à un serveur (UUIDs, domaines, creds) → **local,
  gitignoré**.

> **Règle de portée** : un UUID / IP / domaine / credential → portée `infra`. Sinon → `global`.
> Un même savoir peut donner *deux* fiches (le pattern en global, le concret en infra), reliées.

Chaque dossier a un **`INDEX.md`** (tableau résumé) qui sert de **couche RAG légère** : l'agent le
lit en premier pour décider quelles fiches ouvrir. Détails complets : **[`memory/README.md`](memory/README.md)**.

### Comment l'agent lit (RAG)

1. Résout l'infra active → 2. lit les `INDEX.md` (+ `facts.md`/`registry.md`) →
3. `scripts/memory search <termes>` → 4. ouvre seulement les fiches pertinentes →
5. répond en **citant** les fiches (`type/scope/id`).

### La boucle `/learn` (3 voies)

| Voie | Qui | Quand |
|------|-----|-------|
| **① AUTO** | l'agent, seul | décision tranchée / archi figée / incident résolu → écrit la fiche + récap 1 ligne corrigeable |
| **② RAPPEL** | l'agent | matière probable mais ambiguë → `💡 /learn pour acter ça ?` (n'écrit pas) |
| **③ MANUEL** | vous | `/learn` quand vous le décidez |

> *La mémoire est une responsabilité partagée : l'agent déclenche `/learn` quand l'apprentissage
> est net et le suggère quand il est probable, mais le `/learn` manuel reste à votre main.*

---

## 🗂️ Multi-infra (profils)

Une **infra** = un serveur Coolify = un dossier local `infras/<nom>/` :

```
infras/<nom>/
├── infra.yaml     # identité : base_url, proxy, wildcard, server_uuid, ip, version
├── .env           # COOLIFY_BASE_URL + COOLIFY_API_TOKEN  (SECRET, local)
├── facts.md       # serveur, DNS, projets
├── registry.md    # inventaire des ressources (+ creds, local)
└── {decisions,architecture,habits,cookbook,incidents}/   # mémoire infra
```

L'**infra active** est résolue dans l'ordre : `COOLIFY_PROFILE` (env) → `infras/.current`
(fichier) → `.env` racine (fallback).

```bash
./scripts/infra list            # lister les infras (marque l'active)
./scripts/infra current         # afficher l'active
./scripts/infra use <nom>       # changer l'active
./scripts/infra show <nom>      # infra.yaml + résumé facts/registry
./scripts/infra new <nom>       # créer depuis le squelette _TEMPLATE/

# cibler ponctuellement une infra (sans changer l'active)
./scripts/coolify --infra <nom> <commande>
```

> ⚠️ **Sécurité & backup** : tout `infras/<nom>/` est **gitignoré** (secrets + savoir serveur). git
> ne le sauvegarde donc pas → **sauvegardez-le ailleurs** (gestionnaire de secrets, Time Machine).
> Voir [`infras/README.md`](infras/README.md).

---

## 🧰 Scripts

| Script | Rôle |
|--------|------|
| `scripts/coolify` | CLI haut niveau (lecture, lifecycle, `raw`). Flag global `--infra <nom>`. |
| `scripts/coolify-api.sh` | Wrapper bas niveau de l'API (résout le profil, charge le bon `.env`). |
| `scripts/infra` | Gérer les profils d'infra (`list`/`current`/`use`/`show`/`new`). |
| `scripts/memory` | Moteur RAG : `search` / `new` / `reindex`. |

### Exemples CLI

```bash
# Lecture
./scripts/coolify status
./scripts/coolify --infra baijobu servers
./scripts/coolify apps
./scripts/coolify app <uuid>

# Lifecycle / déploiement (l'agent confirme la cible avant ces écritures)
./scripts/coolify deploy <uuid>
./scripts/coolify app:restart <uuid>

# API brute (bodies JSON construits avec jq)
./scripts/coolify raw GET /servers
./scripts/coolify raw POST /applications/dockerimage "$(jq -n '{name:"x", server_uuid:"...", ports_exposes:"80"}')"

# Mémoire
./scripts/memory search traefik
./scripts/memory new decision global "Titre de la décision"
./scripts/memory reindex
```

Source de vérité des paramètres d'API : **[`API_REFERENCE.md`](API_REFERENCE.md)**.

### Utiliser le wrapper dans vos propres scripts

```bash
source scripts/coolify-api.sh
coolify_api GET /servers
coolify_api POST /projects '{"name":"new-project"}'
```

---

## 🤖 Intégration Claude Code

- **Agent** : [`.claude/agents/coolify-ops.md`](.claude/agents/coolify-ops.md) — applique le
  protocole RAG, le routage multi-infra avec confirmation, la boucle `/learn`, et les règles de
  sécurité.
- **Skills** (`.claude/skills/`) — source unique des commandes :

| Skill | Description |
|-------|-------------|
| `/status` `/servers` `/apps` | Vues d'ensemble |
| `/inspect` | Inspecter une ressource en détail |
| `/deploy` `/manage` | Déployer / start-stop-restart |
| `/envs` | Variables d'environnement |
| `/create-app` `/create-db` `/provision` | Créer des ressources (RAG d'abord) |
| `/api` | Appel API brut |
| `/learn` `/recall` | Mémoriser / interroger la mémoire |
| `/infra-switch` `/onboard-infra` | Gérer / enregistrer des infras |

---

## 📦 Dépendances

Les scripts sont en **Bash** et s'appuient sur des outils Unix standard. Sur macOS, tout est présent
nativement sauf `jq` (et les outils *optionnels*).

### Requises

| Outil | Pourquoi | macOS |
|-------|----------|-------|
| **bash ≥ 3.2** | langage des scripts (compatibles avec le `/bin/bash` 3.2 d'Apple — pas besoin d'upgrade) | natif |
| **curl** | appels HTTP à l'API Coolify | natif |
| **jq** | construire/lire les bodies & réponses JSON | `brew install jq` |
| **coreutils de base** : `sed` `awk` `tr` `grep` `head` `sort` `find` `cat` `cp` `mv` `mkdir` `date` | manipulation de fichiers & parsing du frontmatter | natifs |
| **iconv** | translittération ASCII pour *slugifier* les titres de fiches (`memory new`) | natif |
| **base64** | encoder un `docker-compose.yml` pour l'API (cookbook services) | natif |

> Les scripts ont été **testés sous `bash` 3.2.57** (le bash système macOS) : aucune construction
> bash 4+ (`declare -A`, `mapfile`, `${x,,}`) n'est utilisée.

### Optionnelles

| Outil | Pourquoi | macOS |
|-------|----------|-------|
| **glab** (GitLab CLI) | créer des *deploy tokens* read-only lors du déploiement d'apps Lovable | `brew install glab` |
| **terminal-notifier** + **afplay** | notifications de fin de tâche Claude Code (hook `notif.sh`) ; `afplay` est natif | `brew install terminal-notifier` |

Installation groupée des paquets non natifs :

```bash
brew install jq glab terminal-notifier
```

---

## 🔐 Sécurité

- **Secrets uniquement en local** : tokens API, clés S3, clés Supabase, deploy tokens → seulement
  dans `infras/<nom>/` (gitignoré). **Jamais** dans `memory/`, `docs/`, `CLAUDE.md`, ni dans un
  message susceptible d'être loggé.
- Le `.gitignore` garantit que `infras/*` (sauf `README.md` et `_TEMPLATE/`), `COOKBOOK.md` et tous
  les `.env` ne sont jamais commités.
- **Ne jamais** exposer une clé `SERVICE_ROLE` (ou équivalent admin) côté frontend.
- Les opérations destructrices (`DELETE`, `stop`, écrasement de config) sont confirmées par l'agent
  avant exécution (avec rappel de l'infra cible).

---

## 🗺️ Arborescence

```
coolify_control/
├── README.md                  # ce fichier
├── CLAUDE.md                  # guide pour Claude Code
├── API_REFERENCE.md           # doc API exhaustive (source de vérité des params)
│
├── memory/                    # mémoire GLOBALE (versionnée)
│   ├── README.md
│   └── {decisions,architecture,habits,cookbook,incidents}/  # INDEX.md + fiches
│
├── infras/                    # mémoire PAR INFRA (local sauf README + _TEMPLATE)
│   ├── README.md
│   ├── _TEMPLATE/             # squelette d'une nouvelle infra
│   └── <nom>/                 # une infra (gitignorée)
│
├── scripts/
│   ├── coolify  coolify-api.sh
│   └── infra  memory          # multi-infra + moteur RAG
│
└── .claude/
    ├── agents/coolify-ops.md
    └── skills/                # 15 skills
```

---

## 📚 Pour aller plus loin

- **[`memory/README.md`](memory/README.md)** — format des fiches, types, portées, RAG, `/learn`.
- **[`infras/README.md`](infras/README.md)** — profils d'infra, backup, création.
- **[`API_REFERENCE.md`](API_REFERENCE.md)** — tous les endpoints et paramètres de l'API Coolify.
- **[`CLAUDE.md`](CLAUDE.md)** — comportement attendu de l'assistant.
