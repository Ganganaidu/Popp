'use client';

import { useState } from 'react';
import * as Dialog from '@radix-ui/react-dialog';
import * as Slider from '@radix-ui/react-slider';
import { CloseIcon } from '@/components/ds/Icons';
import { Btn } from '@/components/ds/Btn';
import styles from './FiltersModal.module.css';

/* ─── Category rail ─────────────────────────────────────── */
const CATEGORIES = [
  { id: 'budget',    label: 'Budget',           dot: true  },
  { id: 'brand',     label: 'Brand',            dot: false },
  { id: 'kmdriven',  label: 'KM Driven',        dot: true  },
  { id: 'year',      label: 'Year',             dot: false },
  { id: 'state',     label: 'State',            dot: false },
  { id: 'owners',    label: 'No. of Owners',    dot: false },
  { id: 'insurance', label: 'Insurance',        dot: false },
  { id: 'color',     label: 'Colour',           dot: false },
] as const;

type CategoryId = typeof CATEGORIES[number]['id'];

/* ─── Quick pick chips ───────────────────────────────────── */
const BUDGET_QUICK: string[] = ['Under ₹ 50K', 'Under ₹ 1L', '1L – 3L', '3L – 5L', 'Above ₹ 5L'];
const BRAND_QUICK:  string[] = ['Royal Enfield', 'Bajaj', 'Honda', 'Kawasaki', 'KTM', 'Triumph', 'Ducati', 'Harley-Davidson'];
const KM_QUICK:    string[] = ['Under 5,000', 'Under 10,000', '10K – 20K', '20K – 50K'];

function formatRupees(n: number): string {
  if (n >= 100000) return `₹ ${(n / 100000).toFixed(n % 100000 === 0 ? 0 : 1)}L`;
  if (n >= 1000)   return `₹ ${(n / 1000).toFixed(0)}K`;
  return `₹ ${n}`;
}

interface FiltersModalProps {
  open: boolean;
  onClose: () => void;
}

/**
 * FiltersModal — 880px wide Radix Dialog.
 * Left rail: 220px category list with active state (2px green border-left + dot).
 * Right pane: dynamic content per category. Budget shows twin-handle Radix Slider.
 */
