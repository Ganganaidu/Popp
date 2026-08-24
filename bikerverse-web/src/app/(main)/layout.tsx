import { BVTopBar } from '@/components/layout/BVTopBar';
import styles from './layout.module.css';

export default function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className={styles.shell}>
      <BVTopBar />
      <main className={styles.main}>{children}</main>
    </div>
  );
}
