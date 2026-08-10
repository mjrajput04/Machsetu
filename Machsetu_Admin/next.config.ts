import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // The Flutter app sits beside this project, so pin the workspace root and
  // stop Next inferring it from a stray lockfile further up the tree.
  turbopack: { root: __dirname },
};

export default nextConfig;
