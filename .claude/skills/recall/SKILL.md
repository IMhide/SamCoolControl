---
name: recall
description: Query the typed memory on demand and present a cited synthesis (read-only). Use when the user asks "what do we know about X", "have we done Y before", or wants to introspect the accumulated knowledge.
---

# /recall — interroger la mémoire (lecture seule)

Introspection de la mémoire à la demande. **Ne modifie rien.** C'est le **cas d'école du
`memory-retriever`** : ratisser large en lecture, rendre une synthèse citée compacte.

## Procédure

1. **Délègue au subagent `memory-retriever`** (`.claude/agents/memory-retriever.md`, lecture
   seule) : passe-lui la question de l'utilisateur (et l'infra active si tu la connais déjà). Il
   exécute le protocole RAG complet — résoudre l'infra → INDEX → `./scripts/memory search` →
   ouvrir les fiches pertinentes (+ `facts.md` / `registry.md` au besoin) — et **absorbe le bruit**.
2. **Restitue sa synthèse** à l'utilisateur : la réponse adossée aux fiches, chacune citée sous la
   forme `type/scope/id` avec son chemin ; patterns global + concret infra reliés. S'il n'a rien
   trouvé, dis-le et propose `/learn` si la session contient une matière non mémorisée.

> Le contexte principal ne reçoit que la synthèse (pas les fiches brutes) → on reste léger.
> Pour une **micro-question** triviale (réponse dans 1 fiche évidente), un `./scripts/memory
> search` inline suffit — inutile de déléguer.
>
> Lecture seule : si l'utilisateur veut *enregistrer* quelque chose, c'est `/learn`.
