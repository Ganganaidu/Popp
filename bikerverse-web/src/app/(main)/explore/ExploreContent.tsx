'use client';

import { useState, useEffect } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { BikeCard } from '@/components/cards/BikeCard';
import { ShopRow } from '@/components/cards/ShopRow';
import {
  getLatestProducts,
  getShopServices,
  getEventServices,
  getAllServices,
} from '@/lib/firebase/firestore';
import type { FirestoreProduct, FirestoreService } from '@/lib/types';
import styles from './page.module.css';

// ── Navigation maps ────────────────────────────────────────────────────────

const CATEGORY_TO_SLUG: Record<string, string> = {
  'Find Mechanic':  'mechanics',
  'Bike Rentals':   'bike-rentals',
  'Track day':      'track-day',
  'Training day':   'training-day',
  'Accessory Store':'accessory-store',
  'Tyre Shops':     'tyre-shops',
  'Towing Service': 'towing',
};

// ── Helpers ────────────────────────────────────────────────────────────────

function getServiceImage(s: FirestoreService): string | undefined {
  if (Array.isArray(s.promoImageUrls) && s.promoImageUrls[0]) return s.promoImageUrls[0];
  if (typeof s.shopImageUrls === 'string' && s.shopImageUrls) return s.shopImageUrls;
  if (Array.isArray(s.shopImageUrls) && (s.shopImageUrls as string[])[0]) return (s.shopImageUrls as string[])[0];
  return undefined;
}

function getServiceTitle(s: FirestoreService): string {
  return s.businessTitle ?? s.contactName ?? '';
}

function getServiceLocation(s: FirestoreService): string {
  return [s.area, s.city].filter(Boolean).join(', ');
}

function getEventBadge(s: FirestoreService): string {
  if (s.category === 'Track day')    return 'TRACK';
  if (s.category === 'Training day') return 'TRAIN';
  if (s.category === 'Bike Rentals') return 'RIDE';
  return s.category.substring(0, 5).toUpperCase();
}

function parseEventDate(s: FirestoreService): { day: string; month: string } | null {
  const raw = s.eventStartDate ?? s.createdAt;
  if (!raw) return null;
  const d = new Date(raw);
  if (isNaN(d.getTime())) return null;
  const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
  return { day: String(d.getDate()), month: months[d.getMonth()] };
}

// ── Static category data ───────────────────────────────────────────────────

type Shortcut = {
  label: string;
  subtitle: string;
  image: string;
  href: string;
  colorClass: string;
};

// Images from the "Would you like to" ActionGrid on the home page
const SHORTCUTS: Shortcut[] = [
  { label: 'PREMIUM BIKES',    subtitle: '248 LIVE',    image: '/assets/actions/sell_your_bike.png',       href: '/bikes',                          colorClass: 'shortcutGreen'  },
  { label: 'PROTECTION GEAR',  subtitle: '1,158 ITEMS', image: '/assets/actions/sell_your_accessory.png',  href: '/accessories?cat=protection-gear', colorClass: 'shortcutSalmon' },
  { label: 'ACCESSORIES',      subtitle: '833 ITEMS',   image: '/assets/actions/accessory_store.png',      href: '/accessories?cat=luggage',         colorClass: 'shortcutBlue'   },
  { label: 'MECHANICS',        subtitle: '340 SHOPS',   image: '/assets/actions/find_mechanic.png',        href: '/services/mechanics',              colorClass: 'shortcutSage'   },
  { label: 'TRACK & TRAINING', subtitle: '21 SLOTS',    image: '/assets/actions/track_training_day.png',   href: '/services/track-day',              colorClass: 'shortcutRose'   },
  { label: 'RENTALS',          subtitle: '84 BIKES',    image: '/assets/actions/bike_rentals.png',         href: '/services/bike-rentals',           colorClass: 'shortcutPurple' },
];

type CategoryItem = { name: string; count: number; href: string };
type CategoryGroup = { header: string; colorClass: string; items: CategoryItem[] };

