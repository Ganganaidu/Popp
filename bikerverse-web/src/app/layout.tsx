import type { Metadata, Viewport } from 'next';
import { Archivo, Archivo_Narrow, JetBrains_Mono } from 'next/font/google';
import '@/styles/globals.css';
import { ThemeProvider } from '@/components/ds/ThemeProvider';

/* ─── Google Fonts — three families from the BV design system ─────────────── */

const archivoNarrow = Archivo_Narrow({
  subsets: ['latin'],
  weight: ['500', '600', '700'],
  style: ['normal', 'italic'],
  variable: '--font-archivo-narrow',
  display: 'swap',
});

const archivo = Archivo({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  style: ['normal', 'italic'],
  variable: '--font-archivo',
  display: 'swap',
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  weight: ['400', '500', '600'],
  variable: '--font-jetbrains-mono',
  display: 'swap',
});

/* ─── Metadata ──────────────────────────────────────────────────────────────── */

export const metadata: Metadata = {
  title: {
    default: 'Bikerverse — One-stop hub for riders in India',
    template: '%s · Bikerverse',
  },
  description:
    'Buy & sell premium pre-owned bikes and accessories. Find trusted mechanics, tyre shops and accessory stores. Book track days & training events — all in one place.',
  keywords: ['bikes', 'motorcycles', 'sell bike', 'mechanic', 'track day', 'India'],
  authors: [{ name: 'Bikerverse' }],
  openGraph: {
    siteName: 'Bikerverse',
    type: 'website',
    locale: 'en_IN',
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: [
    { media: '(prefers-color-scheme: dark)',  color: '#0B0B0C' },
    { media: '(prefers-color-scheme: light)', color: '#F6F4EE' },
  ],
};

/* ─── Root layout ───────────────────────────────────────────────────────────── */

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={[
        archivoNarrow.variable,
        archivo.variable,
        jetbrainsMono.variable,
      ].join(' ')}
    >
      <body>
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
