---
name: onboard-infra
description: Register and validate a brand-new Coolify infra/server (create the profile, fill infra.yaml + .env, validate the connection, seed first facts/registry). Use when the user wants to add a new Coolify server to manage.
---

# /onboard-infra — enregistrer une nouvelle infra

Faire entrer un nouveau serveur Coolify dans l'outil, de la création à la validation.

## Procédure

1. **Créer le profil** : `./scripts/infra new <nom>` (copie `_TEMPLATE/` → `infras/<nom>/`, prépare
   `.env`, met `name:` dans `infra.yaml`). Refuse d'écraser une infra existante.
2. **Guider le remplissage** (fichiers LOCAUX, gitignorés) :
   - `infras/<nom>/.env` : `COOLIFY_BASE_URL` (sans slash final) + `COOLIFY_API_TOKEN`
     (UI Coolify : *Keys & Tokens > API tokens*, scopes read/write/deploy). **Demande la valeur du
     token à l'utilisateur ; ne l'invente pas.** Le token ne va QUE dans ce `.env`.
   - `infras/<nom>/infra.yaml` : `base_url`, `proxy`, `wildcard_domain`, `coolify_version`,
     `server_uuid`, `ip`, `notes`.
3. **Valider la connexion** :
   `./scripts/coolify --infra <nom> version` puis `… health` puis `… servers`.
   - Si erreur d'auth/URL → corriger `.env` et réessayer.
   - Récupère `server_uuid` / `ip` réels depuis `… servers` et complète `infra.yaml` + `facts.md`.
4. **Définir comme active si voulu** : `./scripts/infra use <nom>` (confirme la cible).
5. **Amorcer la mémoire infra** si pertinent : remplir `facts.md` (serveur, DNS/wildcard, projets
   via `./scripts/coolify --infra <nom> projects`) et `registry.md` (ressources existantes via
   `apps`/`services`/`databases`). Crée des fiches `infra` (`/learn`) pour les particularités
   notables découvertes.

> Rappel backup : `infras/<nom>/` n'est pas versionné. Conseille de sauvegarder `.env` et
> `registry.md` ailleurs (gestionnaire de secrets / Time Machine).
