import { Router } from 'express';
import { serializeUser } from '../utils/serializers.js';
import { loginSchema, registerSchema } from '../validation/schemas.js';
import { parse } from '../validation/parse.js';

export function createAuthRouter({ authService, requireAuth }) {
  const router = Router();

  router.post('/register', async (req, res) => {
    const input = parse(registerSchema, req.body ?? {});
    const { token, user } = await authService.register({
      username: input.username,
      password: input.password,
      displayName: input.display_name,
      phone: input.phone,
    });
    res.status(201).json({ token, user: serializeUser(user) });
  });

  router.post('/login', async (req, res) => {
    const input = parse(loginSchema, req.body ?? {});
    const { token, user } = await authService.login(input);
    res.json({ token, user: serializeUser(user) });
  });

  router.post('/logout', requireAuth, (req, res) => {
    authService.logout(req.token);
    res.status(204).end();
  });

  return router;
}
