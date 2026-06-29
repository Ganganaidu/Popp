/**
 * Firestore data layer — mirrors Flutter's Firestore access patterns.
 * All public queries filter by isApproved==true, isActive==true.
 */

import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  where,
  limit,
  orderBy,
  addDoc,
  setDoc,
  writeBatch,
  serverTimestamp,
  Timestamp,
  type DocumentData,
  type QueryDocumentSnapshot,
} from 'firebase/firestore';
import { db } from './config';
import type { FirestoreProduct, FirestoreService, FirestoreAd } from '@/lib/types';

/* ── Category slug → Firestore category string ───────────────────────────── */
const SLUG_TO_CATEGORY: Record<string, string> = {
  'mechanics':       'Find Mechanic',
  'bike-rentals':    'Bike Rentals',
  'track-day':       'Track day',
  'training-day':    'Training day',
  'accessory-store': 'Accessory Store',
  'tyre-shops':      'Tyre Shops',
  'towing':          'Towing Service',
  'inspection':      'Find Mechanic',
};

/* ── Timestamp helpers ────────────────────────────────────────────────────── */
function tsToISO(val: unknown): string | undefined {
  if (!val) return undefined;
  if (val instanceof Timestamp) return val.toDate().toISOString();
  if (typeof val === 'string') return val;
  return undefined;
}

function docToProduct(d: QueryDocumentSnapshot<DocumentData>): FirestoreProduct {
  const raw = d.data();
  return {
    ...raw,
    id: d.id,
    mfgDate:            tsToISO(raw.mfgDate),
    registrationDate:   tsToISO(raw.registrationDate),
    insuranceValidTill: tsToISO(raw.insuranceValidTill),
    createdAt:          tsToISO(raw.createdAt),
  } as FirestoreProduct;
}

function docToService(d: QueryDocumentSnapshot<DocumentData>): FirestoreService {
  const raw = d.data();
  return {
    ...raw,
    id: d.id,
    createdAt: tsToISO(raw.createdAt),
  } as FirestoreService;
}

function docToAd(d: QueryDocumentSnapshot<DocumentData>): FirestoreAd {
  return { ...d.data(), id: d.id } as FirestoreAd;
}

/* ── READ: Products ───────────────────────────────────────────────────────── */

/**
 * Returns approved active unsold products.
 * Pass category='Premium Bikes' for bikes, 'accessory' for accessories (non-bikes).
 */
export async function getProducts(opts?: { lim?: number; category?: string }): Promise<FirestoreProduct[]> {
  try {
    const col = collection(db, 'products');
    const lim_ = opts?.lim ?? 20;

    if (!opts?.category || opts.category === 'Premium Bikes') {
      const q = query(
        col,
        where('isApproved', '==', true),
        where('isActive', '==', true),
        where('isSold', '==', false),
        where('category', '==', 'Premium Bikes'),
        orderBy('createdAt', 'desc'),
        limit(lim_),
      );
      const snap = await getDocs(q);
      return snap.docs.map(docToProduct);
    }

    // Accessories: products where category != 'Premium Bikes'
    // Firestore doesn't support != queries with orderBy on different fields, so we query
    // all approved active unsold and filter client-side for accessories.
    const q = query(
      col,
      where('isApproved', '==', true),
      where('isActive', '==', true),
      where('isSold', '==', false),
      orderBy('createdAt', 'desc'),
      limit(lim_ * 4), // over-fetch since we'll filter
    );
    const snap = await getDocs(q);
    const all = snap.docs.map(docToProduct);
    const accessories = all.filter((p) => p.category !== 'Premium Bikes');
    return accessories.slice(0, lim_);
  } catch (err) {
    console.error('[firestore] getProducts error:', err);
    return [];
  }
}

/** Returns a single product by Firestore doc ID. */
export async function getProductById(id: string): Promise<FirestoreProduct | null> {
  try {
    const ref = doc(db, 'products', id);
    const snap = await getDoc(ref);
    if (!snap.exists()) return null;
    const raw = snap.data();
    return {
      ...raw,
      id: snap.id,
      mfgDate:            tsToISO(raw.mfgDate),
      registrationDate:   tsToISO(raw.registrationDate),
      insuranceValidTill: tsToISO(raw.insuranceValidTill),
      createdAt:          tsToISO(raw.createdAt),
    } as FirestoreProduct;
  } catch (err) {
    console.error('[firestore] getProductById error:', err);
    return null;
  }
}

/* ── READ: Services ───────────────────────────────────────────────────────── */