const ALL_CATEGORY_GROUPS: CategoryGroup[] = [
  {
    header: 'MARKETPLACE',
    colorClass: 'groupGreen',
    items: [
      { name: 'Premium bikes',       count: 248, href: '/bikes' },
      { name: 'Superbikes',          count:  96, href: '/bikes?sub=superbikes' },
      { name: 'Cruisers',            count:  74, href: '/bikes?sub=cruisers' },
      { name: 'Adventure & touring', count:  61, href: '/bikes?sub=adventure' },
      { name: 'Commuters',           count: 312, href: '/bikes?sub=commuters' },
      { name: 'Vintage & classics',  count:  38, href: '/bikes?sub=vintage' },
      { name: 'Scooters',            count: 129, href: '/bikes?sub=scooters' },
      { name: 'Spare parts',         count: 806, href: '/accessories?cat=other' },
    ],
  },
  {
    header: 'PROTECTION GEAR',
    colorClass: 'groupSalmon',
    items: [
      { name: 'Helmets',             count: 412, href: '/accessories?cat=protection-gear&sub=Helmets' },
      { name: 'Riding jackets',      count: 188, href: '/accessories?cat=protection-gear&sub=Riding+Jackets' },
      { name: 'Riding gloves',       count: 236, href: '/accessories?cat=protection-gear&sub=Riding+Gloves' },
      { name: 'Riding pants',        count:  94, href: '/accessories?cat=protection-gear&sub=Riding+Pants' },
      { name: 'Riding boots',        count: 118, href: '/accessories?cat=protection-gear&sub=Riding+Boots' },
      { name: 'Base layers',         count:  47, href: '/accessories?cat=protection-gear&sub=Base+layers' },
      { name: 'Other protectors',    count:  63, href: '/accessories?cat=protection-gear&sub=Other+Protectors' },
    ],
  },
  {
    header: 'LUGGAGE & ACCESSORIES',
    colorClass: 'groupBlue',
    items: [
      { name: 'Tank bags',           count:  72, href: '/accessories?cat=luggage&sub=Tank+Bags' },
      { name: 'Saddle & tail bags',  count:  88, href: '/accessories?cat=luggage&sub=Saddle+Bags' },
      { name: 'Lights & mounts',     count: 154, href: '/accessories?cat=lights-mounts' },
      { name: 'Phone mounts',        count:  96, href: '/accessories?cat=lights-mounts&sub=Phone+Mounts' },
      { name: 'Electronic accessories', count: 131, href: '/accessories?cat=electronics' },
      { name: 'Universal fit',       count: 205, href: '/accessories?cat=universal' },
      { name: 'Care & cleaning',     count:  77, href: '/accessories?cat=other' },
    ],
  },
  {
    header: 'SERVICES',
    colorClass: 'groupPurple',
    items: [
      { name: 'Find mechanic',       count: 340, href: '/services/mechanics' },
      { name: 'Tyre shops',          count: 126, href: '/services/tyre-shops' },
      { name: 'Towing service',      count:  58, href: '/services/towing' },
      { name: 'Detailing studios',   count:  44, href: '/services/mechanics' },
      { name: 'Custom fabrication',  count:  31, href: '/services/mechanics' },
      { name: 'Insurance & RTO',     count:  22, href: '/services/inspection' },
      { name: 'Accessory stores',    count: 167, href: '/services/accessory-store' },
    ],
  },
  {
    header: 'RIDE & LEARN',
    colorClass: 'groupOrange',
    items: [
      { name: 'Bike rentals',        count:  84, href: '/services/bike-rentals' },
      { name: 'Track days',          count:  12, href: '/services/track-day' },
      { name: 'Training days',       count:   9, href: '/services/training-day' },
      { name: 'Group rides',         count:  26, href: '/services/bike-rentals' },
      { name: 'Riding clubs',        count:  41, href: '/services/bike-rentals' },
      { name: 'Events calendar',     count:  18, href: '/services/track-day' },
    ],
  },
];

// ── Component ──────────────────────────────────────────────────────────────

