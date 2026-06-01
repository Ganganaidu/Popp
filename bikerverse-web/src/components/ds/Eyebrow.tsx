import type { CSSProperties, ReactNode } from 'react';
import styles from './Eyebrow.module.css';

interface EyebrowProps {
  children: ReactNode;
  /** Color override. Defaults to --bv-green. Pass --bv-text-3 for muted variant. */
  color?: string;
  className?: string;
  style?: CSSProperties;
}

/**
 * Eyebrow label — JetBrains Mono 11px, 0.18em letter-spacing, uppercase.
 * Used above every section heading and in product detail metadata lines.
 */
export function Eyebrow({ children, color, className, style }: EyebrowProps) {
  return (
    <div
      className={[styles.eyebrow, className].filter(Boolean).join(' ')}
      style={{ color: color ?? 'var(--bv-green)', ...style }}
    >
      {children}
    </div>
  );
}
