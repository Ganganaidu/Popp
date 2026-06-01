import type { ReactNode } from 'react';
import { ArrowRightIcon } from './Icons';
import styles from './SectionHead.module.css';

interface SectionHeadProps {
  title: string;
  /** Trailing content — a plain string (e.g. "248 LIVE") or any ReactNode */
  trailing?: ReactNode;
  /** href makes the trailing into a clickable link */
  trailingHref?: string;
}

/**
 * Section header row — H2 title + bottom 1px border + optional trailing link.
 * Used on Home, Listing, and Detail pages.
 * Title: Archivo Narrow 800, 32px, -0.02em, uppercase.
 * Trailing: Mono 11px, text-2 color, with arrow icon.
 */
export function SectionHead({ title, trailing, trailingHref }: SectionHeadProps) {
  return (
    <div className={styles.head}>
      <h2 className={styles.title}>{title}</h2>
      {trailing && (
        trailingHref ? (
          <a href={trailingHref} className={styles.trailing}>
            {trailing}
            <ArrowRightIcon color="var(--bv-text-2)" size={12} />
          </a>
        ) : (
          <span className={styles.trailing}>
            {trailing}
            <ArrowRightIcon color="var(--bv-text-2)" size={12} />
          </span>
        )
      )}
    </div>
  );
}
