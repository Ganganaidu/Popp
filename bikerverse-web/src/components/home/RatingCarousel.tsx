'use client';

import { useState, useEffect, useCallback } from 'react';
import { Eyebrow } from '@/components/ds/Eyebrow';
import { IconBtn } from '@/components/ds/IconBtn';
import { ArrowRightIcon } from '@/components/ds/Icons';
import styles from './RatingCarousel.module.css';

/* ─── Data (verbatim from design handoff README §4.2.B) ───────────────────── */
const TESTIMONIALS = [
  { name: 'Arjun Morison',  location: 'Pune',       stars: 5, tag: 'SOLD A BIKE',       quote: 'Sold my Triumph in 4 days. Verified buyer, smooth handover, no haggling drama.' },
  { name: 'Thomas Silva',   location: 'Bengaluru',   stars: 5, tag: 'TRACK DAY',         quote: 'Booked a track day at MMRT through Bikerverse. Slot confirmation was instant.' },
  { name: 'Priya Nair',     location: 'Kochi',       stars: 5, tag: 'FOUND A MECHANIC',  quote: 'Found a Ducati specialist near me. Service history check + ECU tune in one shop.' },
  { name: 'Karan Mehta',    location: 'Delhi NCR',   stars: 4, tag: 'RENTED A BIKE',     quote: 'Rented a Kawasaki for the Leh trip. Bike was track-prepped, papers in order.' },
  { name: 'Ishaan Roy',     location: 'Mumbai',      stars: 5, tag: 'BOUGHT A BIKE',     quote: 'Bought my Panigale here. The verified-seller filter actually means something.' },
  { name: 'Neha Kulkarni',  location: 'Hyderabad',   stars: 5, tag: 'SOLD GEAR',         quote: 'Listed my old gear and it cleared in a week. Photos + auto-pricing helped.' },
] as const;

const VISIBLE    = 3;
const MAX_INDEX  = TESTIMONIALS.length - VISIBLE;  // 3
const AUTO_MS    = 3500;

function initials(name: string): string {
  return name.split(' ').map((w) => w[0]).join('');
}

/**
 * RatingCarousel — auto-advances every 3.5s, pauses on hover.
 * 3 cards visible at desktop, slides with CSS transform.
 * Spec transform: translateX(calc(-i * (33.333% - 14px) - i*20px))
 * Progress bar scales width with currentIndex / (max + 1).
 */
export function RatingCarousel() {
  const [index,  setIndex]  = useState(0);
  const [paused, setPaused] = useState(false);

  const next = useCallback(() => setIndex((i) => (i >= MAX_INDEX ? 0 : i + 1)), []);
  const prev = useCallback(() => setIndex((i) => (i <= 0 ? MAX_INDEX : i - 1)), []);

  /* Auto-advance */
  useEffect(() => {
    if (paused) return;
    const t = setInterval(next, AUTO_MS);
    return () => clearInterval(t);
  }, [paused, next]);

  /* CSS transform — exactly matches the JSX formula */
  const translateX = `calc(${-index} * (33.333% - 14px) - ${index * 20}px)`;

  /* Progress bar width */
  const progressWidth = `${((index + 1) / (MAX_INDEX + 1)) * 100}%`;

  return (
    <section
      className={styles.section}
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
    >
      {/* Header row */}
      <div className={styles.header}>
        <div>
          <Eyebrow>Word from the saddle</Eyebrow>
          <h2 className={styles.h2}>WHAT RIDERS SAY</h2>
        </div>
        <div className={styles.arrows}>
          <IconBtn
            size={40}
            onClick={prev}
            aria-label="Previous testimonial"
            style={{ transform: 'rotate(180deg)' }}
          >
            <ArrowRightIcon color="var(--bv-text)" size={14} />
          </IconBtn>
          <IconBtn size={40} onClick={next} aria-label="Next testimonial">
            <ArrowRightIcon color="var(--bv-text)" size={14} />
          </IconBtn>
        </div>
      </div>

      {/* Sliding rail */}
      <div className={styles.viewport}>
        <div
          className={styles.rail}
          style={{ transform: `translateX(${translateX})` }}
        >
          {TESTIMONIALS.map((t, k) => (
            <div key={k} className={styles.card}>
              {/* Activity tag badge */}
              <span className={styles.tagBadge}>{t.tag}</span>

              {/* Avatar + name block */}
              <div className={styles.avatarRow}>
                <div className={styles.avatar} aria-hidden>
                  {initials(t.name)}
                </div>
                <div>
                  <div className={styles.authorName}>{t.name}</div>
                  <div className={styles.authorLocation}>{t.location.toUpperCase()}</div>
                </div>
              </div>

              {/* Stars */}
              <div className={styles.stars} aria-label={`${t.stars} out of 5 stars`}>
                {Array.from({ length: 5 }).map((_, i) => (
                  <span
                    key={i}
                    className={i < t.stars ? styles.starFilled : styles.starEmpty}
                  >
                    ★
                  </span>
                ))}
              </div>

              {/* Quote */}
              <p className={styles.quote}>"{t.quote}"</p>
            </div>
          ))}
        </div>
      </div>

      {/* Progress bar */}
      <div className={styles.progressTrack}>
        <div
          className={styles.progressFill}
          style={{ width: progressWidth }}
        />
      </div>
    </section>
  );
}
