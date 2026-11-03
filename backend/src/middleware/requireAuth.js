import { HttpError } from '../utils/httpError.js';

/** Resolves `Authorization: Bearer <token>` to `req.user`, or rejects with 401. */
export function createRequireAuth(authService) {
  return function requireAuth(req, _res, next) {
    const [scheme, token] = (req.get('authorization') ?? '').split(' ');
    const user = scheme === 'Bearer' && token ? authService.userForToken(token) : undefined;
    if (!user) {
      next(new HttpError(401, 'Please sign in again.'));
      return;
    }
    req.user = user;
    req.token = token;
    next();
  };
}
