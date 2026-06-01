import styles from './CornerTicks.module.css';

interface CornerTicksProps {
  /**
   * Which corners to render. Defaults to all four.
   * Product detail uses only top-left + bottom-right.
   */
  corners?: ('tl' | 'tr' | 'bl' | 'br')[];
  /**
   * Offset outward from the image edge in px. Design spec: 8px.
   */
  offset?: number;
}

/**
 * Gauge-cluster corner ticks — L-shaped 16×16 green lines placed outside
 * the hero image / product primary image. 2px stroke, --bv-green color.
 *
 * The parent element MUST have position: relative.
 * Wrap the image + ticks together in a <div style={{ position: 'relative' }}>.
 */
export function CornerTicks({
  corners = ['tl', 'tr', 'bl', 'br'],
  offset = 8,
}: CornerTicksProps) {
  const set = new Set(corners);

  const pos = (inset: number) => ({
    position: 'absolute' as const,
    width: 16,
    height: 16,
  });

  return (
    <>
      {set.has('tl') && (
        <span
          className={styles.tick}
          style={{
            top: -offset,
            left: -offset,
            borderTop: '2px solid var(--bv-green)',
            borderLeft: '2px solid var(--bv-green)',
            ...pos(offset),
          }}
          aria-hidden
        />
      )}
      {set.has('tr') && (
        <span
          className={styles.tick}
          style={{
            top: -offset,
            right: -offset,
            borderTop: '2px solid var(--bv-green)',
            borderRight: '2px solid var(--bv-green)',
            ...pos(offset),
          }}
          aria-hidden
        />
      )}
      {set.has('bl') && (
        <span
          className={styles.tick}
          style={{
            bottom: -offset,
            left: -offset,
            borderBottom: '2px solid var(--bv-green)',
            borderLeft: '2px solid var(--bv-green)',
            ...pos(offset),
          }}
          aria-hidden
        />
      )}
      {set.has('br') && (
        <span
          className={styles.tick}
          style={{
            bottom: -offset,
            right: -offset,
            borderBottom: '2px solid var(--bv-green)',
            borderRight: '2px solid var(--bv-green)',
            ...pos(offset),
          }}
          aria-hidden
        />
      )}
    </>
  );
}
