import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        /* Firebase Storage — same bucket as Flutter app */
        protocol: 'https',
        hostname: 'firebasestorage.googleapis.com',
      },
    ],
  },

  /* Silence "module not found" for optional firebase-admin
     which is only used in server actions (not bundled client-side) */
  serverExternalPackages: ['firebase-admin'],

  /* Enable strict mode for better React hygiene */
  reactStrictMode: true,
};

export default nextConfig;
