'use client';

import Link from 'next/link';
import Image from 'next/image';
import { useRef, useEffect, useState } from 'react';
import { Eyebrow } from '@/components/ds/Eyebrow';
import styles from './ActionGrid.module.css';

/**
 * All 10 categories from Flutter's popServiceItemList.
 * Colors sourced from pop_service_item.dart.
 */
const TILES = [
  {
    verb: 'SELL',
    noun: 'Bike',
    n: '01',
    href: '/sell/bike',
    image: '/assets/actions/sell_your_bike.png',
    color: null,          // featured — uses --bv-green
    featured: true,
  },
  {
    verb: 'SELL',
    noun: 'Accessory',
    n: '02',
    href: '/sell/accessory',
    image: '/assets/actions/sell_your_accessory.png',
    color: '#1565C0',     // Flutter: Blue
    featured: false,
  },
  {
    verb: 'LIST',
    noun: 'Business',
    n: '03',
    href: '/list-service',
    image: '/assets/actions/list_your_business.png',
    color: '#6A0DAD',     // Flutter: Purple
    featured: false,
  },
  {
    verb: 'FIND',
    noun: 'Mechanic',
    n: '04',
    href: '/services/mechanics',
    image: '/assets/actions/find_mechanic.png',
    color: '#BF360C',     // Flutter: Deep Orange
    featured: false,
  },
  {
    verb: 'BOOK',
    noun: 'Track day',
    n: '05',
    href: '/services/track-day',
    image: '/assets/actions/track_training_day.png',
    color: '#B71C1C',     // Flutter: Red
    featured: false,
  },
  {
    verb: 'RENT',
    noun: 'Super bike',
    n: '06',
    href: '/services/bike-rentals',
    image: '/assets/actions/bike_rentals.png',
    color: '#37474F',     // Flutter: Blue Grey
    featured: false,
  },
  {
    verb: 'INSPECT',
    noun: 'Super bike',
    n: '07',
    href: '/services/inspection',
    image: '/assets/actions/premium_bike_inspection.png',
    color: '#064302',     // Flutter: Dark Green
    featured: false,
  },
  {
    verb: 'TYRE',
    noun: 'Shops',
    n: '08',
    href: '/services/tyre-shops',
    image: '/assets/actions/tyre_shops.png',
    color: '#0D47A1',     // Flutter: Blue (darker)
    featured: false,
  },
  {
    verb: 'ACCESSORY',
    noun: 'Store',
    n: '09',
    href: '/services/accessory-store',
    image: '/assets/actions/accessory_store.png',
    color: '#4A0072',     // Flutter: Deep Purple
    featured: false,
  },
  {
    verb: 'TOWING',
    noun: 'Service',
    n: '10',
    href: '/services/towing',
    image: '/assets/actions/towing_service.png',
    color: '#3D5502',     // Flutter: Olive Green
    featured: false,
  },
] as const;

export function ActionGrid() {
  const scrollRef = useRef<HTMLDivElement>(null);
  const [canLeft, setCanLeft] = useState(false);
  const [canRight, setCanRight] = useState(true);

  const updateArrows = () => {
    const el = scrollRef.current;
    if (!el) return;
    setCanLeft(el.scrollLeft > 4);
    setCanRight(el.scrollLeft < el.scrollWidth - el.clientWidth - 4);
  };

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    updateArrows();
    el.addEventListener('scroll', updateArrows, { passive: true });
    const ro = new ResizeObserver(updateArrows);
    ro.observe(el);
    return () => {
      el.removeEventListener('scroll', updateArrows);
      ro.disconnect();
    };
  }, []);

  const scroll = (dir: 'left' | 'right') => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollBy({ left: dir === 'right' ? 360 : -360, behavior: 'smooth' });
  };

  return (
    <section className={styles.section}>
      {/* Header */}
      <div className={styles.header}>
        <Eyebrow>Would you like to</Eyebrow>
        <span className={styles.label}>10 WAYS IN</span>
      </div>

      {/* Scroll track */}
      <div className={styles.track}>
        {canLeft && (
          <button
            className={`${styles.navBtn} ${styles.navBtnLeft}`}
            onClick={() => scroll('left')}
            aria-label="Scroll left"
          >
            ‹
          </button>
        )}

        <div ref={scrollRef} className={styles.scroller}>
          {TILES.map(({ verb, noun, n, href, image, color, featured }) => (
            <Link
              key={n}
              href={href}
              className={[styles.tile, featured ? styles.tileFeatured : ''].join(' ')}
              style={!featured && color ? { '--tile-color': color } as React.CSSProperties : undefined}
            >
              {/* Top row */}
              <div className={styles.topRow}>
                <span className={styles.index}>/{n}</span>
                <span className={styles.arrow} aria-hidden>→</span>
              </div>

              {/* Centred icon image */}
              <div className={styles.imageWrap}>
                <Image
                  src={image}
                  alt={`${verb} ${noun}`}
                  width={110}
                  height={110}
                  className={styles.image}
                />
              </div>

              {/* Text */}
              <div className={styles.textBlock}>
                <span className={styles.verb}>{verb}</span>
                <span className={styles.noun}>{noun}</span>
              </div>
            </Link>
          ))}
        </div>

        {canRight && (
          <button
            className={`${styles.navBtn} ${styles.navBtnRight}`}
            onClick={() => scroll('right')}
            aria-label="Scroll right"
          >
            ›
          </button>
        )}
      </div>
    </section>
  );
}
