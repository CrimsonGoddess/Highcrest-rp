import { useMemo, useState } from 'react';
import {
  ActionIcon,
  Button,
  Checkbox,
  Group,
  NumberInput,
  ScrollArea,
  Switch,
  Table,
  Text,
  TextInput,
  Badge,
  Stack,
} from '@mantine/core';
import { IconPlus, IconSearch, IconTrash } from '@tabler/icons-react';
import type { CatalogItem, Product } from './types';
import { formatJobs, money, parseJobs } from './helpers';

const SHOW_LIMIT = 150;

type Props = {
  products: Product[];
  onChange: (products: Product[]) => void;
  catalog: CatalogItem[];
};

const num = (v: number | string) => (typeof v === 'number' ? v : undefined);

export function ItemsEditor({ products, onChange, catalog }: Props) {
  const [query, setQuery] = useState('');
  const [hideAdded, setHideAdded] = useState(true);
  const [selected, setSelected] = useState<string[]>([]);
  const [bulkPrice, setBulkPrice] = useState<number | string>('');
  const [bulkPct, setBulkPct] = useState<number | string>('');
  const [bulkStock, setBulkStock] = useState<number | string>('');
  const [bulkCategory, setBulkCategory] = useState('');

  const labelOf = useMemo(() => new Map(catalog.map((i) => [i.name, i])), [catalog]);
  const inShop = useMemo(() => new Set(products.map((p) => p.name)), [products]);

  const matches = useMemo(() => {
    const q = query.trim().toLowerCase();
    return catalog.filter(
      (i) =>
        (!hideAdded || !inShop.has(i.name)) &&
        (!q || i.label.toLowerCase().includes(q) || i.name.toLowerCase().includes(q)),
    );
  }, [catalog, query, hideAdded, inShop]);

  const shown = matches.slice(0, SHOW_LIMIT);

  const update = (name: string, patch: Partial<Product>) =>
    onChange(products.map((p) => (p.name === name ? { ...p, ...patch } : p)));

  const addItems = (names: string[]) => {
    const fresh = names.filter((n) => !inShop.has(n)).map<Product>((name) => ({ name, price: 10, defaultStock: 50 }));
    if (fresh.length) onChange([...products, ...fresh]);
  };

  const removeSelected = () => {
    onChange(products.filter((p) => !selected.includes(p.name)));
    setSelected([]);
  };

  const bulk = (fn: (p: Product) => Partial<Product>) =>
    onChange(products.map((p) => (selected.includes(p.name) ? { ...p, ...fn(p) } : p)));

  const toggle = (name: string, on: boolean) =>
    setSelected((s) => (on ? [...s, name] : s.filter((n) => n !== name)));

  const allSelected = products.length > 0 && selected.length === products.length;
  const categories = new Set(products.map((p) => p.category).filter(Boolean)).size;
  const stockValue = products.reduce((sum, p) => sum + (p.defaultStock !== undefined ? p.price * p.defaultStock : 0), 0);

  return (
    <div className="items-grid">
      <Stack gap="xs" className="catalog">
        <Text fw={600}>Item list</Text>
        <TextInput
          placeholder="Search by label or item name"
          leftSection={<IconSearch size={16} />}
          value={query}
          onChange={(e) => setQuery(e.currentTarget.value)}
        />
        <Group justify="space-between">
          <Switch size="xs" label="Hide items already in shop" checked={hideAdded} onChange={(e) => setHideAdded(e.currentTarget.checked)} />
          <Text size="xs" c="dimmed">
            {matches.length} match{matches.length === 1 ? '' : 'es'}
          </Text>
        </Group>
        <Button
          size="xs"
          variant="light"
          disabled={!shown.length}
          onClick={() => addItems(shown.map((i) => i.name))}
        >
          Add the {shown.length} shown
        </Button>
        <ScrollArea h={460} type="auto">
          <Stack gap={4}>
            {shown.map((item) => (
              <Group key={item.name} justify="space-between" wrap="nowrap" className="catalog-row">
                <Group gap="xs" wrap="nowrap" miw={0}>
                  <img src={item.image} alt="" width={28} height={28} style={{ objectFit: 'contain', flexShrink: 0 }} />
                  <div style={{ minWidth: 0 }}>
                    <Text size="sm" truncate>
                      {item.label}
                    </Text>
                    <Text size="xs" c="dimmed" truncate>
                      {item.name}
                    </Text>
                  </div>
                </Group>
                <ActionIcon variant="subtle" aria-label={`Add ${item.label}`} disabled={inShop.has(item.name)} onClick={() => addItems([item.name])}>
                  <IconPlus size={16} />
                </ActionIcon>
              </Group>
            ))}
            {matches.length > SHOW_LIMIT && (
              <Text size="xs" c="dimmed">
                Showing the first {SHOW_LIMIT}. Type more to narrow it down.
              </Text>
            )}
          </Stack>
        </ScrollArea>
      </Stack>

      <Stack gap="xs" miw={0}>
        <Group justify="space-between">
          <Text fw={600}>Shop items</Text>
          <Group gap="xs">
            <Badge variant="light">{products.length} items</Badge>
            <Badge variant="light" color="gray">{categories} categories</Badge>
            <Badge variant="light" color="gray">stock value {money(stockValue)}</Badge>
          </Group>
        </Group>

        <Group gap="xs" align="flex-end" className="bulk">
          <Text size="xs" c="dimmed" w="100%">
            {selected.length} selected. Blank stock means unlimited. Changes apply to selected rows only.
          </Text>
          <NumberInput size="xs" w={110} label="Set price" min={0} value={bulkPrice} onChange={setBulkPrice} />
          <Button
            size="xs"
            variant="default"
            disabled={!selected.length || num(bulkPrice) === undefined}
            onClick={() => bulk(() => ({ price: Math.round(num(bulkPrice)!) }))}
          >
            Apply
          </Button>
          <NumberInput size="xs" w={110} label="Change by %" value={bulkPct} onChange={setBulkPct} />
          <Button
            size="xs"
            variant="default"
            disabled={!selected.length || num(bulkPct) === undefined}
            onClick={() => bulk((p) => ({ price: Math.max(0, Math.round(p.price * (1 + num(bulkPct)! / 100))) }))}
          >
            Apply
          </Button>
          <NumberInput size="xs" w={110} label="Set stock" min={0} value={bulkStock} onChange={setBulkStock} />
          <Button
            size="xs"
            variant="default"
            disabled={!selected.length}
            onClick={() => bulk(() => ({ defaultStock: num(bulkStock) === undefined ? undefined : Math.round(num(bulkStock)!) }))}
          >
            Apply
          </Button>
          <TextInput size="xs" w={140} label="Set category" value={bulkCategory} onChange={(e) => setBulkCategory(e.currentTarget.value)} />
          <Button size="xs" variant="default" disabled={!selected.length} onClick={() => bulk(() => ({ category: bulkCategory.trim() || undefined }))}>
            Apply
          </Button>
          <Button size="xs" color="red" variant="light" disabled={!selected.length} onClick={removeSelected}>
            Remove selected
          </Button>
        </Group>

        <ScrollArea h={460} type="auto">
          <Table striped highlightOnHover verticalSpacing={4} miw={760}>
            <Table.Thead>
              <Table.Tr>
                <Table.Th w={30}>
                  <Checkbox
                    aria-label="Select all"
                    checked={allSelected}
                    indeterminate={selected.length > 0 && !allSelected}
                    onChange={(e) => setSelected(e.currentTarget.checked ? products.map((p) => p.name) : [])}
                  />
                </Table.Th>
                <Table.Th>Item</Table.Th>
                <Table.Th w={100}>Price</Table.Th>
                <Table.Th w={100}>Stock</Table.Th>
                <Table.Th w={120}>Category</Table.Th>
                <Table.Th w={120}>License</Table.Th>
                <Table.Th w={130}>Job lock</Table.Th>
                <Table.Th w={40} />
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {products.map((p) => {
                const item = labelOf.get(p.name);
                return (
                  <Table.Tr key={p.name}>
                    <Table.Td>
                      <Checkbox aria-label={`Select ${p.name}`} checked={selected.includes(p.name)} onChange={(e) => toggle(p.name, e.currentTarget.checked)} />
                    </Table.Td>
                    <Table.Td>
                      <Group gap="xs" wrap="nowrap">
                        {item && <img src={item.image} alt="" width={24} height={24} style={{ objectFit: 'contain' }} />}
                        <div>
                          <Text size="sm">{item?.label ?? p.name}</Text>
                          <Text size="xs" c="dimmed">{p.name}</Text>
                        </div>
                      </Group>
                    </Table.Td>
                    <Table.Td>
                      <NumberInput size="xs" min={0} value={p.price} onChange={(v) => num(v) !== undefined && update(p.name, { price: Math.round(num(v)!) })} />
                    </Table.Td>
                    <Table.Td>
                      <NumberInput
                        size="xs"
                        min={0}
                        placeholder="Unlimited"
                        value={p.defaultStock ?? ''}
                        onChange={(v) => update(p.name, { defaultStock: num(v) === undefined ? undefined : Math.round(num(v)!) })}
                      />
                    </Table.Td>
                    <Table.Td>
                      <TextInput size="xs" value={p.category ?? ''} onChange={(e) => update(p.name, { category: e.currentTarget.value || undefined })} />
                    </Table.Td>
                    <Table.Td>
                      <TextInput size="xs" value={p.license ?? ''} onChange={(e) => update(p.name, { license: e.currentTarget.value || undefined })} />
                    </Table.Td>
                    <Table.Td>
                      <TextInput
                        size="xs"
                        placeholder="police:2"
                        defaultValue={formatJobs(p.jobs)}
                        onBlur={(e) => update(p.name, { jobs: parseJobs(e.currentTarget.value) })}
                      />
                    </Table.Td>
                    <Table.Td>
                      <ActionIcon variant="subtle" color="red" aria-label={`Remove ${p.name}`} onClick={() => onChange(products.filter((x) => x.name !== p.name))}>
                        <IconTrash size={16} />
                      </ActionIcon>
                    </Table.Td>
                  </Table.Tr>
                );
              })}
            </Table.Tbody>
          </Table>
          {!products.length && (
            <Text c="dimmed" size="sm" p="md">
              No items yet. Search the item list and add some.
            </Text>
          )}
        </ScrollArea>
      </Stack>
    </div>
  );
}
