import styles from './Wordmark.module.css';

interface WordmarkProps {
  /** Rendered font-size in px. Default 20 (top bar). Use 34 on auth/marketing. */
  size?: number;
  /** Optional className for additional positioning */
  className?: string;
}

/**
 * BV Wordmark — "BIKER" in primary text color, "VERSE" in brand green.
 * Archivo Narrow ExtraBold, -0.02em letter-spacing, uppercase — exactly as specced.
 */
export function Wordmark({ size = 20, className }: WordmarkProps) {
  return (
    <span
      className={[styles.wordmark, className].filter(Boolean).join(' ')}
      style={{ fontSize: size }}
      aria-label="Bikerverse"
    >
      BIKER<span className={styles.accent}>VERSE</span>
    </span>
  );
}
