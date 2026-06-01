import type { SelectHTMLAttributes } from 'react';
import { ChevronIcon } from '@/components/ds/Icons';
import styles from './FormSelect.module.css';

interface FormSelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label: string;
  hint?: string;
  error?: string;
  options: readonly { value: string; label: string }[];
  placeholder?: string;
}

/**
 * BV FormSelect — same visual style as FormField input but with native <select>.
 * Custom chevron overlaid via wrapper div; select itself is transparent to arrow.
 */
export function FormSelect({ label, hint, error, options, placeholder, required, ...rest }: FormSelectProps) {
  const fieldId = `select-${label.toLowerCase().replace(/\s+/g, '-')}`;

  return (
    <div className={styles.wrap}>
      <label htmlFor={fieldId} className={styles.label}>
        {label}
        {required && <span className={styles.req} aria-hidden>*</span>}
      </label>

      <div className={styles.selectWrap}>
        <select
          id={fieldId}
          className={[styles.select, error ? styles.hasError : ''].filter(Boolean).join(' ')}
          aria-describedby={hint || error ? `${fieldId}-hint` : undefined}
          aria-invalid={!!error}
          required={required}
          {...rest}
        >
          {placeholder && <option value="">{placeholder}</option>}
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>{opt.label}</option>
          ))}
        </select>
        <span className={styles.chevron} aria-hidden>
          <ChevronIcon direction="down" size={12} color="var(--bv-text-3)" />
        </span>
      </div>

      {(hint || error) && (
        <span id={`${fieldId}-hint`} className={error ? styles.error : styles.hint}>
          {error ?? hint}
        </span>
      )}
    </div>
  );
}
