import type { ButtonHTMLAttributes, ReactNode } from 'react';
import styles from './IconBtn.module.css';

interface IconBtnProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  /** 40 (default top-bar) or 44 (product price card) */
  size?: 40 | 44;
  /** Extra class */
  className?: string;
  /** Active/toggled state — e.g. heart is filled */
  active?: boolean;
}

/**
 * Square icon button — transparent background, 1px --bv-border, 2px radius.
 * Used for: heart, gear, close, arrow prev/next.
 */
export function IconBtn({ children, size = 40, active, className, ...rest }: IconBtnProps) {
  return (
    <button
      className={[styles.iconBtn, active ? styles.active : '', className]
        .filter(Boolean)
        .join(' ')}
      style={{ width: size, height: size }}
      {...rest}
    >
      {children}
    </button>
  );
}
