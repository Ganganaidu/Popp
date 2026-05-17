import Link from 'next/link';
import styles from './Breadcrumb.module.css';

export interface BreadcrumbItem {
  label: string;
  href?: string;
}

interface BreadcrumbProps {
  items: BreadcrumbItem[];
}

/**
 * BV Breadcrumb — JetBrains Mono 11px 0.14em, text-3.
 * Last segment rendered in --bv-green (active page).
 * Separator: " / "
 */
export function Breadcrumb({ items }: BreadcrumbProps) {
  return (
    <nav aria-label="breadcrumb" className={styles.nav}>
      {items.map((item, i) => {
        const isLast = i === items.length - 1;
        return (
          <span key={i} className={styles.segment}>
            {i > 0 && <span className={styles.sep}>/</span>}
            {isLast || !item.href ? (
              <span className={isLast ? styles.active : styles.crumb}>{item.label}</span>
            ) : (
              <Link href={item.href} className={styles.crumb}>{item.label}</Link>
            )}
          </span>
        );
      })}
    </nav>
  );
}