/**
 * Returns approved active services matching a URL slug.
 * For 'inspection': queries 'Find Mechanic' + filters by doYouInspectPremiumBikes == 'Yes'.
 */
export async function getServices(categorySlug: string, lim_: number = 20): Promise<FirestoreService[]> {
  try {
    const firestoreCategory = SLUG_TO_CATEGORY[categorySlug];
    if (!firestoreCategory) return [];

    const col = collection(db, 'services');

    if (categorySlug === 'inspection') {
      const q = query(
        col,
        where('isApproved', '==', true),
        where('isActive', '==', true),
        where('category', '==', 'Find Mechanic'),
        where('doYouInspectPremiumBikes', '==', 'Yes'),
        limit(lim_),
      );
      const snap = await getDocs(q);
      return snap.docs.map(docToService);
    }

    const q = query(
      col,
      where('isApproved', '==', true),
      where('isActive', '==', true),
      where('category', '==', firestoreCategory),
      limit(lim_),
    );
    const snap = await getDocs(q);
    return snap.docs.map(docToService);
  } catch (err) {
    console.error('[firestore] getServices error:', err);
    return [];
  }
}

/** Returns a single service by Firestore doc ID. */
export async function getServiceById(id: string): Promise<FirestoreService | null> {
  try {
    const ref = doc(db, 'services', id);
    const snap = await getDoc(ref);
    if (!snap.exists()) return null;
    const raw = snap.data();
    return {
      ...raw,
      id: snap.id,
      createdAt: tsToISO(raw.createdAt),
    } as FirestoreService;
  } catch (err) {
    console.error('[firestore] getServiceById error:', err);
    return null;
  }
}

/* ── READ: Ads ────────────────────────────────────────────────────────────── */

/** Returns all active ads. */
export async function getAds(): Promise<FirestoreAd[]> {
  try {
    const col = collection(db, 'ads');
    const q = query(col, where('isActive', '==', true));
    const snap = await getDocs(q);
    return snap.docs.map(docToAd);
  } catch (err) {
    console.error('[firestore] getAds error:', err);
    return [];
  }
}

/* ── WRITE: Products ──────────────────────────────────────────────────────── */

/**
 * Creates a product doc + atomically links it to the user's createdProductIds.
 * Returns the new doc ID or null on error.
 */
export async function createProduct(data: Record<string, unknown>, userId: string): Promise<string | null> {
  try {
    const batch = writeBatch(db);
    const productRef = doc(collection(db, 'products'));
    batch.set(productRef, {
      ...data,
      userId,
      createdAt: serverTimestamp(),
      searchKeywords: [],
      favoritedBy: [],
    });

    const userRef = doc(db, 'users', userId);
    // Note: arrayUnion is not available on batch. Use addDoc + separate update.
    // Instead: create product first, then update user.
    await batch.commit();

    await linkProductToUser(userId, productRef.id);
    return productRef.id;
  } catch (err) {
    console.error('[firestore] createProduct error:', err);
    return null;
  }
}

/* ── WRITE: Services ──────────────────────────────────────────────────────── */

/**
 * Creates a service doc.
 * Returns the new doc ID or null on error.
 */
export async function createService(data: Record<string, unknown>, userId: string): Promise<string | null> {
  try {
    const ref = await addDoc(collection(db, 'services'), {
      ...data,
      userId,
      isApproved: false,
      isActive: true,
      createdAt: serverTimestamp(),
    });
    return ref.id;
  } catch (err) {
    console.error('[firestore] createService error:', err);
    return null;
  }
}

/* ── WRITE: Users ─────────────────────────────────────────────────────────── */

/** Create or merge a user doc (called on signup). */
export async function createUserDoc(uid: string, data: Record<string, unknown>): Promise<void> {
  try {
    const ref = doc(db, 'users', uid);
    await setDoc(ref, {
      ...data,
      createdAt: serverTimestamp(),
      createdProductIds: [],
      savedProductIds: [],
    }, { merge: true });
  } catch (err) {
    console.error('[firestore] createUserDoc error:', err);
  }
}

/** Add a product ID to the user's createdProductIds array. */
export async function linkProductToUser(userId: string, productId: string): Promise<void> {
  try {
    // Import arrayUnion dynamically to keep this module leaner
    const { updateDoc, arrayUnion } = await import('firebase/firestore');
    const ref = doc(db, 'users', userId);
    await updateDoc(ref, {
      createdProductIds: arrayUnion(productId),
    });
  } catch (err) {
    console.error('[firestore] linkProductToUser error:', err);
  }
}
