import express from 'express';
import { createErrorHandler } from './middleware/errorHandler.js';
import { createRequireAuth } from './middleware/requireAuth.js';
import { createPhotoUpload } from './middleware/upload.js';
import { requestLogger } from './middleware/requestLogger.js';
import { createListingsRepository } from './repositories/listingsRepository.js';
import { createSessionsRepository } from './repositories/sessionsRepository.js';
import { createUsersRepository } from './repositories/usersRepository.js';
import { createAuthRouter } from './routes/authRoutes.js';
import { createListingsRouter } from './routes/listingsRoutes.js';
import { createMeRouter } from './routes/meRoutes.js';
import { createAuthService } from './services/authService.js';
import { createListingsService } from './services/listingsService.js';

/**
 * Wires repositories → services → routes. Takes the database and photo storage so tests and
 * each deployment target can supply their own.
 */
export function createApp({ db, photoStorage, maxPhotos = 3, maxPhotoBytes = 4 * 1024 * 1024, logRequests = false }) {
  const authService = createAuthService({
    users: createUsersRepository(db),
    sessions: createSessionsRepository(db),
  });
  const listingsService = createListingsService({
    listings: createListingsRepository(db),
    photoStorage,
    maxPhotos,
  });
  const requireAuth = createRequireAuth(authService);
  const photoUpload = createPhotoUpload({ maxPhotos, maxPhotoBytes });

  const app = express();
  app.disable('x-powered-by');
  if (logRequests) app.use(requestLogger);
  app.use(express.json({ limit: '100kb' }));

  app.get('/health', (_req, res) => res.json({ status: 'ok' }));
  if (photoStorage.localDirectory) {
    app.use('/uploads', express.static(photoStorage.localDirectory, { maxAge: '7d', immutable: true }));
  }
  app.use('/auth', createAuthRouter({ authService, requireAuth }));
  app.use('/me', requireAuth, createMeRouter({ listingsService }));
  app.use('/listings', requireAuth, createListingsRouter({ listingsService, photoUpload }));

  app.use((_req, res) => res.status(404).json({ error: 'Not found.' }));
  app.use(createErrorHandler());
  return app;
}
