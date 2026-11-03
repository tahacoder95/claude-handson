/** Data access for the `users` table. No business rules here. */
export function createUsersRepository(db) {
  return {
    async create({ username, passwordHash, displayName, phone }) {
      const { lastInsertRowid } = await db.run(
        'INSERT INTO users (username, password_hash, display_name, phone) VALUES (?, ?, ?, ?)',
        [username, passwordHash, displayName, phone],
      );
      return db.get('SELECT * FROM users WHERE id = ?', [lastInsertRowid]);
    },

    findById(id) {
      return db.get('SELECT * FROM users WHERE id = ?', [id]);
    },

    findByUsername(username) {
      return db.get('SELECT * FROM users WHERE username = ?', [username]);
    },
  };
}
