import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // The Flutter app sits beside this project, so pin the workspace root and
  // stop Next inferring it from a stray lockfile further up the tree.
  turbopack: { root: __dirname },

  async headers() {
    return [
      {
        // The Flutter client runs on its own origin (web on :8080, or a
        // device), so the API has to allow cross-origin calls.
        source: "/api/:path*",
        headers: [
          { key: "Access-Control-Allow-Origin", value: "*" },
          {
            key: "Access-Control-Allow-Methods",
            value: "GET,POST,PUT,PATCH,DELETE,OPTIONS",
          },
          {
            key: "Access-Control-Allow-Headers",
            value: "Content-Type, Authorization",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
