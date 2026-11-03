import os from 'node:os';
import { createConfiguredApp } from './bootstrap.js';
import { config } from './config.js';

// Local development server. On Vercel, api/index.js is the entry point instead.
const { app, db } = await createConfiguredApp();

const server = app.listen(config.port, config.host, () => {
  console.log(`PureCS Market API listening on http://localhost:${config.port}`);
  // Phones on the same Wi-Fi need the laptop's LAN address, so print it.
  for (const addresses of Object.values(os.networkInterfaces())) {
    for (const address of addresses ?? []) {
      if (address.family === 'IPv4' && !address.internal) {
        console.log(`  on your network:  http://${address.address}:${config.port}`);
      }
    }
  }
});

function shutdown() {
  server.close(() => {
    db.close();
    process.exit(0);
  });
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
