import type { Metadata } from 'next';
import { HeroSection }      from '@/components/home/HeroSection';
import { ActionGrid }       from '@/components/home/ActionGrid';
import { CategorySection }  from '@/components/home/CategorySection';

export const metadata: Metadata = {
  title: 'Bikerverse — One-stop hub for riders in India',
  description:
    'Buy & sell premium pre-owned bikes and accessories. Find trusted mechanics, tyre shops and accessory stores. Book track days & training events — all in one place.',
};

const PRODUCT_CATEGORIES = [
  { name: 'Premium Bikes',             href: '/bikes' },
  { name: 'Protection Gear',           href: '/accessories?cat=protection-gear' },
  { name: 'Luggage & Accessories',     href: '/accessories?cat=luggage' },
  { name: 'Lights & Mounts',           href: '/accessories?cat=lights-mounts' },
  { name: 'Electronic Accessories',    href: '/accessories?cat=electronics' },
  { name: 'Universal Bike Accessories', href: '/accessories?cat=universal' },
  { name: 'Other Products',            href: '/accessories?cat=other' },
] as const;

export default function HomePage() {
  return (
    <>
      <HeroSection />
      {/* <RatingCarousel /> — hidden until ratings API is ready */}
      <ActionGrid />
      {PRODUCT_CATEGORIES.map(({ name, href }) => (
        <CategorySection key={name} categoryName={name} viewAllHref={href} limit={4} />
      ))}
    </>
  );
}
