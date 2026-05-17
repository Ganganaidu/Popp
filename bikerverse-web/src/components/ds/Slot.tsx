import type { CSSProperties } from 'react';
import styles from './Slot.module.css';

interface SlotProps {
  /** Descriptive label shown in the placeholder */
  label: string;
  /** CSS aspect-ratio string e.g. "4/3", "1/1", "4/5" */
  aspectRatio?: string;
  /** Fixed height override (bypasses aspectRatio) */
  height?: number | string;
  className?: string;
  style?: CSSProperties;
  /** Optional src — when provided, renders a real image instead of placeholder */
  src?: string;
  alt?: string;
}

/**
 * Striped image placeholder — used throughout the design for images not yet sourced.
 * When `src` is provided, renders a real <img> instead.
 */
export function Slot({ label, aspectRatio, height, className, style, src, alt }: SlotProps) {
  if (src) {
    return (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        src={src}
        alt={alt ?? label}
        className={[styles.image, className].filter(Boolean).join(' ')}
        style={{ aspectRatio, height, ...style }}
      />
    );
  }

  return (
    <div
      className={[styles.slot, className].filter(Boolean).join(' ')}
      style={{ aspectRatio, height, ...style }}
      role="img"
      aria-label={label}
    >
      <span className={styles.label}>{label}</span>
    </div>
  );
}
