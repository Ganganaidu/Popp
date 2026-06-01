/**
 * Shared TypeScript types — mirrors the Firestore data model
 * used by the Flutter app (same collections, same field names).
 */

/* ─── User ──────────────────────────────────────────────────────────────────── */
export interface BVUser {
  uid: string;
  email: string;
  displayName?: string;
  photoURL?: string;
  city?: string;
  state?: string;
  phone?: string;
  isAdmin?: boolean;
  isVerifiedSeller?: boolean;
  createdAt: string; // ISO date
}

/* ─── Product (bike or accessory listing) ───────────────────────────────────── */
export interface Product {
  id: string;
  type: 'bike' | 'accessory';
  title: string;
  brand?: string;
  model?: string;
  year?: number;
  priceInRupees: number;
  negotiable?: boolean;
  kmDriven?: number;
  city: string;
  state?: string;
  area?: string;
  description?: string;
  imageUrls: string[];
  thumbnailUrl?: string;
  sellerId: string;
  sellerName?: string;
  isVerifiedSeller?: boolean;
  isFeatured?: boolean;
  status: 'active' | 'sold' | 'paused';
  // Bike-specific
  owners?: number;
  insuranceValidTill?: string;
  registrationNumber?: string;
  manufacturingDate?: string;
  registrationDate?: string;
  invoiceAvailable?: boolean;
  nocAvailable?: boolean;
  registrationCertificate?: string;
  numberPlate?: string;
  features?: string[];
  specifications?: Record<string, string>;
  // Accessory-specific
  category?: string;
  condition?: 'new' | 'like-new' | 'good' | 'fair';
  createdAt: string;
  updatedAt: string;
}

/* ─── Service (mechanic, rental, track day, etc.) ───────────────────────────── */
export interface Service {
  id: string;
  category: ServiceCategory;
  name: string;
  description?: string;
  city: string;
  state?: string;
  area?: string;
  address?: string;
  phone?: string;
  rating?: number;
  reviewCount?: number;
  imageUrls: string[];
  thumbnailUrl?: string;
  tags?: string[];
  openingHours?: {
    days: string;
    hours: string;
  };
  ownerId: string;
  isFeatured?: boolean;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
}

export type ServiceCategory =
  | 'mechanics'
  | 'bike-rentals'
  | 'track-day'
  | 'training-day'
  | 'tyre-shops'
  | 'accessory-stores'
  | 'bike-inspection'
  | 'towing';

/* ─── Chat ──────────────────────────────────────────────────────────────────── */
export interface ChatThread {
  id: string;
  participantIds: string[];
  participantNames: Record<string, string>;
  lastMessage?: string;
  lastMessageAt?: string;
  relatedProductId?: string;
  relatedProductTitle?: string;
  unreadCounts: Record<string, number>;
  createdAt: string;
}

export interface ChatMessage {
  id: string;
  threadId: string;
  senderId: string;
  senderName: string;
  text: string;
  createdAt: string;
  readBy: string[];
}

/* ─── Notification ──────────────────────────────────────────────────────────── */
export interface Notification {
  id: string;
  userId: string;
  title: string;
  body: string;
  type: 'message' | 'sale' | 'system' | 'offer';
  read: boolean;
  relatedId?: string;
  createdAt: string;
}

/* ─── Filter state (listing pages) ─────────────────────────────────────────── */
export interface BikeFilters {
  priceMin?: number;
  priceMax?: number;
  brand?: string;
  kmMax?: number;
  state?: string;
  yearMin?: number;
  owners?: number;
  insurance?: boolean;
  sortBy?: 'newest' | 'price-asc' | 'price-desc' | 'km-asc';
}

export interface AccessoryFilters {
  priceMin?: number;
  priceMax?: number;
  category?: string;
  brand?: string;
  condition?: string;
  sortBy?: 'newest' | 'price-asc' | 'price-desc';
}
