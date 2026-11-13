import type { ConfigShop, Product, Shop, Vec4 } from './types';

export const blankShop = (id: string, label: string): Shop => ({
  id,
  label,
  enabled: true,
  coords: [],
  blip: { disabled: false, sprite: 52, color: 2, scale: 0.8 },
  target: { radius: 2 },
  products: [],
});

// "Convenience Store" -> "convenience_store"
export const slugify = (s: string) =>
  s.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '').slice(0, 36);

// Shop ids are c_<slug>. Adds 2, 3... when the base is taken.
export function uniqueId(base: string, taken: string[]): string {
  const stem = `c_${base || 'shop'}`;
  let id = stem;
  let n = 2;
  while (taken.includes(id)) id = `${stem}${n++}`;
  return id;
}

export function shopFromConfig(c: ConfigShop, id: string): Shop {
  const models = c.model === undefined ? [] : (Array.isArray(c.model) ? c.model : [c.model]).map(String);
  return {
    id,
    label: c.label,
    enabled: true,
    models: models.length ? models : undefined,
    coords: c.coords.map((v: Vec4) => ({ x: v.x, y: v.y, z: v.z, w: v.w })),
    blip: {
      disabled: c.blip?.disabled ?? false,
      sprite: c.blip?.sprite ?? 52,
      color: c.blip?.color ?? 2,
      scale: c.blip?.scale ?? 0.8,
    },
    target: { label: c.target?.label, icon: c.target?.icon, radius: c.target?.radius ?? 2 },
    jobs: c.jobs && Object.keys(c.jobs).length ? c.jobs : undefined,
    products: c.products.map((p: Product) => ({ ...p })),
  };
}

// "police:2, ambulance:0" -> { police: 2, ambulance: 0 }
export function parseJobs(text: string): Record<string, number> | undefined {
  const out: Record<string, number> = {};
  for (const part of text.split(',')) {
    const [job, grade] = part.split(':').map((s) => s.trim());
    if (job) out[job] = Number(grade ?? 0) || 0;
  }
  return Object.keys(out).length ? out : undefined;
}

export const formatJobs = (jobs?: Record<string, number>) =>
  jobs ? Object.entries(jobs).map(([j, g]) => `${j}:${g}`).join(', ') : '';

export const money = (n: number) => `$${Math.round(n).toLocaleString()}`;
