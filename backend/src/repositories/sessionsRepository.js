/** Data access for the `sessions` table (opaque bearer tokens). */
export function createSessionsRepository(db) {
  const insert = db.prepare('INSERT INTO sessions (token, user_id) VALUES (?, ?)');
  const selectUserByToken = db.prepare(
    'SELECT u.* FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.token = ?',
  );
  const remove = db.prepare('DELETE FROM sessions WHERE token = ?');

  return {
    create(token, userId) {
      insert.run(token, userId);
    },

    findUserByToken(token) {
      return selectUserByToken.get(token);
    },

    delete(token) {
      remove.run(token);
    },
  };
}
