---
name: recall
description: Query the typed memory on demand and present a cited synthesis (read-only). Use when the user asks "what do we know about X", "have we done Y before", or wants to introspect the accumulated knowledge.
---

# /recall — interroger la mémoire (lecture seule)

Introspection de la mémoire à la demande. **Ne modifie rien.**

## Procédure

1. Résous l'infra active (`./scripts/infra current`) — la recherche couvre `memory/` (global) +
   `infras/<actif>/` (infra).
2. `./scripts/memory search <termes de la demande>` pour lister les fiches pertinentes (le tri met
   les matchs title/tags d'abord).
3. **Ouvre les fiches pertinentes** (et au besoin `facts.md` / `registry.md` de l'infra active pour
   le concret).
4. **Présente une synthèse citée** : réponds à la question en t'appuyant sur les fiches, et **cite**
   chacune sous la forme `type/scope/id` avec son chemin. Si plusieurs fiches se complètent
   (pattern global + concret infra), relie-les dans l'explication.
5. Si rien ne matche, dis-le clairement et propose éventuellement `/learn` si la session contient
   une matière non encore mémorisée.

> Lecture seule : si l'utilisateur veut *enregistrer* quelque chose, c'est `/learn`.
