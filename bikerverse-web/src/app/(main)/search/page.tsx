'use client';

import { useState, useRef, useEffect } from 'react';
import styles from './page.module.css';
import { BikeCard, type BikeCardProps } from '@/components/cards/BikeCard';
import { GearCard, type GearCardProps } from '@/components/cards/GearCard';
import { ShopRow, type ShopRowProps } from '@/components/cards/ShopRow';

/* ---- Seed data ---- */
const SEED_BIKES: BikeCardProps[] = [
  { id: 'b1', name: 'Triumph Street Twin', priceInRupees: 700000, kmDriven: 12000, city: 'Hyderabad', year: 2021, featured: true },
  { id: 'b2', name: 'KTM 390 Duke', priceInRupees: 280000, kmDriven: 8500, city: 'Bengaluru', year: 2022, isNew: true },
];

const SEED_GEAR: GearCardProps[] = [
  { id: 'g1', name: 'Arai RX-7V Helmet', priceInRupees: 45000 },
  { id: 'g2', name: 'Alpinestars SMX-6 Boots', priceInRupees: 18000 },
];

const SEED_SERVICES: ShopRowProps[] = [
  { id: 's1', name: 'GarageOne Performance', city: 'Hyderabad', rating: '4.8', tags: ['Tuning', 'Suspension', 'Brakes'] },
];

const RECENT_SEARCHES = ['Triumph', 'KTM 390', 'Arai helmet', 'Hyderabad bikes', 'Royal Enfield'];

const CATEGORIES = [
  { icon: '🏍️', label: 'Bikes' },
  { icon: '⛑️', label: 'Helmets' },
  { icon: '🧤', label: 'Gear' },
  { icon: '🔧', label: 'Mechanics' },
  { icon: '🎨', label: 'Modifiers' },
  { icon: '🛒', label: 'Accessories' },
];

function isMac(): boolean {
  if (typeof navigator === 'undefined') return false;
  return navigator.platform.toUpperCase().includes('MAC');
}

export default function SearchPage() {
  const [query, setQuery] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  // ⌘K / Ctrl+K shortcut
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'k' && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        inputRef.current?.focus();
      }
    }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  const trimmed = query.trim();
  const hasQuery = trimmed.length > 0;

  // Simple filter: match any non-empty query against name
  const bikes = hasQuery
    ? SEED_BIKES.filter((b) => b.name.toLowerCase().includes(trimmed.toLowerCase()))
    : [];
  const gear = hasQuery
    ? SEED_GEAR.filter((g) => g.name.toLowerCase().includes(trimmed.toLowerCase()))
    : [];
  const services = hasQuery
    ? SEED_SERVICES.filter((s) => s.name.toLowerCase().includes(trimmed.toLowerCase()))
    : [];

  // Show all seed results for any non-empty query (demo behavior)
  const showBikes = hasQuery ? SEED_BIKES : [];
  const showGear = hasQuery ? SEED_GEAR : [];
  const showServices = hasQuery ? SEED_SERVICES : [];
  const hasResults = showBikes.length > 0 || showGear.length > 0 || showServices.length > 0;

  const shortcutLabel = isMac() ? '⌘K' : 'Ctrl+K';

  return (
    <div className={styles.page}>
      <h1 className={styles.title}>Search</h1>

      {/* Search bar */}
      <div className={styles.searchWrap}>
        <span className={styles.searchIcon}>
          <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
            <circle cx="8" cy="8" r="5.5" stroke="currentColor" strokeWidth="1.5" />
            <path d="M12.5 12.5L16 16" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
          </svg>
        </span>
        <input
          ref={inputRef}
          className={styles.searchInput}
          type="text"
          placeholder="Search bikes, gear, services…"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        {!hasQuery && (
          <span className={styles.shortcutHint}>{shortcutLabel}</span>
        )}
        {hasQuery && (
          <button className={styles.clearBtn} onClick={() => setQuery('')} aria-label="Clear search">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M4 4L12 12M12 4L4 12" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
            </svg>
          </button>
        )}
      </div>

      {/* Results */}
      {hasQuery && hasResults && (
        <>
          {showBikes.length > 0 && (
            <div className={styles.section}>
              <p className={styles.sectionHead}>Bikes ({showBikes.length})</p>
              <div className={styles.bikeGrid}>
                {showBikes.map((b) => (
                  <BikeCard key={b.id} {...b} />
                ))}
              </div>
            </div>
          )}

          {showGear.length > 0 && (
            <div className={styles.section}>
              <p className={styles.sectionHead}>Accessories ({showGear.length})</p>
              <div className={styles.gearGrid}>
                {showGear.map((g) => (
                  <GearCard key={g.id} {...g} />
                ))}
              </div>
            </div>
          )}

          {showServices.length > 0 && (
            <div className={styles.section}>
              <p className={styles.sectionHead}>Services ({showServices.length})</p>
              <div className={styles.serviceList}>
                {showServices.map((s) => (
                  <ShopRow key={s.id} {...s} />
                ))}
              </div>
            </div>
          )}
        </>
      )}

      {/* No results */}
      {hasQuery && !hasResults && (
        <div className={styles.noResults}>
          <p className={styles.noResultsLabel}>No results for &ldquo;{trimmed}&rdquo;</p>
        </div>
      )}

      {/* Initial state */}
      {!hasQuery && (
        <>
          <div className={styles.recentSearches}>
            <p className={styles.sectionHead}>Recent searches</p>
            <div className={styles.chips}>
              {RECENT_SEARCHES.map((s) => (
                <button key={s} className={styles.chip} onClick={() => setQuery(s)}>
                  {s}
                </button>
              ))}
            </div>
          </div>

          <div>
            <p className={styles.sectionHead}>Explore categories</p>
            <div className={styles.categoryGrid}>
              {CATEGORIES.map((cat) => (
                <button key={cat.label} className={styles.categoryTile} onClick={() => setQuery(cat.label)}>
                  <span className={styles.categoryIcon}>{cat.icon}</span>
                  <span className={styles.categoryLabel}>{cat.label}</span>
                </button>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