export function FiltersModal({ open, onClose }: FiltersModalProps) {
  const [activeCategory, setActiveCategory] = useState<CategoryId>('budget');
  const [budgetRange, setBudgetRange] = useState<[number, number]>([100000, 500000]);
  const [selectedBrands, setSelectedBrands] = useState<string[]>([]);
  const [selectedKm, setSelectedKm] = useState<string[]>([]);

  function toggleBrand(b: string) {
    setSelectedBrands((prev) => prev.includes(b) ? prev.filter((x) => x !== b) : [...prev, b]);
  }

  function toggleKm(k: string) {
    setSelectedKm((prev) => prev.includes(k) ? prev.filter((x) => x !== k) : [...prev, k]);
  }

  function clearAll() {
    setBudgetRange([100000, 500000]);
    setSelectedBrands([]);
    setSelectedKm([]);
  }

  const activeCount = (budgetRange[0] !== 100000 || budgetRange[1] !== 500000 ? 1 : 0) + selectedBrands.length + selectedKm.length;

  return (
    <Dialog.Root open={open} onOpenChange={(o) => !o && onClose()}>
      <Dialog.Portal>
        <Dialog.Overlay className={styles.overlay} />
        <Dialog.Content className={styles.dialog} aria-describedby={undefined}>
          {/* Header */}
          <div className={styles.header}>
            <Dialog.Title className={styles.title}>FILTERS</Dialog.Title>
            {activeCount > 0 && (
              <button type="button" className={styles.clearAll} onClick={clearAll}>
                CLEAR ALL ({activeCount})
              </button>
            )}
            <Dialog.Close className={styles.closeBtn} aria-label="Close filters">
              <CloseIcon size={18} color="var(--bv-text-2)" />
            </Dialog.Close>
          </div>

          {/* Body */}
          <div className={styles.body}>
            {/* Left rail */}
            <nav className={styles.rail}>
              {CATEGORIES.map((cat) => (
                <button
                  key={cat.id}
                  type="button"
                  className={[
                    styles.railItem,
                    activeCategory === cat.id ? styles.railActive : '',
                  ].filter(Boolean).join(' ')}
                  onClick={() => setActiveCategory(cat.id)}
                >
                  <span className={styles.railLabel}>{cat.label}</span>
                  {cat.dot && <span className={styles.railDot} />}
                </button>
              ))}
            </nav>

            {/* Right pane */}
            <div className={styles.pane}>
              {activeCategory === 'budget' && (
                <div className={styles.section}>
                  <p className={styles.paneTitle}>BUDGET</p>

                  {/* Range display */}
                  <div className={styles.rangeDisplay}>
                    <span className={styles.rangeValue}>{formatRupees(budgetRange[0])}</span>
                    <span className={styles.rangeSep}>—</span>
                    <span className={styles.rangeValue}>{formatRupees(budgetRange[1])}</span>
                  </div>

                  {/* Twin-handle slider */}
                  <Slider.Root
                    className={styles.sliderRoot}
                    min={0}
                    max={2000000}
                    step={10000}
                    value={budgetRange}
                    onValueChange={(v) => setBudgetRange(v as [number, number])}
                  >
                    <Slider.Track className={styles.sliderTrack}>
                      <Slider.Range className={styles.sliderRange} />
                    </Slider.Track>
                    <Slider.Thumb className={styles.sliderThumb} aria-label="Minimum budget" />
                    <Slider.Thumb className={styles.sliderThumb} aria-label="Maximum budget" />
                  </Slider.Root>

                  {/* Scale labels */}
                  <div className={styles.sliderScale}>
                    <span>₹ 0</span>
                    <span>₹ 5L</span>
                    <span>₹ 10L</span>
                    <span>₹ 15L</span>
                    <span>₹ 20L+</span>
                  </div>

                  {/* Quick picks */}
                  <p className={styles.quickTitle}>QUICK PICKS</p>
                  <div className={styles.quickChips}>
                    {BUDGET_QUICK.map((q) => (
                      <button key={q} type="button" className={styles.quickChip}>{q}</button>
                    ))}
                  </div>
                </div>
              )}

              {activeCategory === 'brand' && (
                <div className={styles.section}>
                  <p className={styles.paneTitle}>BRAND</p>
                  <div className={styles.quickChips}>
                    {BRAND_QUICK.map((b) => (
                      <button
                        key={b}
                        type="button"
                        className={[styles.quickChip, selectedBrands.includes(b) ? styles.quickChipActive : ''].filter(Boolean).join(' ')}
                        onClick={() => toggleBrand(b)}
                      >
                        {b}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {activeCategory === 'kmdriven' && (
                <div className={styles.section}>
                  <p className={styles.paneTitle}>KM DRIVEN</p>
                  <div className={styles.quickChips}>
                    {KM_QUICK.map((k) => (
                      <button
                        key={k}
                        type="button"
                        className={[styles.quickChip, selectedKm.includes(k) ? styles.quickChipActive : ''].filter(Boolean).join(' ')}
                        onClick={() => toggleKm(k)}
                      >
                        {k}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {!['budget', 'brand', 'kmdriven'].includes(activeCategory) && (
                <div className={styles.section}>
                  <p className={styles.paneTitle}>{CATEGORIES.find((c) => c.id === activeCategory)?.label.toUpperCase()}</p>
                  <p className={styles.emptyState}>Filter options coming soon.</p>
                </div>
              )}
            </div>
          </div>

          {/* Footer */}
          <div className={styles.footer}>
            <span className={styles.footerCount}>240 bikes match</span>
            <Btn kind="primary" size="md" onClick={onClose}>
              APPLY FILTERS
            </Btn>
          </div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
