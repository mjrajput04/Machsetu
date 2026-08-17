/**
 * PM2 process definition for the MachSetu admin console.
 *
 *   pm2 start ecosystem.config.cjs --env production
 *   pm2 save
 *
 * Secrets are NOT kept here — they live in .env.local on the server, which
 * Next reads at boot. This file only decides how the process is run.
 */
module.exports = {
  apps: [
    {
      name: "machsetu-admin",
      cwd: "/var/www/machsetu/Machsetu_Admin",
      script: "node_modules/next/dist/bin/next",
      args: "start --port 3000 --hostname 127.0.0.1",

      // Two workers on a 2-vCPU box: one serves while the other restarts.
      instances: 2,
      exec_mode: "cluster",

      // Nginx is the only thing that talks to these ports.
      env: {
        NODE_ENV: "production",
        PORT: 3000,
      },

      max_memory_restart: "600M",
      autorestart: true,
      // A crash loop should back off rather than hammer the database.
      restart_delay: 2000,
      max_restarts: 10,

      error_file: "/var/log/machsetu/error.log",
      out_file: "/var/log/machsetu/out.log",
      merge_logs: true,
      time: true,
    },
  ],
};
