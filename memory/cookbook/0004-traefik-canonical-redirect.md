---
id: 0004
type: cookbook
scope: global
title: Redirect 301/308 d'aliases vers un domaine canonique (Traefik custom_labels)
tags: [traefik, redirect, canonical, seo, custom-labels, middleware, base64]
date: 2026-06-20
status: active
related: [cookbook/0001, decisions/0002]
---

## Contexte

Une app a plusieurs `fqdn` (alias) et l'on veut que **tous redirigent vers UN domaine canonique**
en préservant path + query (SEO, branding).

## Procédure

Méthode : injecter un middleware Traefik `redirectregex` dans les labels Docker via
`PATCH /applications/{uuid}`, en mettant à jour `custom_labels` (champ **base64**, blob multiligne).

1. `GET /applications/{uuid}` → récupérer `custom_labels`, **décoder base64**. On y trouve des
   routers `http-N-<uuid>` et `https-N-<uuid>` (N = index du domaine dans `fqdn`).
2. Ajouter le middleware (la regex capture le path en groupe 2) :
   ```
   traefik.http.middlewares.redirect-to-canonical.redirectregex.regex=^https?://(alias1|alias2)/(.*)$
   traefik.http.middlewares.redirect-to-canonical.redirectregex.replacement=https://canonical.tld/${2}
   traefik.http.middlewares.redirect-to-canonical.redirectregex.permanent=true
   ```
   Note : `${2}` **avec accolades** (pas `$2`) pour éviter l'interprétation shell par Coolify.
3. Routers **HTTPS** des alias : `middlewares=gzip` → `middlewares=gzip,redirect-to-canonical`.
4. Routers **HTTP** des alias : `middlewares=redirect-to-https` → `middlewares=redirect-to-canonical`
   (court-circuite l'aller-retour http→https→app→redirect).
5. Le router **canonique reste inchangé** (sert l'app normalement).
6. **Re-encoder base64**, `PATCH /applications/{uuid}` `{"custom_labels":"<base64>"}`.
7. `GET /applications/{uuid}/restart` → recreate le container avec les nouveaux labels (PAS de
   rebuild, pas de cold cache).
8. Vérif : `curl -I https://alias/path?q=v` → `308 Permanent Redirect` + `location:
   https://canonical/path?q=v`.

## Pourquoi / Conséquences

- Traefik émet **`308`** (RFC 7538) avec `permanent=true`, pas `301`. Équivalent sémantique mais
  préserve la méthode HTTP ; tous deux bien traités par Google/curl/navigateurs.
- Tester un alias avant que son DNS pointe sur le serveur :
  `curl --resolve "alias:443:<server-ip>" https://alias/`.
- Certs Let's Encrypt émis à la 1ère requête TLS réussie (donc au switch DNS si pas déjà validé
  via ACME).
