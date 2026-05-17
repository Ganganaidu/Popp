import type { ButtonHTMLAttributes, ReactNode, CSSProperties } from 'react';
import styles from './Btn.module.css';

export type BtnKind = 'primary' | 'ghost' | 'line';
export type BtnSize = 'sm' | 'md' | 'lg';

interface BtnProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  kind?: BtnKind;
  size?: BtnSize;
  /** Icon node rendered after the label */
  icon?: ReactNode;
  children: ReactNode;
  style?: CSSProperties;
  /** Render as an anchor — pass href to use */
  href?: string;
  fullWidth?: boolean;
}

/**
 * BV Button — JetBrains Mono, uppercase, 0.14em letter-spacing.
 * Heights: sm=34px  md=44px  lg=56px
 * Kinds:   primary (green fill) | ghost (transparent + border) | line (transparent + green text)
 * Radius:  2px — sharp brand aesthetic, never rounded.
 */
export function Btn({
  kind = 'primary',
  size = 'md',
  icon,
  children,
  style,
  href,
  fullWidth,
  className,
  disabled,
  ...rest
}: BtnProps) {
  const cls = [
    styles.btn,
    styles[kind],
    styles[size],
    fullWidth ? styles.fullWidth : '',
    className,
  ]
    .filter(Boolean)
    .join(' ');

  if (href) {
    return (
      <a href={href} className={cls} style={style} aria-disabled={disabled}>
        {children}
        {icon && <span className={styles.icon}>{icon}</span>}
      </a>
    );
  }

  return (
    <button className={cls} style={style} disabled={disabled} {...rest}>
      {children}
      {icon && <span className={styles.icon}>{icon}</span>}
    </button>
  );
}
