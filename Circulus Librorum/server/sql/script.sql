CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE users_tokens (
    id INT NOT NULL,
    token TEXT NOT NULL,
    expires_at DATETIME NOT NULL,

    FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
);