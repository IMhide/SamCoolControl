# `infras/` — mémoire & config PAR INFRA (100 % LOCAL)

Une **infra** = un serveur (ou un cluster) Coolify que cet outil pilote. Chaque infra est un
**dossier local** sous `infras/<nom>/` qui contient sa configuration (`.env`, `infra.yaml`),
ses faits (`facts.md`), son inventaire de ressources (`registry.md`) et sa **mémoire typée
spécifique** (les 5 types, portée `infra:<nom>`).

```
infras/
├── README.md          ← versionné (ce fichier)
├── _TEMPLATE/         ← versionné (squelette à copier pour une nouvelle infra)
├── .current           ← LOCAL — nom du profil actif (ex: "baijobu")
└── <nom>/             ← LOCAL — une infra
    ├── infra.yaml     ← identité (base_url, proxy, wildcard, server_uuid, ip, version…)
    ├── .env           ← COOLIFY_BASE_URL + COOLIFY_API_TOKEN (SECRET)
    ├── facts.md       ← serveur, réseau/DNS, projets, divers
    ├── registry.md    ← inventaire : applications / databases / services (UUIDs, ports, creds)
    └── {decisions,architecture,habits,cookbook,incidents}/   ← mémoire infra (INDEX.md + fiches)
```

---

## ⚠️ AVERTISSEMENT BACKUP (à lire absolument)

**Tout ce qui est sous `infras/` est gitignoré** (sauf ce README et `_TEMPLATE/`). Ces dossiers
contiennent des **secrets** (tokens API, clés S3, clés Supabase, deploy tokens) et du **savoir
serveur** qui n'existe **nulle part ailleurs** une fois `COOKBOOK.md` migré.

> **git ne les sauvegarde PAS.** Si tu perds ce disque, tu perds cette mémoire et ces creds.
> **Sauvegarde `infras/` par un autre moyen** : Time Machine, un coffre de secrets (1Password,
> Bitwarden), ou une copie chiffrée hors-ligne. Les tokens API restent régénérables depuis
> l'UI Coolify, mais le savoir accumulé (registry, incidents, archi concrète), non.

---

## Le profil actif

L'infra « active » est résolue dans cet ordre par les scripts :

1. La variable d'environnement `COOLIFY_PROFILE` (ex. posée par `coolify --infra <nom>`).
2. Le fichier `infras/.current` (posé par `scripts/infra use <nom>`).
3. Sinon, **fallback** sur le `.env` à la racine du projet (rétrocompat mono-serveur).

Cibler ponctuellement une infra sans changer l'actif :
```bash
./scripts/coolify --infra <nom> servers
COOLIFY_PROFILE=<nom> ./scripts/coolify status
```

---

## Créer une nouvelle infra

**Méthode recommandée** (script) :
```bash
./scripts/infra new <nom>      # copie _TEMPLATE/ → infras/<nom>/, prépare .env
# puis éditer infras/<nom>/.env (COOLIFY_BASE_URL + COOLIFY_API_TOKEN)
#       et   infras/<nom>/infra.yaml (base_url, server_uuid, ip, wildcard…)
./scripts/infra use <nom>      # définir comme actif
./scripts/coolify --infra <nom> version   # valider la connexion
```

**Méthode manuelle** : copier `_TEMPLATE/` vers `infras/<nom>/`, renommer `.env.example` → `.env`,
remplir les valeurs.

La skill `/onboard-infra` guide ce processus de bout en bout (création, remplissage, validation,
premières fiches `facts`/`registry`).

---

## Commandes utiles

```bash
./scripts/infra list           # liste les infras (marque l'active)
./scripts/infra current        # affiche l'infra active
./scripts/infra use <nom>      # change l'infra active
./scripts/infra show <nom>     # infra.yaml + résumé facts/registry
```
