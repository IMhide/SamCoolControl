---
name: learn
description: Capture what was just learned into the typed memory (decisions/architecture/habits/cookbook/incidents), classifying it autonomously and showing a correctable recap. Use when a decision was made, an architecture was figured out, an incident was fixed — or when the user runs /learn.
---

# /learn — alimenter la mémoire typée (zéro question)

LA boucle d'apprentissage. **Autonome** : tu classes et tu écris **seul**, puis tu montres un
**récap corrigeable**. Tu ne poses **aucune question** à l'utilisateur.

Déclenchable de **2 façons** : par l'agent au moment sémantique (Option B — voir l'agent
`coolify-ops`, voie ①), ou manuellement par l'utilisateur (voie ③).

## Procédure

1. **Relis ce qui vient de se passer** dans la session : qu'a-t-on décidé, monté, conventionné,
   réparé, ou rendu rejouable ?
2. **Identifie les apprentissages** et **classe chacun seul** :
   - **Type** : decision (choix + pourquoi) · architecture (câblage) · habit (convention) ·
     cookbook (procédure rejouable) · incident (casse + fix).
   - **Portée** : présence d'un **UUID/IP/domaine/credential** → `infra` (infra active) ;
     sinon **global**. Un savoir peut donner 2 fiches (pattern global + concret infra), reliées
     par `related:`.
3. **Pour chaque apprentissage** :
   - `./scripts/memory new <type> <scope> <title>` (scope = `global` ou `infra`/`infra:<nom>`).
     La commande calcule l'`id`, crée la fiche pré-remplie et met l'INDEX à jour ; elle **affiche
     le chemin créé** (dernière ligne).
   - **Remplis le corps** de la fiche (Contexte / section selon le type / Pourquoi-Conséquences),
     ajoute les `tags:` et les `related:`. Édite le fichier créé.
   - **Secrets → fiche `infra` uniquement** (jamais en clair dans une fiche `global`/versionnée).
4. **Affiche un RÉCAP** — 1 ligne par fiche :
   `✓ <type> · <scope> · <id>  <titre>  → <chemin>`
   (pour la voie ① auto de l'agent, la forme courte est `🧠 mémorisé : <type>/<scope>/<id> — <titre>`).
5. **Si l'utilisateur corrige après coup** (« 0004 c'est une decision pas un habit », « ça c'est
   global ») : déplace/renomme la fiche dans le bon dossier (recalcule l'`id` cible si besoin),
   corrige son frontmatter, puis `./scripts/memory reindex` pour resync tous les INDEX touchés.

## Garde-fous

- **Zéro question** : tu tranches le classement toi-même (c'est le but). Le récap rend la décision
  visible et corrigeable a posteriori.
- N'invente pas d'apprentissage pour un tour trivial (status, simple lecture) — dans ce cas, ne rien
  écrire.
- Vérifie qu'aucun secret n'atterrit dans `memory/` (global). En cas de doute sur la portée d'une
  fiche contenant un UUID/credential → `infra`.
