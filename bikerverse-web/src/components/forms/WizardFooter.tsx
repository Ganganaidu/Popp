import { Btn } from '@/components/ds/Btn';
import { ArrowRightIcon } from '@/components/ds/Icons';
import styles from './WizardFooter.module.css';

interface WizardFooterProps {
  step: number;
  totalSteps: number;
  onBack: () => void;
  onNext: () => void;
  nextLabel?: string;
  submitLabel?: string;
  isSubmitting?: boolean;
  canProceed?: boolean;
}

/**
 * WizardFooter — sticky bottom nav for multi-step forms.
 * Back (ghost) on left, Next/Submit (primary) on right.
 * On last step, primary button becomes "Submit" with loading state.
 */
export function WizardFooter({
  step,
  totalSteps,
  onBack,
  onNext,
  nextLabel = 'NEXT',
  submitLabel = 'PUBLISH LISTING',
  isSubmitting = false,
  canProceed = true,
}: WizardFooterProps) {
  const isLast = step === totalSteps - 1;

  return (
    <div className={styles.footer}>
      <div className={styles.inner}>
        <div className={styles.left}>
          {step > 0 && (
            <Btn kind="ghost" size="md" onClick={onBack} type="button">
              ← BACK
            </Btn>
          )}
        </div>

        <div className={styles.right}>
          <span className={styles.stepCount}>
            Step {step + 1} of {totalSteps}
          </span>
          <Btn
            kind="primary"
            size="md"
            onClick={onNext}
            type={isLast ? 'submit' : 'button'}
            disabled={!canProceed || isSubmitting}
            icon={!isLast ? <ArrowRightIcon size={14} color="var(--bv-green-ink)" /> : undefined}
          >
            {isLast ? (isSubmitting ? 'PUBLISHING…' : submitLabel) : nextLabel}
          </Btn>
        </div>
      </div>
    </div>
  );
}
