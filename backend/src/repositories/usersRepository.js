/** Data access for the `users` table. No business rules here. */
export function createUsersRepository(db) {
  const insert = db.prepare(
    'INSERT INTO users (username, password_hash, display_name, phone) VALUES (?, ?, ?, ?)',
  );
  const selectById = db.prepare('SELECT * FROM users WHERE id = ?');
  const selectByUsername = db.prepare('SELECT * FROM users WHERE username = ?');

  return {
    create({ username, passwordHash, displayName, phone }) {
      const { lastInsertRowid } = insert.run(username, passwordHash, displayName, phone);
      return selectById.get(lastInsertRowid);
    },

    findById(id) {
      return selectById.get(id);
    },

    findByUsername(username) {
      return selectByUsername.get(username);
    },
  };
}
