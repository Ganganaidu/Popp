import styles from './SpecStrip.module.css';

interface SpecStripProps {
  kmDriven: number;
  year: string | number;
  owners: number;
  insurance?: string;
}

function formatKm(n: number): string {
  return n.toLocaleString('en-IN');
}

/**
 * SpecStrip — 4-cell gauge cluster.
 * Outer border, each cell has border-left (first cell none).
 * Value: Archivo Narrow 700 24px. Label: Mono 10px 0.14em text-3.
 */
export function SpecStrip({ kmDriven, year, owners, insurance = 'Valid' }: SpecStripProps) {
  const cells = [
    { label: 'KM DRIVEN',  value: `${formatKm(kmDriven)} KM` },
    { label: 'YEAR',        value: String(year)                },
    { label: 'OWNERS',      value: `${owners} ${owners === 1 ? 'Owner' : 'Owners'}` },
    { label: 'INSURANCE',   value: insurance                   },
  ] as const;

  return (
    <div className={styles.strip}>
      {cells.map((cell, i) => (
        <div key={cell.label} className={[styles.cell, i === 0 ? styles.first : ''].filter(Boolean).join(' ')}>
          <span className={styles.value}>{cell.value}</span>
          <span className={styles.label}>{cell.label}</span>
        </div>
      ))}
    </div>
  );
}
