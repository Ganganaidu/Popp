import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { initializeFirestore, getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

/**
 * Firebase configuration — reads from environment variables.
 * Copy .env.local.example → .env.local and fill in values from your
 * existing Firebase project (same project the Flutter app uses).
 */
const firebaseConfig = {
  apiKey:            process.env.NEXT_PUBLIC_FIREBASE_API_KEY!,
  authDomain:        process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN!,
  projectId:         process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID!,
  storageBucket:     process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET!,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID!,
  appId:             process.env.NEXT_PUBLIC_FIREBASE_APP_ID!,
};

/* Prevent re-initialization on hot-reload */
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();

export const auth = getAuth(app);

/*
 * Force HTTP long-polling instead of gRPC WebChannel.
 * gRPC is not available in Node.js server components (Next.js RSC/SSR),
 * which causes "GRPC error has no .code" console errors.
 * experimentalForceLongPolling works in both Node.js and browsers.
 * On hot-reload initializeFirestore throws because it was already called —
 * fall through to getFirestore() which returns the existing instance.
 */
function buildDb() {
  try {
    return initializeFirestore(app, { experimentalForceLongPolling: true });
  } catch {
    return getFirestore(app);
  }
}
export const db = buildDb();

export const storage = getStorage(app);
export default app;
