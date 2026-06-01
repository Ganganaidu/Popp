import type { InputHTMLAttributes, TextareaHTMLAttributes, ReactNode } from 'react';
import styles from './FormField.module.css';

interface BaseProps {
  label: string;
  hint?: string;
  error?: string;
  required?: boolean;
}

interface InputProps extends BaseProps, InputHTMLAttributes<HTMLInputElement> {
  as?: 'input';
}

interface TextareaProps extends BaseProps, TextareaHTMLAttributes<HTMLTextAreaElement> {
  as: 'textarea';
  rows?: number;
}

type FormFieldProps = InputProps | TextareaProps;

/**
 * BV FormField — label + input/textarea + hint/error line.
 * 44px input height, 2px radius, --bv-border border.
 * Focus: outline 1px --bv-green + 2px offset.
 * Error: --bv-red border + red helper text.
 */
export function FormField(props: FormFieldProps) {
  const { label, hint, error, required, as = 'input', ...rest } = props;
  const fieldId = `field-${label.toLowerCase().replace(/\s+/g, '-')}`;

  return (
    <div className={styles.wrap}>
      <label htmlFor={fieldId} className={styles.label}>
        {label}
        {required && <span className={styles.req} aria-hidden>*</span>}
      </label>

      {as === 'textarea' ? (
        <textarea
          id={fieldId}
          className={[styles.input, styles.textarea, error ? styles.hasError : ''].filter(Boolean).join(' ')}
          rows={(rest as TextareaProps).rows ?? 4}
          aria-describedby={hint || error ? `${fieldId}-hint` : undefined}
          aria-invalid={!!error}
          {...(rest as TextareaHTMLAttributes<HTMLTextAreaElement>)}
        />
      ) : (
        <input
          id={fieldId}
          className={[styles.input, error ? styles.hasError : ''].filter(Boolean).join(' ')}
          aria-describedby={hint || error ? `${fieldId}-hint` : undefined}
          aria-invalid={!!error}
          {...(rest as InputHTMLAttributes<HTMLInputElement>)}
        />
      )}

      {(hint || error) && (
        <span id={`${fieldId}-hint`} className={error ? styles.error : styles.hint}>
          {error ?? hint}
        </span>
      )}
    </div>
  );
}
