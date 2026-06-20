---
id: 0002
type: decision
scope: global
title: Mettre le domaine via PATCH "domains", jamais "fqdn" (422)
tags: [domains, fqdn, patch, application, api, 422]
date: 2026-03-26
status: active
related: [cookbook/0001, cookbook/0004]
---

## Contexte

Pour (re)définir le domaine d'une Application via l'API, on peut être tenté d'envoyer un champ
`fqdn` (c'est le nom du champ dans la réponse `GET`).

## Décision

Mettre à jour le domaine avec **`PATCH /applications/<uuid>` `{"domains":"https://…"}`**.
**Ne pas** envoyer `fqdn` en écriture → l'API rejette en **422**.

## Pourquoi / Conséquences

L'API expose la lecture sous `fqdn` mais attend `domains` en écriture (string, peut contenir
plusieurs domaines séparés). Conséquence pratique : si conflit de domaine, ajouter
`force_domain_override: true` au même PATCH (sinon 409). Voir `cookbook/0001` (déploiement) et
`cookbook/0004` (multi-domaines + redirect canonique).
