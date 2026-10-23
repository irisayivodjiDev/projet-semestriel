# DevFlow CMS — Projet Semestriel 3A WD

CMS headless éditorial multi-auteurs développé **from scratch en PHP**, sans framework externe. Back-office complet, API REST JSON, et frontend public découplé en Vite.

**Stack :** PHP 8.4 · PostgreSQL 16 · Apache · Docker · SASS maison · Vite

---

## Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installé et **démarré**
- [Node.js](https://nodejs.org/) v18 ou supérieur (pour le frontend)

---

## Lancer le projet — étape par étape

### 1. Cloner le dépôt

```bash
git clone https://github.com/yascodev/projet-semestriel.git
cd projet-semestriel
```

### 2. Démarrer le back-end (PHP + PostgreSQL)

```bash
cd api
docker compose up -d --build
```


**La base de données est déjà incluse dans le dépôt** (`api/postgres/`) — elle est automatiquement montée dans le conteneur PostgreSQL. Aucune commande d'import SQL n'est nécessaire.

> Le back-office est disponible sur **<http://localhost:8079>**

### 3. Démarrer le frontend (dans un second terminal)

```bash
cd frontend
npm install
npm run dev
```

> ✅ Le frontend public est disponible sur **<http://localhost:5173>**

> ⚠️ Docker doit être démarré **avant** le frontend. Le frontend consomme l'API sur `http://localhost:8079`.

## Déploiement sur Render

Le fichier [`render.yaml`](./render.yaml) configure le front public et l'API sur Render. L'API utilise PostgreSQL chez Neon, dont le plan gratuit convient à une démonstration personnelle.

1. Créez une base PostgreSQL gratuite sur [Neon](https://neon.com/) et copiez sa chaîne de connexion (`DATABASE_URL`).
2. Connectez le dépôt GitHub à [Render](https://render.com/), puis créez un Blueprint à partir de ce dépôt et de `render.yaml`.
3. Lors de la création, fournissez la chaîne Neon comme `DATABASE_URL`. Le premier démarrage de l'API crée le schéma et les données de démonstration.
4. Après le déploiement, vérifiez les URL Render générées. Si elles diffèrent des URL déclarées dans `render.yaml`, mettez à jour `VITE_API_URL` sur le site statique et `CORS_ORIGIN` sur l'API, puis redéployez le front.

Les services gratuits peuvent se mettre en veille après une période d'inactivité. Le système de fichiers de l'API est éphémère : les fichiers média téléversés ne sont donc pas conservés durablement. Ne déployez pas de données sensibles ni de secrets dans ce projet de démonstration.

Avant de partager le back-office publiquement, remplacez le mot de passe de démonstration `admin123` du compte `admin@cms.local`.

---

## Résolution de problèmes fréquents

### Port déjà utilisé

Si le port `8079` ou `5433` est occupé, arrêtez les autres conteneurs Docker :

```bash
docker compose down
docker compose up -d --build
```

### Erreur PostgreSQL au démarrage (`postmaster.pid`)

Si PostgreSQL refuse de démarrer avec un message `lock file "postmaster.pid" already exists`, supprimez le fichier résiduel et relancez :

```bash
# Dans api/
Remove-Item postgres/postmaster.pid   # Windows PowerShell
# ou
rm postgres/postmaster.pid            # macOS / Linux

docker compose up -d
```

### Voir les logs en cas d'erreur

```bash
# Logs du serveur Apache / PHP
docker logs php-CMS

# Logs de PostgreSQL
docker logs php-postgres-CMS
```

---

## Accès par défaut

| | |
|---|---|
| Back-office | <http://localhost:8079/admin> |
| Page de connexion | <http://localhost:8079/login> |
| API REST | <http://localhost:8079/api/v1> |
| Frontend public | <http://localhost:5173> |

**Compte administrateur**

| Champ | Valeur |
|---|---|
| Email | `admin@cms.local` |
| Mot de passe | `admin123` |

**Autres comptes de test**

| Email | Mot de passe | Rôle |
|---|---|---|
| `editor@cms.local` | `editor123` | Éditeur |
| `author@cms.local` | `author123` | Auteur |

---

## Rôles et permissions

| Rôle | Droits |
|---|---|
| **Admin** | Accès total — utilisateurs, contenus, publication, médias |
| **Editor** | Gérer et publier tous les articles, catégories, tags, médias |
| **Author** | Créer et gérer ses propres articles (brouillons uniquement, ne peut pas publier) |

---

## Workflow des articles

```text
Draft → Published → Archived
```

- Les **auteurs** créent des brouillons uniquement
- Les **éditeurs et admins** publient et archivent

---

## API REST

Base URL : `http://localhost:8079/api/v1`

Les endpoints de lecture sont **publics** (pas d'authentification requise). Les endpoints d'écriture nécessitent une session active.

| Ressource | Endpoints disponibles |
|---|---|
| Articles | `GET /articles` · `GET /articles/:id` · `GET /articles/slug/:slug` |
| Catégories | `GET /categories` · `GET /categories/:id/articles` |
| Tags | `GET /tags` · `GET /tags/:id/articles` |
| Auth | `POST /auth/login` · `GET /auth/logout` · `GET /auth/profile` |

---

## Structure du projet

```text
projet-semestriel/
├── api/
│   ├── app/
│   │   ├── src/
│   │   │   ├── Controllers/   # Contrôleurs Admin, API, Erreurs
│   │   │   ├── Entities/      # User, Article, Category, Tag, Media
│   │   │   ├── Repositories/  # Accès base de données (ORM maison + PDO)
│   │   │   └── Lib/           # Framework : Router, AbstractController, CSRF, Session...
│   │   ├── config/
│   │   │   ├── routes.json    # Déclaration des routes
│   │   │   └── database.json  # Connexion PostgreSQL
│   │   └── views/             # Templates HTML (back-office + erreurs)
│   ├── assets/                # Sources SASS
│   ├── dist/css/              # CSS compilé (servi par Apache)
│   ├── database/init/         # Scripts SQL de référence (01 à 08)
│   ├── postgres/              # Données PostgreSQL persistées
│   └── docker-compose.yml
└── frontend/                  # Blog public (Vite multi-pages)
```

---

## Framework maison

| Composant | Rôle |
|---|---|
| **Router** | Lit `routes.json`, dispatche vers le bon contrôleur, gère les paramètres dynamiques (`:id`, `:slug`), fallback 404 |
| **AbstractController** | Rendu de vues HTML et réponses JSON, héritage pour tous les contrôleurs |
| **AbstractRepository** | ORM léger : CRUD via PDO + PHP Reflection pour mapper les entités automatiquement |
| **Middlewares** | Vérification de session, token CSRF, vérification des rôles à chaque requête |
| **Autoload PSR-4** | `App\` → `src/` via Composer |

---

## Sécurité

- Mots de passe hashés avec `password_hash()` (bcrypt)
- Requêtes SQL via PDO prepared statements (protection injection SQL)
- Tokens CSRF sur tous les formulaires POST
- Échappement XSS avec `htmlspecialchars()`
- Vérification des permissions à chaque requête par le middleware de rôle

---

## Commandes utiles

```bash
# Accéder à la base de données PostgreSQL
docker exec -it php-postgres-CMS psql -U user -d db

# Recompiler le CSS SASS manuellement
cd api
npx sass assets/main.scss dist/css/main.css --style=compressed

# Recompiler en mode watch (rechargement automatique)
npx sass --watch assets/main.scss dist/css/main.css

# Arrêter tous les conteneurs
docker compose down

# Reconstruire entièrement (si problème de build)
docker compose down && docker compose up -d --build
```

---

## Conventions Git

- **Branches :** `feature/`, `fix/`, `chore/`, `docs/`
- **Commits :** `feat:`, `fix:`, `chore:`, `docs:`
- Chaque feature développée sur une branche dédiée, fusionnée via Pull Request
- Issues GitHub liées aux commits via `Closes #n`
