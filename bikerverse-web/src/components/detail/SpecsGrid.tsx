import styles from './SpecsGrid.module.css';

export interface SpecItem {
  key: string;
  value: string;
}

interface SpecsGridProps {
  specs: SpecItem[];
  title?: string;
}

/**
 * SpecsGrid — 2-column grid with outer 1px border.
 * Each cell: key in Mono 10px 0.14em text-3, value in Archivo 13px.
 * Cells from row 2 onward get border-top. Odd-indexed cells get border-left.
 */
export function SpecsGrid({ specs, title = 'SPECIFICATIONS' }: SpecsGridProps) {
  return (
    <section className={styles.section}>
      <h2 className={styles.title}>{title}</h2>
      <div className={styles.grid}>
        {specs.map((spec, i) => (
          <div
            key={spec.key}
            className={[
              styles.cell,
              i >= 2 ? styles.borderTop : '',
              i % 2 === 1 ? styles.borderLeft : '',
            ].filter(Boolean).join(' ')}
          >
            <span className={styles.key}>{spec.key}</span>
            <span className={styles.value}>{spec.value}</span>
          </div>
        ))}
      </div>
    </section>
  );
}
