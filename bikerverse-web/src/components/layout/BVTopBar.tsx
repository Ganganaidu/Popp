'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Wordmark, IconBtn, Btn, SearchIcon, HeartIcon, GearIcon, MoonIcon, SunIcon } from '@/components/ds';
import { useTheme } from '@/components/ds/ThemeProvider';
import styles from './BVTopBar.module.css';

const NAV_LINKS = [
  { key: 'home',      label: 'Home',       href: '/' },
  { key: 'explore',   label: 'Explore',    href: '/explore' },
  { key: 'sell',      label: 'Sell',       href: '/sell/bike' },
  { key: 'rent',      label: 'Rent',       href: '/services/bike-rentals' },
  { key: 'mechanics', label: 'Mechanics',  href: '/services/mechanics' },
  { key: 'track',     label: 'Track days', href: '/services/track-day' },
  { key: 'chat',      label: 'Chat',       href: '/chat' },
] as const;

interface BVTopBarProps {
  /** Explicitly force an active key — auto-detected from pathname if omitted */
  activeKey?: string;
}

/**
 * BVTopBar — 64px sticky top navigation bar.
 * Spec: height 64px, bg --bv-bg, bottom border 1px --bv-border, padding 0 32px.
 * Contents: Wordmark | 1px divider | nav links | spacer | search | heart | settings | theme toggle | sign in
 */
export function BVTopBar({ activeKey }: BVTopBarProps) {
  const pathname = usePathname();
  const { theme, toggle } = useTheme();

  function resolveActive(): string {
    if (activeKey) return activeKey;
    if (pathname === '/') return 'home';
    if (pathname.startsWith('/sell') || pathname.startsWith('/list-service')) return 'sell';
    if (pathname.startsWith('/services/bike-rentals')) return 'rent';
    if (pathname.startsWith('/services/mechanics')) return 'mechanics';
    if (pathname.startsWith('/services/track')) return 'track';
    if (pathname.startsWith('/chat')) return 'chat';
    return 'explore';
  }

  const active = resolveActive();

  return (
    <header className={styles.bar}>
      <div className={styles.inner}>
        {/* Wordmark */}
        <Link href="/" className={styles.wordmarkLink} aria-label="Bikerverse home">
          <Wordmark size={20} />
        </Link>

        {/* 1px vertical divider */}
        <div className={styles.divider} aria-hidden />

        {/* Nav links */}
        <nav className={styles.nav} aria-label="Main navigation">
          {NAV_LINKS.map(({ key, label, href }) => (
            <Link
              key={key}
              href={href}
              className={[styles.navLink, active === key ? styles.navLinkActive : ''].join(' ')}
            >
              {label}
              {active === key && <span className={styles.activeBar} aria-hidden />}
            </Link>
          ))}
        </nav>

        {/* Right side */}
        <div className={styles.right}>
          {/* Search */}
          <button className={styles.searchField} aria-label="Search (⌘K)">
            <SearchIcon color="var(--bv-text-3)" size={16} />
            <span className={styles.searchPlaceholder}>Search bikes, gear, mechanics…</span>
            <span className={styles.kbdHint}>⌘K</span>
          </button>

          {/* Heart */}
          <IconBtn size={40} aria-label="Saved items">
            <HeartIcon color="var(--bv-text)" size={16} />
          </IconBtn>

          {/* Settings / account */}
          <IconBtn size={40} aria-label="Account settings">
            <GearIcon color="var(--bv-text)" size={16} />
          </IconBtn>

          {/* Theme toggle */}
          <IconBtn
            size={40}
            onClick={toggle}
            aria-label={theme === 'dark' ? 'Switch to light theme' : 'Switch to dark theme'}
          >
            {theme === 'dark'
              ? <SunIcon color="var(--bv-text)" size={16} />
              : <MoonIcon color="var(--bv-text)" size={16} />
            }
          </IconBtn>

          {/* Sign in */}
          <Btn kind="primary" size="sm" href="/login">
            Sign in
          </Btn>
        </div>
      </div>
    </header>
  );
}
