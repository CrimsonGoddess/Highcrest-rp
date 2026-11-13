import { colorsTuple, createTheme, type MantineColorsTuple } from '@mantine/core';

// Highcrest colours. The accent follows the player's phone setting.
export const CRIMSON = '#C8102E';
export const GOLD = '#D4AF37';

/** Ten shades from one colour (lighter to darker), so Mantine's hover/pressed states still work. */
function shades(hex: string): MantineColorsTuple {
  const n = parseInt(hex.slice(1), 16);
  const r = (n >> 16) & 255, g = (n >> 8) & 255, b = n & 255;
  const mix = (t: number, to: number) => [r, g, b].map((c) => Math.round(c + (to - c) * t));
  const toHex = (rgb: number[]) => '#' + rgb.map((c) => c.toString(16).padStart(2, '0')).join('');
  const steps = [0.85, 0.7, 0.55, 0.4, 0.25, 0.1, 0, -0.15, -0.3, -0.45];
  return steps.map((t) => toHex(t >= 0 ? mix(t, 255) : mix(-t, 0))) as unknown as MantineColorsTuple;
}

/** Dark or light text for a background colour. */
export function contrastText(hex: string): string {
  const n = parseInt(hex.slice(1), 16);
  const brightness = (((n >> 16) & 255) * 299 + ((n >> 8) & 255) * 587 + (n & 255) * 114) / 1000;
  return brightness > 150 ? '#0b0b0d' : '#f5f5f5';
}

export function makeTheme(accent: string) {
  const valid = /^#[0-9a-f]{6}$/i.test(accent) ? accent : CRIMSON;
  return createTheme({
    fontFamily: 'Rajdhani, "Segoe UI", Arial, sans-serif',
    headings: { fontFamily: 'Rajdhani, "Segoe UI", Arial, sans-serif', fontWeight: '700' },
    primaryColor: 'accent',
    primaryShade: 6,
    colors: {
      accent: shades(valid),
      gold: colorsTuple(GOLD),
    },
    defaultRadius: 'md',
    cursorType: 'pointer',
    autoContrast: true,
  });
}
