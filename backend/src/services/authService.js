import crypto from 'node:crypto';
import bcrypt from 'bcryptjs';
import { HttpError } from '../utils/httpError.js';
import { isUniqueViolation } from '../utils/sqliteErrors.js';

const BCRYPT_ROUNDS = 10;
const USERNAME_TAKEN = 'That username is already taken.';

/** Sign-up, sign-in and token sessions. */
export function createAuthService({ users, sessions }) {
  async function startSession(user) {
    const token = crypto.randomBytes(32).toString('hex');
    await sessions.create(token, user.id);
    return { token, user };
  }

  return {
    async register({ username, password, displayName, phone }) {
      if (await users.findByUsername(username)) {
        throw new HttpError(409, USERNAME_TAKEN);
      }
      const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
      try {
        return await startSession(await users.create({ username, passwordHash, displayName, phone }));
      } catch (error) {
        // Two sign-ups racing for the same username.
        if (isUniqueViolation(error)) throw new HttpError(409, USERNAME_TAKEN);
        throw error;
      }
    },

    async login({ username, password }) {
      const user = await users.findByUsername(username);
      const matches = user ? await bcrypt.compare(password, user.password_hash) : false;
      if (!matches) {
        throw new HttpError(401, 'Wrong username or password.');
      }
      return startSession(user);
    },

    logout(token) {
      return sessions.delete(token);
    },

    userForToken(token) {
      return sessions.findUserByToken(token);
    },
  };
}
