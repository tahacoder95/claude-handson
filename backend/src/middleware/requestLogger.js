/** One line per request: method, path, status and duration. */
export function requestLogger(req, res, next) {
  const startedAt = performance.now();
  res.on('finish', () => {
    const duration = (performance.now() - startedAt).toFixed(0);
    console.log(`${req.method} ${req.originalUrl} → ${res.statusCode} (${duration} ms)`);
  });
  next();
}
