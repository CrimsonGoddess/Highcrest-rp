export type Vec4 = { x: number; y: number; z: number; w: number };

export type Product = {
  name: string;
  price: number;
  defaultStock?: number;
  category?: string;
  license?: string;
  jobs?: Record<string, number>;
  metadata?: unknown;
};

export type Blip = { disabled: boolean; sprite: number; color: number; scale: number };

export type Shop = {
  id: string;
  label: string;
  enabled: boolean;
  models?: string[];
  coords: Vec4[];
  blip: Blip;
  target: { label?: string; icon?: string; radius: number };
  jobs?: Record<string, number>;
  products: Product[];
};

// Config shops from config/locations.lua, read-only. Models are hashes here.
export type ConfigShop = {
  id: string;
  label: string;
  model?: number | number[];
  coords: Vec4[];
  blip?: Partial<Blip>;
  target?: Partial<Shop['target']>;
  jobs?: Record<string, number>;
  products: Product[];
};

export type CatalogItem = { name: string; label: string; weight?: number; image: string };

export type LogRow = {
  actor: string;
  action: string;
  shop_id?: string | null;
  detail?: string | null;
  created_at: string;
};

export type Bootstrap = {
  shops: Shop[];
  config: ConfigShop[];
  items: CatalogItem[];
  actor: string;
  efRunning: boolean;
};
