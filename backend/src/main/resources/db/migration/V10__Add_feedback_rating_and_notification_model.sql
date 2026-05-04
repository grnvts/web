CREATE TABLE IF NOT EXISTS rating_categories (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO rating_categories (code, name, description)
SELECT 'OVERALL', 'Overall', 'Overall satisfaction score'
WHERE NOT EXISTS (SELECT 1 FROM rating_categories WHERE code = 'OVERALL');

INSERT INTO rating_categories (code, name, description)
SELECT 'QUALITY', 'Work quality', 'Quality of completed work'
WHERE NOT EXISTS (SELECT 1 FROM rating_categories WHERE code = 'QUALITY');

INSERT INTO rating_categories (code, name, description)
SELECT 'DEADLINE', 'Deadline', 'Adherence to agreed deadlines'
WHERE NOT EXISTS (SELECT 1 FROM rating_categories WHERE code = 'DEADLINE');

INSERT INTO rating_categories (code, name, description)
SELECT 'COMMUNICATION', 'Communication', 'Quality of communication and feedback'
WHERE NOT EXISTS (SELECT 1 FROM rating_categories WHERE code = 'COMMUNICATION');

INSERT INTO rating_categories (code, name, description)
SELECT 'PRICE', 'Price', 'Price to value ratio'
WHERE NOT EXISTS (SELECT 1 FROM rating_categories WHERE code = 'PRICE');

ALTER TABLE reviews
    ADD COLUMN IF NOT EXISTS author_id BIGINT REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS target_user_id BIGINT REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS title VARCHAR(255),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP;

UPDATE reviews r
SET author_id = o.client_id,
    target_user_id = COALESCE(b.brigadier_id, o.brigadier_id),
    updated_at = COALESCE(r.updated_at, r.created_at)
FROM orders o
LEFT JOIN brigade b ON b.id = o.brigade_id
WHERE r.order_id = o.id
  AND (r.author_id IS NULL OR r.target_user_id IS NULL OR r.updated_at IS NULL);

CREATE TABLE IF NOT EXISTS review_ratings (
    id BIGSERIAL PRIMARY KEY,
    review_id BIGINT NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    category_id BIGINT NOT NULL REFERENCES rating_categories(id),
    score SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    CONSTRAINT uk_review_rating_review_category UNIQUE (review_id, category_id)
);

INSERT INTO review_ratings (review_id, category_id, score)
SELECT r.id, rc.id, r.rating::SMALLINT
FROM reviews r
JOIN rating_categories rc ON rc.code = 'OVERALL'
WHERE r.rating IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM review_ratings rr
      WHERE rr.review_id = r.id
        AND rr.category_id = rc.id
  );

ALTER TABLE reviews
    DROP COLUMN IF EXISTS rating;

CREATE UNIQUE INDEX IF NOT EXISTS uk_reviews_order_author_target
    ON reviews(order_id, author_id, target_user_id);

CREATE INDEX IF NOT EXISTS idx_reviews_order
    ON reviews(order_id);

CREATE INDEX IF NOT EXISTS idx_reviews_author
    ON reviews(author_id);

CREATE INDEX IF NOT EXISTS idx_reviews_target_user
    ON reviews(target_user_id);

CREATE INDEX IF NOT EXISTS idx_reviews_order_created
    ON reviews(order_id, created_at DESC);

CREATE TABLE IF NOT EXISTS notification_types (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

INSERT INTO notification_types (code, name, description)
SELECT 'ORDER_STATUS', 'Order status', 'Order lifecycle events'
WHERE NOT EXISTS (SELECT 1 FROM notification_types WHERE code = 'ORDER_STATUS');

INSERT INTO notification_types (code, name, description)
SELECT 'CHAT_MESSAGE', 'Chat message', 'New message in order chat'
WHERE NOT EXISTS (SELECT 1 FROM notification_types WHERE code = 'CHAT_MESSAGE');

INSERT INTO notification_types (code, name, description)
SELECT 'SYSTEM', 'System', 'System information and service events'
WHERE NOT EXISTS (SELECT 1 FROM notification_types WHERE code = 'SYSTEM');

INSERT INTO notification_types (code, name, description)
SELECT 'ORDER_REMINDER', 'Order reminder', 'Reminder about upcoming work or action'
WHERE NOT EXISTS (SELECT 1 FROM notification_types WHERE code = 'ORDER_REMINDER');

CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    actor_user_id BIGINT REFERENCES users(id),
    order_id BIGINT REFERENCES orders(id),
    type_id BIGINT REFERENCES notification_types(id),
    title VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE notifications
    ADD COLUMN IF NOT EXISTS user_id BIGINT REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS order_id BIGINT REFERENCES orders(id),
    ADD COLUMN IF NOT EXISTS actor_user_id BIGINT REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS type_id BIGINT REFERENCES notification_types(id),
    ADD COLUMN IF NOT EXISTS title VARCHAR(255),
    ADD COLUMN IF NOT EXISTS message TEXT,
    ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS read_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

UPDATE notifications n
SET type_id = nt.id,
    title = COALESCE(n.title, 'Order status updated')
FROM notification_types nt
WHERE nt.code = 'ORDER_STATUS'
  AND (n.type_id IS NULL OR n.title IS NULL);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created
    ON notifications(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_type
    ON notifications(type_id);

CREATE INDEX IF NOT EXISTS idx_notifications_order
    ON notifications(order_id);

CREATE INDEX IF NOT EXISTS idx_notifications_actor_user
    ON notifications(actor_user_id);

CREATE TABLE IF NOT EXISTS messages (
    id BIGSERIAL PRIMARY KEY,
    sender_id BIGINT NOT NULL REFERENCES users(id),
    recipient_id BIGINT NOT NULL REFERENCES users(id),
    order_id BIGINT NOT NULL REFERENCES orders(id),
    content TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS sender_id BIGINT REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS recipient_id BIGINT REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS order_id BIGINT REFERENCES orders(id),
    ADD COLUMN IF NOT EXISTS content TEXT,
    ADD COLUMN IF NOT EXISTS sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_messages_order_sent
    ON messages(order_id, sent_at ASC);

CREATE INDEX IF NOT EXISTS idx_messages_sender
    ON messages(sender_id);

CREATE INDEX IF NOT EXISTS idx_messages_recipient
    ON messages(recipient_id);

CREATE INDEX IF NOT EXISTS idx_review_ratings_review
    ON review_ratings(review_id);

CREATE INDEX IF NOT EXISTS idx_review_ratings_category
    ON review_ratings(category_id);
