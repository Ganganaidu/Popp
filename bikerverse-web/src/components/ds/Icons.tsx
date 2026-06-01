/**
 * BV Icon set — 16×16 line icons at 1.4–1.5px stroke.
 * All sourced from the design handoff bv-screens.jsx.
 * Each icon accepts an optional `color` prop (defaults to currentColor).
 */

interface IconProps {
  color?: string;
  size?: number;
}

export const HomeIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M2 7l6-5 6 5v7H10v-4H6v4H2V7z" stroke={color} strokeWidth="1.4" strokeLinejoin="round" />
  </svg>
);

export const SearchIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <circle cx="7" cy="7" r="4.5" stroke={color} strokeWidth="1.4" />
    <path d="M10.5 10.5L14 14" stroke={color} strokeWidth="1.4" strokeLinecap="round" />
  </svg>
);

export const ChatIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M2 3h12v8H6l-3 3V3z" stroke={color} strokeWidth="1.4" strokeLinejoin="round" />
  </svg>
);

export const HeartIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path
      d="M8 13.5S2 10 2 5.8C2 3.7 3.5 2.5 5 2.5c1.2 0 2.3.7 3 1.8.7-1.1 1.8-1.8 3-1.8 1.5 0 3 1.2 3 3.3 0 4.2-6 7.7-6 7.7z"
      stroke={color}
      strokeWidth="1.4"
      strokeLinejoin="round"
    />
  </svg>
);

export const HeartFilledIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path
      d="M8 13.5S2 10 2 5.8C2 3.7 3.5 2.5 5 2.5c1.2 0 2.3.7 3 1.8.7-1.1 1.8-1.8 3-1.8 1.5 0 3 1.2 3 3.3 0 4.2-6 7.7-6 7.7z"
      fill={color}
      stroke={color}
      strokeWidth="1.4"
      strokeLinejoin="round"
    />
  </svg>
);

export const GearIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <circle cx="8" cy="8" r="2" stroke={color} strokeWidth="1.4" />
    <path
      d="M8 1.5v2M8 12.5v2M14.5 8h-2M3.5 8h-2M12.6 3.4l-1.4 1.4M4.8 11.2l-1.4 1.4M12.6 12.6l-1.4-1.4M4.8 4.8L3.4 3.4"
      stroke={color}
      strokeWidth="1.4"
      strokeLinecap="round"
    />
  </svg>
);

export const LoginIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path
      d="M9 2h4v12H9M2 8h8M7 5l3 3-3 3"
      stroke={color}
      strokeWidth="1.4"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

export const PinIcon = ({ color = 'currentColor', size = 14 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M8 14s5-4.5 5-8.5A5 5 0 003 5.5C3 9.5 8 14 8 14z" stroke={color} strokeWidth="1.4" />
    <circle cx="8" cy="5.5" r="1.6" stroke={color} strokeWidth="1.4" />
  </svg>
);

export const CalIcon = ({ color = 'currentColor', size = 14 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <rect x="2" y="3" width="12" height="11" rx="1" stroke={color} strokeWidth="1.4" />
    <path d="M2 6h12M5 1.5v3M11 1.5v3" stroke={color} strokeWidth="1.4" strokeLinecap="round" />
  </svg>
);

export const ArrowRightIcon = ({ color = 'currentColor', size = 14 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path
      d="M3 8h10M9 4l4 4-4 4"
      stroke={color}
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

export const FilterIcon = ({ color = 'currentColor', size = 14 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M2 4h12M4 8h8M6 12h4" stroke={color} strokeWidth="1.5" strokeLinecap="round" />
  </svg>
);

export const CloseIcon = ({ color = 'currentColor', size = 14 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M3 3l10 10M13 3L3 13" stroke={color} strokeWidth="1.5" strokeLinecap="round" />
  </svg>
);

export const ChevronIcon = ({
  color = 'currentColor',
  size = 10,
  direction = 'right',
}: IconProps & { direction?: 'right' | 'left' | 'up' | 'down' }) => {
  const rotations = { right: 0, down: 90, left: 180, up: -90 };
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      style={{ transform: `rotate(${rotations[direction]}deg)`, flexShrink: 0 }}
    >
      <path
        d="M6 4l4 4-4 4"
        fill="none"
        stroke={color}
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};

export const MoonIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path
      d="M13.5 9.5A6 6 0 016.5 2.5a6 6 0 000 11 6 6 0 007-4z"
      stroke={color}
      strokeWidth="1.4"
      strokeLinejoin="round"
    />
  </svg>
);

export const SunIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <circle cx="8" cy="8" r="3" stroke={color} strokeWidth="1.4" />
    <path
      d="M8 1v2M8 13v2M1 8h2M13 8h2M3.2 3.2l1.4 1.4M11.4 11.4l1.4 1.4M3.2 12.8l1.4-1.4M11.4 4.6l1.4-1.4"
      stroke={color}
      strokeWidth="1.4"
      strokeLinecap="round"
    />
  </svg>
);

export const MenuIcon = ({ color = 'currentColor', size = 16 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M2 4h12M2 8h12M2 12h12" stroke={color} strokeWidth="1.5" strokeLinecap="round" />
  </svg>
);

export const StarIcon = ({ color = 'currentColor', size = 14 }: IconProps) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill={color}>
    <path d="M8 1.5l1.8 3.7 4.1.6-3 2.9.7 4-3.6-1.9L4.4 12.7l.7-4-3-2.9 4.1-.6z" />
  </svg>
);
