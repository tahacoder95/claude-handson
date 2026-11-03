import crypto from 'node:crypto';
import bcrypt from 'bcryptjs';
import { HttpError } from '../utils/httpError.js';

const BCRYPT_ROUNDS = 10;

function isUniqueViolation(error) {
  return error?.code === 'SQLITE_CONSTRAINT_UNIQUE';
}

/** Sign-up, sign-in and token sessions. */
export function createAuthService({ users, sessions }) {
  function startSession(user) {
    const token = crypto.randomBytes(32).toString('hex');
    sessions.create(token, user.id);
    return { token, user };
  }

  return {
    async register({ username, password, displayName, phone }) {
      if (users.findByUsername(username)) {
        throw new HttpError(409, 'That username is already taken.');
      }
      const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
      try {
        return startSession(users.create({ username, passwordHash, displayName, phone }));
      } catch (error) {
        // Two sign-ups racing for the same username.
        if (isUniqueViolation(error)) throw new HttpError(409, 'That username is already taken.');
        throw error;
      }
    },

    async login({ username, password }) {
      const user = users.findByUsername(username);
      const matches = user ? await bcrypt.compare(password, user.password_hash) : false;
      if (!matches) {
        throw new HttpError(401, 'Wrong username or password.');
      }
      return startSession(user);
    },

    logout(token) {
      sessions.delete(token);
    },

    userForToken(token) {
      return sessions.findUserByToken(token);
    },
  };
}
