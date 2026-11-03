import os from 'node:os';
import { createApp } from './app.js';
import { config } from './config.js';
import { openDatabase } from './db/database.js';

const db = openDatabase(config.databasePath);
const app = createApp({ db, ...config, logRequests: true });

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
