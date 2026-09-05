import type { Metadata } from 'next';
import { ExploreContent } from './ExploreContent';

export const metadata: Metadata = {
  title: 'Explore — Bikerverse',
  description:
    'Search the whole garage. Find premium bikes, riding gear, mechanics, track days, rentals and more.',
};

export default function ExplorePage() {
  return <ExploreContent />;
}
