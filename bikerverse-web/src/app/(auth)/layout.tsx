import Link from 'next/link';
import { Wordmark } from '@/components/ds';
import styles from './layout.module.css';

/**
 * Auth layout — centered card, no top bar or category rail.
 * Wordmark at top links home. Dark/light surface card.
 */
export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className={styles.shell}>
      <header className={styles.header}>
        <Link href="/" aria-label="Back to Bikerverse home">
          <Wordmark size={28} />
        </Link>
      </header>
      <main className={styles.main}>
        <div className={styles.card}>{children}</div>
      </main>
    </div>
  );
}
