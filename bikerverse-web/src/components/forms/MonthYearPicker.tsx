import { MONTHS, yearOptions } from '@/lib/data/bikeData';
import styles from './MonthYearPicker.module.css';

interface MonthYearPickerProps {
  label: string;
  value: { month: string; year: string };
  onChange: (v: { month: string; year: string }) => void;
  required?: boolean;
  hint?: string;
  error?: string;
  fromYear?: number;
  toYear?: number;
}

/**
 * MonthYearPicker — mirrors Flutter's MonthYearPicker widget.
 * Side-by-side Month + Year selects under a single label.
 */
export function MonthYearPicker({
  label, value, onChange, required, hint, error, fromYear = 1990, toYear,
}: MonthYearPickerProps) {
  const years = yearOptions(fromYear, toYear);
  const fieldId = `myp-${label.toLowerCase().replace(/\s+/g, '-')}`;

  return (
    <div className={styles.wrap}>
      <span className={styles.label} id={`${fieldId}-label`}>
        {label}
        {required && <span className={styles.req} aria-hidden>*</span>}
      </span>
      <div className={styles.row} aria-labelledby={`${fieldId}-label`}>
        {/* Month */}
        <div className={styles.selectWrap}>
          <select
            className={[styles.select, error ? styles.hasError : ''].filter(Boolean).join(' ')}
            value={value.month}
            onChange={(e) => onChange({ ...value, month: e.target.value })}
            aria-label={`${label} month`}
            aria-invalid={!!error}
          >
            <option value="">Month</option>
            {MONTHS.map((m) => (
              <option key={m} value={m}>{m}</option>
            ))}
          </select>
          <span className={styles.chevron} aria-hidden>▾</span>
        </div>

        {/* Year */}
        <div className={styles.selectWrap}>
          <select
            className={[styles.select, error ? styles.hasError : ''].filter(Boolean).join(' ')}
            value={value.year}
            onChange={(e) => onChange({ ...value, year: e.target.value })}
            aria-label={`${label} year`}
            aria-invalid={!!error}
          >
            <option value="">Year</option>
            {years.map((y) => (
              <option key={y.value} value={y.value}>{y.label}</option>
            ))}
          </select>
          <span className={styles.chevron} aria-hidden>▾</span>
        </div>
      </div>
      {(error || hint) && (
        <span className={error ? styles.error : styles.hint}>
          {error ?? hint}
        </span>
      )}
    </div>
  );
}
