import { HttpError } from '../utils/httpError.js';

/** Resolves `Authorization: Bearer <token>` to `req.user`, or rejects with 401. */
export function createRequireAuth(authService) {
  // Express 5 forwards a rejected promise from middleware to the error handler.
  return async function requireAuth(req, _res, next) {
    const [scheme, token] = (req.get('authorization') ?? '').split(' ');
    const user = scheme === 'Bearer' && token ? await authService.userForToken(token) : undefined;
    if (!user) {
      throw new HttpError(401, 'Please sign in again.');
    }
    req.user = user;
    req.token = token;
    next();
  };
}
