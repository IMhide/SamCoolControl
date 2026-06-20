---
name: provision
description: Create a Coolify resource end-to-end following the right cookbook (RAG first), then record it in the infra registry and learn from it. Use when the user wants to deploy/provision a new app, service, or stack the proper way.
---

# /provision — créer une ressource proprement (RAG → exécuter → consigner → apprendre)

Provisionner une ressource Coolify en suivant le bon cookbook, puis tenir la mémoire à jour.

## Procédure

1. **RAG d'abord** : résous l'infra active (`./scripts/infra current`), lis les INDEX, puis
   `./scripts/memory search <ce qu'on provisionne>`. Ouvre la/les fiche(s) `cookbook` pertinentes
   (ex. `cookbook/global/0001` image Docker HTTPS ; `cookbook/global/0002` service compose ;
   `cookbook/global/0005` app Lovable). **`Read API_REFERENCE.md`** pour les params exacts.
2. **Confirme l'infra cible** (nom + base_url depuis `infra.yaml`) — c'est une opération d'écriture.
   Jamais sur une infra ambiguë.
3. **Exécute le workflow** du cookbook, en appliquant les habits maison :
   - `instant_deploy:false`, puis domaine/volumes/envs, puis start (`habits/global/0002`).
   - domaine via PATCH `domains` (`decisions/global/0002`) ; Application vs Service
     (`decisions/global/0001`) ; bodies JSON avec `jq` (`habits/global/0001`).
   - Vérifie le résultat (status + `curl` du domaine si HTTPS).
4. **Consigne la ressource** dans `infras/<actif>/registry.md` : name, uuid, projet, domaine, ports,
   volumes, date — et tout credential associé (local uniquement).
5. **Apprends** (Option B) : si une décision a été tranchée, une archi figée, ou un piège rencontré
   → déclenche `/learn` (auto) et montre le récap. Sinon, si c'est juste probable → suggère `/learn`.

> Pour une ressource qui suit un pattern particulier (ex. Lovable SSR), commence par
> `architecture/INDEX.md` (global + infra) avant de provisionner — le concret (repo de build,
> `private_key_uuid`, deploy tokens) est dans `infras/<actif>/architecture/`.
