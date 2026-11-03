/** Data access for the `sessions` table (opaque bearer tokens). */
export function createSessionsRepository(db) {
  return {
    async create(token, userId) {
      await db.run('INSERT INTO sessions (token, user_id) VALUES (?, ?)', [token, userId]);
    },

    findUserByToken(token) {
      return db.get('SELECT u.* FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.token = ?', [token]);
    },

    async delete(token) {
      await db.run('DELETE FROM sessions WHERE token = ?', [token]);
    },
  };
}
