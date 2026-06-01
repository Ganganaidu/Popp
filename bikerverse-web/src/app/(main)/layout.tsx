import { BVTopBar } from '@/components/layout/BVTopBar';
import { BVCategoryRail } from '@/components/layout/BVCategoryRail';
import styles from './layout.module.css';

/**
 * Main layout — wraps all customer-facing pages with the sticky top bar
 * and the category rail. Auth pages use a separate (auth) layout.
 */
export default function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className={styles.shell}>
      <BVTopBar />
      <BVCategoryRail />
      <main className={styles.main}>{children}</main>
    </div>
  );
}
