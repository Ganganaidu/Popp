'use client';

import { useState } from 'react';
import { FilterChip } from '@/components/ds/FilterChip';
import { FilterIcon, ChevronIcon } from '@/components/ds/Icons';
import { FiltersModal } from './FiltersModal';
import styles from './FilterBar.module.css';

const CHIPS = [
  { label: 'BUDGET',     value: '₹ 1L – 5L',  active: true  },
  { label: 'BRAND',      value: 'Any',          active: false },
  { label: 'KM DRIVEN',  value: '< 20,000',     active: true  },
  { label: 'STATE',      value: 'Any',          active: false },
  { label: 'YEAR',       value: '2020 – 2024',  active: true  },
] as const;

const SORT_OPTIONS = ['Newest first', 'Price: low to high', 'Price: high to low', 'KM: low to high'] as const;

interface FilterBarProps {
  count?: number;
}

/**
 * FilterBar — "All filters" ghost btn + FilterChips + flex spacer + Sort dropdown.
 * Used at the top of any listing page.
 */
export function FilterBar({ count = 240 }: FilterBarProps) {
  const [modalOpen, setModalOpen] = useState(false);
  const [sort, setSort] = useState<string>(SORT_OPTIONS[0]);
  const [sortOpen, setSortOpen] = useState(false);

  return (
    <>
      <div className={styles.bar}>
        {/* All Filters button */}
        <button
          type="button"
          className={styles.allFilters}
          onClick={() => setModalOpen(true)}
        >
          <FilterIcon size={14} color="var(--bv-text-2)" />
          <span>ALL FILTERS</span>
        </button>

        <div className={styles.divider} />

        {/* Chips */}
        <div className={styles.chips}>
          {CHIPS.map((chip) => (
            <FilterChip
              key={chip.label}
              label={chip.label}
              value={chip.value}
              active={chip.active}
            />
          ))}
        </div>

        <div className={styles.spacer} />

        {/* Count */}
        <span className={styles.count}>{count.toLocaleString('en-IN')} bikes</span>

        {/* Sort */}
        <div className={styles.sortWrap}>
          <button
            type="button"
            className={styles.sortBtn}
            onClick={() => setSortOpen((o) => !o)}
          >
            <span className={styles.sortLabel}>SORT</span>
            <span className={styles.sortValue}>{sort}</span>
            <ChevronIcon direction={sortOpen ? 'up' : 'down'} size={10} color="var(--bv-text-3)" />
          </button>
          {sortOpen && (
            <div className={styles.sortDropdown}>
              {SORT_OPTIONS.map((opt) => (
                <button
                  key={opt}
                  type="button"
                  className={[styles.sortOption, opt === sort ? styles.sortActive : ''].filter(Boolean).join(' ')}
                  onClick={() => { setSort(opt); setSortOpen(false); }}
                >
                  {opt}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      <FiltersModal open={modalOpen} onClose={() => setModalOpen(false)} />
    </>
  );
}
