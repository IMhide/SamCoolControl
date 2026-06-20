# Mémoire typée — `memory/` (GLOBAL, versionné)

Ce dossier est la **mémoire à long terme** de l'agent Coolify. Elle remplace l'ancien
`COOKBOOK.md` mono-fichier par des **fiches atomiques typées**, indexées, lisibles par
l'agent (RAG) et alimentées par la boucle `/learn`.

La mémoire a **2 portées** :

- **GLOBAL** — ici, dans `memory/` : savoir **universel Coolify** (vrai sur n'importe quel
  serveur), **sans aucun secret ni UUID/IP/domaine concret**. Versionné dans git.
- **INFRA** — dans `infras/<nom>/` : savoir **spécifique à un serveur** (UUID, IP, domaines,
  creds, ressources déployées). **100 % local, gitignoré.** Voir `infras/README.md`.

---

## Les 5 types

| Type | C'est quoi | Exemple |
|------|-----------|---------|
| **decisions** | Un choix + son **POURQUOI**. | « Application plutôt que Service, car Traefik renvoie 503 via l'API pour les services. » |
| **architecture** | Comment des composants sont **câblés** ensemble. | Le flux Lovable → GitLab → Coolify → Supabase (pattern SSR). |
| **habits** | Une **convention** répétée, une façon de faire. | « Toujours `instant_deploy:false` puis vérifier les envs avant de démarrer. » |
| **cookbook** | Une **procédure rejouable** pas-à-pas. | « Déployer une image Docker en HTTPS via Traefik. » |
| **incidents** | Ce qui a **cassé** + pourquoi + le **fix**. | « Supabase `degraded:unhealthy` le 2026-06-04 → restart. » |

Chaque type a son sous-dossier (`decisions/`, `architecture/`, `habits/`, `cookbook/`,
`incidents/`), avec un `INDEX.md` et N fiches `NNNN-slug.md`.

---

## Règle de PORTÉE (global vs infra)

> **Présence d'un UUID / IP / domaine précis / credential → `scope: infra:<nom>`**
> (la fiche va dans `infras/<nom>/<type>/`).
> **Sinon, vrai pour tout Coolify → `scope: global`** (la fiche va dans `memory/<type>/`).

Un même savoir peut donner DEUX fiches : le **pattern générique** en global, le **concret**
(UUIDs, tokens) en infra, reliés par `related:`.

> **Secrets : JAMAIS dans `memory/`** (versionné). Clés, tokens, mots de passe → uniquement
> dans `infras/<nom>/` (local, gitignoré).

---

## Anatomie d'une fiche `NNNN-slug.md`

```markdown
---
id: 0001
type: decision            # decision | architecture | habit | cookbook | incident
scope: global             # global | infra:<nom>
title: <titre clair>
tags: [tag1, tag2, tag3]
date: YYYY-MM-DD
status: active            # active | superseded | deprecated
related: [cookbook/0001, architecture/0001]
---

## Contexte
…
## <Décision | Montage | Règle | Procédure | Incident & Fix>
…
## Pourquoi / Conséquences
…
```

- **id** : 4 chiffres, incrémenté **par type + portée** (chaque dossier a sa propre séquence).
- **Nom de fichier** : `NNNN-slug-kebab.md` (le slug reprend le titre).
- **related** : liens vers d'autres fiches sous la forme `type/id` (ex. `cookbook/0001`).

---

## Le rôle des `INDEX.md` (couche RAG légère)

Chaque dossier a un `INDEX.md` : un **tableau résumé** (id, titre, tags, date, status) de
toutes ses fiches. C'est la **première chose que l'agent lit** — léger, il tient en un coup
d'œil et permet de décider quelles fiches ouvrir **sans tout charger**.

Les INDEX sont maintenus automatiquement :
- `scripts/memory new …` ajoute la ligne au bon INDEX à la création.
- `scripts/memory reindex` reconstruit les INDEX depuis les frontmatters (resync après édition
  manuelle ; idempotent).

---

## Comment l'agent LIT la mémoire (RAG)

Avant de répondre à une tâche Coolify, l'agent :

1. Résout l'infra active (`scripts/infra current`).
2. Lit les **INDEX légers** : `memory/*/INDEX.md` + `infras/<actif>/*/INDEX.md` (+ `facts.md`,
   `registry.md` de l'infra).
3. Cible avec `scripts/memory search <termes de la demande>`.
4. Ouvre **uniquement** les fiches pertinentes.
5. Répond en s'appuyant dessus et **cite** les fiches utilisées (`type/scope/id`).

## Comment l'agent ÉCRIT dans la mémoire (`/learn`)

La skill `/learn` (et l'agent, en mode auto — voir décision #10 du plan) :
1. Identifie un apprentissage et le **classe seul** (type + portée, via les règles ci-dessus).
2. `scripts/memory new <type> <scope> <title>` crée la fiche + met à jour l'INDEX.
3. Remplit le corps, pose les `related:`.
4. Affiche un **récap 1-ligne corrigeable** par fiche.

Voir `.claude/skills/learn/SKILL.md` et `.claude/agents/coolify-ops.md`.
