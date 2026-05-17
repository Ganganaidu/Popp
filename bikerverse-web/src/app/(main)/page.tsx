import type { Metadata } from 'next';
import { HeroSection }      from '@/components/home/HeroSection';
import { RatingCarousel }   from '@/components/home/RatingCarousel';
import { ActionGrid }       from '@/components/home/ActionGrid';
import { PremiumBikesRow }  from '@/components/home/PremiumBikesRow';
import { GearMechanicsRow } from '@/components/home/GearMechanicsRow';

export const metadata: Metadata = {
  title: 'Bikerverse — One-stop hub for riders in India',
  description:
    'Buy & sell premium pre-owned bikes and accessories. Find trusted mechanics, tyre shops and accessory stores. Book track days & training events — all in one place.',
};

/**
 * Home page — Phase 2 complete.
 * Sections (in order, matching design handoff screen 02):
 *   A. Hero — two-column + corner ticks
 *   B. Testimonial carousel — auto-advance, 3 cards, progress bar
 *   C. Action grid — "Pick a Lane", 6 tiles
 *   D. Premium bikes — 4-column BikeCard row
 *   E. Two-up — Protection Gear + Trusted Mechanics
 */
export default function HomePage() {
  return (
    <>
      <HeroSection />
      <RatingCarousel />
      <ActionGrid />
      <PremiumBikesRow />
      <GearMechanicsRow />
    </>
  );
}
