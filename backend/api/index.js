import { createConfiguredApp } from '../src/bootstrap.js';

// Vercel serverless entry point. vercel.json routes every path here.
// The app (and its database connection) is built once per warm instance and reused.
let appPromise;

function getApp() {
  appPromise ??= createConfiguredApp()
    .then(({ app }) => app)
    .catch((error) => {
      appPromise = undefined; // retry on the next request, e.g. after env vars are fixed
      throw error;
    });
  return appPromise;
}

export default async function handler(req, res) {
  let app;
  try {
    app = await getApp();
  } catch (error) {
    console.error(error);
    res.statusCode = 500;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ error: `The server is not configured: ${error.message}` }));
    return;
  }
  app(req, res);
}
