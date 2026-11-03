/**
 * Lets browser clients on other origins (the web frontend) call the API.
 * Auth uses the Authorization header, not cookies, so credentials are never allowed.
 * `allowedOrigins` is a list of exact origins, or ['*'] for any.
 */
export function createCors(allowedOrigins) {
  const allowsAnyOrigin = allowedOrigins.includes('*');

  return function cors(req, res, next) {
    const origin = req.get('origin');
    if (origin && (allowsAnyOrigin || allowedOrigins.includes(origin))) {
      res.set('Access-Control-Allow-Origin', allowsAnyOrigin ? '*' : origin);
      if (!allowsAnyOrigin) res.vary('Origin');
      res.set('Access-Control-Allow-Headers', 'Authorization, Content-Type');
      res.set('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
      res.set('Access-Control-Max-Age', '600');
    }
    // Preflight requests never reach the routes.
    if (req.method === 'OPTIONS') {
      res.status(204).end();
      return;
    }
    next();
  };
}