export function ExploreContent() {
  const router = useRouter();

  const [trending, setTrending]       = useState<FirestoreProduct[]>([]);
  const [shops, setShops]             = useState<FirestoreService[]>([]);
  const [events, setEvents]           = useState<FirestoreService[]>([]);
  const [allServices, setAllServices] = useState<FirestoreService[]>([]);
  const [loaded, setLoaded]           = useState(false);

  useEffect(() => {
    Promise.all([
      getLatestProducts(12),
      getShopServices(8),
      getEventServices(8),
      getAllServices(30),
    ]).then(([t, s, e, a]) => {
      setTrending(t);
      setShops(s);
      setEvents(e);
      setAllServices(a);
      setLoaded(true);
    });
  }, []);

  // Curated catalogue figures — consistent with the static counts used on the
  // shortcut cards and category columns below.
  const statsListings = 12480;
  const statsShops    = 340;
  const statsEvents   = 96;

  const totalCategories = ALL_CATEGORY_GROUPS.reduce((acc, g) => acc + g.items.length, 0);

  // Filter allServices to exclude IDs already shown in Shops Near You or Ride Calendar
  const shownIds = new Set([...shops.map(s => s.id), ...events.map(e => e.id)]);
  const uniqueServices = allServices.filter(s => !shownIds.has(s.id));

  return (
    <div className={styles.page}>

      {/* ── Hero ─────────────────────────────────────────────────────── */}
      <section className={styles.hero}>
        <div className={styles.heroInner}>
          <div className={styles.heroTop}>
            <div className={styles.heroLeft}>
              <p className={styles.eyebrow}>EXPLORE</p>
              <h1 className={styles.heroTitle}>
                SEARCH THE <span className={styles.heroAccent}>WHOLE GARAGE</span>
              </h1>
            </div>

            <div className={styles.statsRow}>
              <div className={styles.stat}>
                <span className={styles.statValue}>{statsListings.toLocaleString('en-IN')}</span>
                <span className={styles.statLabel}>LISTINGS</span>
              </div>
              <div className={styles.stat}>
                <span className={styles.statValue}>{statsShops}</span>
                <span className={styles.statLabel}>VERIFIED SHOPS</span>
              </div>
              <div className={styles.stat}>
                <span className={styles.statValue}>{statsEvents}</span>
                <span className={styles.statLabel}>RIDES &amp; EVENTS</span>
              </div>
            </div>
          </div>

          {/* Search bar */}
          <div
            className={styles.searchBar}
            role="button"
            tabIndex={0}
            onClick={() => router.push('/search')}
            onKeyDown={(e) => e.key === 'Enter' && router.push('/search')}
          >
            <svg className={styles.searchIcon} width="18" height="18" viewBox="0 0 18 18" fill="none">
              <circle cx="8" cy="8" r="5.5" stroke="currentColor" strokeWidth="1.5" />
              <path d="M12.5 12.5L16 16" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
            </svg>
            <span className={styles.searchPlaceholder}>
              Search bikes, gear, mechanics, track days, riders...
            </span>
            <span className={styles.searchHint}>⌘K</span>
          </div>
        </div>
      </section>

      {/* ── All content below hero ────────────────────────────────────── */}
      <div className={styles.inner}>

      {/* ── Category shortcuts ────────────────────────────────────────── */}
      <section className={styles.section}>
        <div className={styles.shortcutGrid}>
          {SHORTCUTS.map((c) => (
            <Link key={c.label} href={c.href} className={`${styles.shortcutCard} ${styles[c.colorClass]}`}>
              <div className={styles.shortcutImageWrap}>
                <Image
                  src={c.image}
                  alt={c.label}
                  width={64}
                  height={64}
                  className={styles.shortcutImage}
                />
              </div>
              <div className={styles.shortcutText}>
                <span className={styles.shortcutLabel}>{c.label}</span>
                <span className={styles.shortcutCount}>{c.subtitle}</span>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* ── All Categories ────────────────────────────────────────────── */}
      <section className={styles.section}>
        <div className={styles.sectionHead}>
          <h2 className={styles.sectionTitle}>ALL CATEGORIES</h2>
          <Link href="/bikes" className={styles.sectionLink}>
            {totalCategories} CATEGORIES →
          </Link>
        </div>
        <div className={styles.categoryGrid}>
          {ALL_CATEGORY_GROUPS.map((g) => (
            <div key={g.header} className={styles.categoryColumn}>
              <span className={`${styles.columnHeader} ${styles[g.colorClass]}`}>{g.header}</span>
              {g.items.map((item) => (
                <Link key={item.name} href={item.href} className={styles.columnItem}>
                  <span className={styles.columnItemName}>{item.name}</span>
                  <span className={styles.columnCount}>{item.count}</span>
                </Link>
              ))}
            </div>
          ))}
        </div>
      </section>

      {/* ── Trending Now ──────────────────────────────────────────────── */}
      {loaded && trending.length > 0 && (
        <section className={styles.section}>
          <div className={styles.sectionHead}>
            <h2 className={styles.sectionTitle}>TRENDING NOW</h2>
            <Link href="/bikes" className={styles.sectionLink}>
              {trending.length} LIVE →
            </Link>
          </div>
          <div className={styles.trendingGrid}>
            {trending.slice(0, 4).map((p, i) => (
              <div key={p.id} className={styles.trendingCard}>
                <BikeCard
                  id={p.id}
                  name={`${p.brandName} ${p.modelName}`}
                  priceInRupees={parseFloat(p.expectedPrice ?? p.price ?? '0') || 0}
                  kmDriven={parseInt(p.kmDriven ?? '0', 10) || 0}
                  city={p.city}
                  year={p.mfgDate ? new Date(p.mfgDate).getFullYear() : ''}
                  imageUrl={p.imageUrl ?? p.thumbImageUrls?.[0]}
                  featured={i === 0}
                />
              </div>
            ))}
          </div>
        </section>
      )}

      {/* ── Shops Near You + Ride Calendar (side-by-side) ─────────────── */}
      {loaded && (shops.length > 0 || events.length > 0) && (
        <div className={styles.twoColSection}>
          {shops.length > 0 && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <h2 className={styles.sectionTitle}>SHOPS NEAR YOU</h2>
                <Link href="/services/mechanics" className={styles.sectionLinkGreen}>SEE ALL →</Link>
              </div>
              <div className={styles.shopsList}>
                {shops.slice(0, 5).map((s) => (
                  <ShopRow
                    key={s.id}
                    id={s.id}
                    name={getServiceTitle(s)}
                    city={getServiceLocation(s)}
                    rating={s.rating ?? '—'}
                    tags={s.tags ?? []}
                    category={CATEGORY_TO_SLUG[s.category] ?? 'mechanics'}
                    imageUrl={getServiceImage(s)}
                  />
                ))}
              </div>
            </section>
          )}

          {events.length > 0 && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <h2 className={styles.sectionTitle}>RIDE CALENDAR</h2>
                <Link href="/services/track-day" className={styles.sectionLink}>NEXT 30 DAYS →</Link>
              </div>
              <div className={styles.calendarList}>
                {events.slice(0, 5).map((e) => {
                  const date  = parseEventDate(e);
                  const badge = getEventBadge(e);
                  const slug  = CATEGORY_TO_SLUG[e.category] ?? 'track-day';
                  return (
                    <Link key={e.id} href={`/services/${slug}/${e.id}`} className={styles.calendarItem}>
                      {date ? (
                        <div className={styles.calendarDate}>
                          <span className={styles.calendarDay}>{date.day}</span>
                          <span className={styles.calendarMonth}>{date.month}</span>
                        </div>
                      ) : (
                        <div className={styles.calendarDateEmpty} />
                      )}
                      <div className={styles.calendarBody}>
                        <span className={styles.calendarTitle}>{getServiceTitle(e)}</span>
                        <span className={styles.calendarLoc}>{getServiceLocation(e)}</span>
                      </div>
                      <span className={`${styles.calendarBadge} ${badge === 'TRACK' ? styles.badgeTrack : styles.badgeTrain}`}>
                        {badge}
                      </span>
                    </Link>
                  );
                })}
              </div>
            </section>
          )}
        </div>
      )}

      {/* ── All Services (only services not already shown above) ──────── */}
      {loaded && uniqueServices.length > 0 && (
        <section className={styles.section}>
          <div className={styles.sectionHead}>
            <h2 className={styles.sectionTitle}>ALL SERVICES</h2>
          </div>
          <div className={styles.shopsList}>
            {uniqueServices.map((s) => (
              <ShopRow
                key={s.id}
                id={s.id}
                name={getServiceTitle(s)}
                city={getServiceLocation(s)}
                rating={s.rating ?? '—'}
                tags={s.tags ?? []}
                category={CATEGORY_TO_SLUG[s.category] ?? 'mechanics'}
                imageUrl={getServiceImage(s)}
              />
            ))}
          </div>
        </section>
      )}

      {/* Loading skeleton */}
      {!loaded && (
        <div className={styles.loadingState}>
          <span className={styles.loadingDot} />
          <span className={styles.loadingDot} />
          <span className={styles.loadingDot} />
        </div>
      )}

      </div>{/* /inner */}
    </div>
  );
}
