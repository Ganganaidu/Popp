import { ChevronIcon } from './Icons';
import styles from './FilterChip.module.css';

interface FilterChipProps {
  label: string;
  value: string;
  active?: boolean;
  onClick?: () => void;
}

/**
 * BV FilterChip — used in the listing filter bar and filters modal.
 * Mono label + sans value + down chevron.
 * Active state: green-soft background, green-line border, green value text.
 */
export function FilterChip({ label, value, active, onClick }: FilterChipProps) {
  return (
    <button
      type="button"
      className={[styles.chip, active ? styles.active : ''].filter(Boolean).join(' ')}
      onClick={onClick}
      aria-pressed={active}
    >
      <span className={styles.label}>{label}</span>
      <span className={styles.value}>{value}</span>
      <ChevronIcon
        direction="down"
        size={10}
        color={active ? 'var(--bv-green)' : 'var(--bv-text-3)'}
      />
    </button>
  );
}
