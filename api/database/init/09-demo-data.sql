-- Données de démonstration pour le projet
-- Idempotent : les inserts ignorent les doublons si les slugs/noms existent déjà.

INSERT INTO category (name, slug, description)
VALUES
    ('Actualités', 'actualites', 'Articles d’actualité et de contexte.'),
    ('Technologie', 'technologie', 'Dossiers et retours d’expérience tech.'),
    ('Design', 'design', 'Création, UX et identité visuelle.'),
    ('Tendances', 'tendances', 'Ce qui se passe dans le web et les usages.')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tags (name, slug, description)
VALUES
    ('PHP', 'php', 'PHP et architecture backend.'),
    ('JavaScript', 'javascript', 'Frontend et interactions web.'),
    ('UX', 'ux', 'Expérience utilisateur.'),
    ('SEO', 'seo', 'Référencement naturel.'),
    ('DevOps', 'devops', 'Déploiement et CI/CD.')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (title, slug, content, excerpt, status, author_id, published_at)
VALUES
    (
        'Comment structurer un projet CMS moderne en PHP ?',
        'comment-structurer-un-projet-cms-moderne-en-php',
        '<p>Un CMS robuste repose sur une séparation claire entre routes, contrôleurs, repositories et vues.</p><p>La clé est d’encapsuler les responsabilités pour garder le code maintenable sans perdre en vitesse.</p>',
        'Un CMS robuste repose sur une séparation claire entre routes, contrôleurs, repositories et vues.',
        'published',
        1,
        NOW()
    ),
    (
        'Les bonnes pratiques pour un front-end rapide avec Vite',
        'les-bonnes-pratiques-pour-un-front-end-rapide-avec-vite',
        '<p>Vite permet de gagner du temps de build et d’offrir une meilleure expérience de développement.</p><p>En combinant modularisation, composants et chargements ciblés, on obtient une interface plus fluide.</p>',
        'Vite permet de gagner du temps de build et d’offrir une meilleure expérience de développement.',
        'published',
        1,
        NOW() - INTERVAL '2 days'
    ),
    (
        'UX et contenu : comment faire parler les interfaces',
        'ux-et-contenu-comment-faire-parler-les-interfaces',
        '<p>Un bon design ne se limite pas à l’apparence visuelle. Il guide la compréhension, le parcours et la confiance.</p><p>Le contenu doit être pensé comme un composant central de l’expérience utilisateur.</p>',
        'Un bon design ne se limite pas à l’apparence visuelle. Il guide la compréhension, le parcours et la confiance.',
        'published',
        1,
        NOW() - INTERVAL '5 days'
    )
ON CONFLICT (slug) DO NOTHING;

-- Liaisons catégories
INSERT INTO article_category (article_id, category_id)
SELECT a.id, c.id
FROM articles a
JOIN category c ON c.slug = 'actualites'
WHERE a.slug = 'comment-structurer-un-projet-cms-moderne-en-php'
ON CONFLICT DO NOTHING;

INSERT INTO article_category (article_id, category_id)
SELECT a.id, c.id
FROM articles a
JOIN category c ON c.slug = 'technologie'
WHERE a.slug = 'les-bonnes-pratiques-pour-un-front-end-rapide-avec-vite'
ON CONFLICT DO NOTHING;

INSERT INTO article_category (article_id, category_id)
SELECT a.id, c.id
FROM articles a
JOIN category c ON c.slug = 'design'
WHERE a.slug = 'ux-et-contenu-comment-faire-parler-les-interfaces'
ON CONFLICT DO NOTHING;

-- Liaisons tags
INSERT INTO article_tag (article_id, tag_id)
SELECT a.id, t.id
FROM articles a
JOIN tags t ON t.slug = 'php'
WHERE a.slug = 'comment-structurer-un-projet-cms-moderne-en-php'
ON CONFLICT DO NOTHING;

INSERT INTO article_tag (article_id, tag_id)
SELECT a.id, t.id
FROM articles a
JOIN tags t ON t.slug = 'javascript'
WHERE a.slug = 'les-bonnes-pratiques-pour-un-front-end-rapide-avec-vite'
ON CONFLICT DO NOTHING;

INSERT INTO article_tag (article_id, tag_id)
SELECT a.id, t.id
FROM articles a
JOIN tags t ON t.slug = 'ux'
WHERE a.slug = 'ux-et-contenu-comment-faire-parler-les-interfaces'
ON CONFLICT DO NOTHING;
