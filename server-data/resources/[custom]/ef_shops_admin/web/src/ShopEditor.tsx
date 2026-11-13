import {
  ActionIcon,
  Badge,
  Button,
  Group,
  NumberInput,
  Paper,
  SimpleGrid,
  Stack,
  Switch,
  Table,
  Tabs,
  TagsInput,
  Text,
  TextInput,
  Title,
} from '@mantine/core';
import { IconCopy, IconDeviceFloppy, IconFileExport, IconPlus, IconRefresh, IconTrash, IconWalk, IconMapPin } from '@tabler/icons-react';
import type { CatalogItem, Shop, Vec4 } from './types';
import { formatJobs, parseJobs } from './helpers';
import { ItemsEditor } from './ItemsEditor';

type Props = {
  shop: Shop;
  isNew: boolean;
  dirty: boolean;
  busy: boolean;
  catalog: CatalogItem[];
  onChange: (shop: Shop) => void;
  onSave: () => void;
  onDelete: () => void;
  onRestock: () => void;
  onDuplicate: () => void;
  onJson: () => void;
  act: <T>(action: string, data?: unknown) => Promise<T | undefined>;
};

const num = (v: number | string) => (typeof v === 'number' ? v : undefined);

export function ShopEditor({ shop, isNew, dirty, busy, catalog, onChange, onSave, onDelete, onRestock, onDuplicate, onJson, act }: Props) {
  const set = (patch: Partial<Shop>) => onChange({ ...shop, ...patch });

  const setCoord = (i: number, key: keyof Vec4, value: number) =>
    set({ coords: shop.coords.map((c, idx) => (idx === i ? { ...c, [key]: value } : c)) });

  const addCoord = (c: Vec4) => set({ coords: [...shop.coords, c] });

  const addMyPosition = async () => {
    const pos = await act<Vec4>('position');
    if (pos) addCoord({ x: round(pos.x), y: round(pos.y), z: round(pos.z), w: round(pos.w) });
  };

  const teleport = (c: Vec4) => act('teleport', { x: c.x, y: c.y, z: c.z });

  return (
    <Stack gap="md">
      <Group justify="space-between" align="flex-start" wrap="wrap">
        <div>
          <Title order={3}>{shop.label || 'Untitled shop'}</Title>
          <Group gap="xs" mt={4}>
            <Badge variant="light" color={isNew ? 'blue' : 'gray'} tt="none">{isNew ? 'New, not saved' : shop.id}</Badge>
            {!shop.enabled && <Badge color="gray">Disabled, hidden in game</Badge>}
            {dirty && <Badge color="yellow">Unsaved changes</Badge>}
          </Group>
        </div>
        <Group gap="xs">
          <Button leftSection={<IconDeviceFloppy size={16} />} onClick={onSave} loading={busy} disabled={!dirty}>
            Save
          </Button>
          <Button variant="default" leftSection={<IconRefresh size={16} />} onClick={onRestock} disabled={isNew || dirty || !shop.enabled}>
            Restock
          </Button>
          <Button variant="default" leftSection={<IconCopy size={16} />} onClick={onDuplicate}>
            Duplicate
          </Button>
          <Button variant="default" leftSection={<IconFileExport size={16} />} onClick={onJson}>
            JSON
          </Button>
          <Button color="red" variant="light" leftSection={<IconTrash size={16} />} onClick={onDelete} disabled={isNew}>
            Delete
          </Button>
        </Group>
      </Group>
      {!isNew && dirty && (
        <Text size="xs" c="dimmed">Saving restocks this shop to its item defaults.</Text>
      )}

      <Tabs defaultValue="details" keepMounted={false}>
        <Tabs.List>
          <Tabs.Tab value="details">Details</Tabs.Tab>
          <Tabs.Tab value="locations">Locations ({shop.coords.length})</Tabs.Tab>
          <Tabs.Tab value="items">Items ({shop.products.length})</Tabs.Tab>
        </Tabs.List>

        <Tabs.Panel value="details" pt="md">
          <Stack gap="lg">
            <SimpleGrid cols={{ base: 1, sm: 2 }}>
              <TextInput label="Name" required value={shop.label} onChange={(e) => set({ label: e.currentTarget.value })} maxLength={48} />
              <TextInput
                label="ID"
                description={isNew ? 'Letters, numbers and _. Cannot change after saving.' : 'Fixed once saved.'}
                value={shop.id}
                disabled={!isNew}
                onChange={(e) => set({ id: e.currentTarget.value.toLowerCase() })}
              />
              <Switch
                label="Open for business"
                description="Off hides the shop in game without deleting it."
                checked={shop.enabled}
                onChange={(e) => set({ enabled: e.currentTarget.checked })}
              />
              <TagsInput
                label="Vendor models"
                description="Ped or prop names. Leave empty for an invisible shop zone. Press Enter after each one."
                placeholder="e.g. mp_m_shopkeep_01"
                value={shop.models ?? []}
                onChange={(models) => set({ models: models.length ? models : undefined })}
                maxTags={10}
                clearable
              />
            </SimpleGrid>

            <Paper withBorder p="md" radius="md">
              <Text fw={600} mb="xs">Map blip</Text>
              <SimpleGrid cols={{ base: 2, sm: 4 }}>
                <Switch
                  label="Hide blip"
                  checked={shop.blip.disabled}
                  onChange={(e) => set({ blip: { ...shop.blip, disabled: e.currentTarget.checked } })}
                />
                <NumberInput label="Sprite" min={0} max={830} disabled={shop.blip.disabled} value={shop.blip.sprite} onChange={(v) => num(v) !== undefined && set({ blip: { ...shop.blip, sprite: Math.round(num(v)!) } })} />
                <NumberInput label="Colour" min={0} max={85} disabled={shop.blip.disabled} value={shop.blip.color} onChange={(v) => num(v) !== undefined && set({ blip: { ...shop.blip, color: Math.round(num(v)!) } })} />
                <NumberInput label="Scale" min={0.1} max={2} step={0.05} decimalScale={2} disabled={shop.blip.disabled} value={shop.blip.scale} onChange={(v) => num(v) !== undefined && set({ blip: { ...shop.blip, scale: num(v)! } })} />
              </SimpleGrid>
            </Paper>

            <Paper withBorder p="md" radius="md">
              <Text fw={600} mb="xs">Interaction</Text>
              <SimpleGrid cols={{ base: 1, sm: 3 }}>
                <TextInput label="Target label" placeholder="Browse Shop" value={shop.target.label ?? ''} onChange={(e) => set({ target: { ...shop.target, label: e.currentTarget.value || undefined } })} />
                <TextInput label="Target icon" description="FontAwesome class" placeholder="fas fa-cash-register" value={shop.target.icon ?? ''} onChange={(e) => set({ target: { ...shop.target, icon: e.currentTarget.value || undefined } })} />
                <NumberInput label="Target radius" min={0.5} max={50} step={0.5} decimalScale={1} value={shop.target.radius} onChange={(v) => num(v) !== undefined && set({ target: { ...shop.target, radius: num(v)! } })} />
              </SimpleGrid>
            </Paper>

            <Paper withBorder p="md" radius="md">
              <TextInput
                label="Shop job lock"
                description="Only these jobs can use the shop. Format job:grade, separated by commas. Blank means everyone."
                placeholder="police:0, ambulance:2"
                key={shop.id}
                defaultValue={formatJobs(shop.jobs)}
                onBlur={(e) => set({ jobs: parseJobs(e.currentTarget.value) })}
              />
            </Paper>
          </Stack>
        </Tabs.Panel>

        <Tabs.Panel value="locations" pt="md">
          <Stack gap="md">
            <Group>
              <Button variant="light" leftSection={<IconMapPin size={16} />} onClick={addMyPosition}>
                Add my position
              </Button>
              <Button variant="default" leftSection={<IconPlus size={16} />} onClick={() => addCoord({ x: 0, y: 0, z: 0, w: 0 })}>
                Add blank
              </Button>
            </Group>
            <Text size="xs" c="dimmed">Heading is in degrees. Each location gets its own vendor and map blip.</Text>
            {!shop.coords.length && <Text c="dimmed" size="sm">No locations yet. Stand where the shop should be and press Add my position.</Text>}
            {shop.coords.length > 0 && (
              <Table striped verticalSpacing={4} miw={520}>
                <Table.Thead>
                  <Table.Tr>
                    <Table.Th>#</Table.Th>
                    <Table.Th>X</Table.Th>
                    <Table.Th>Y</Table.Th>
                    <Table.Th>Z</Table.Th>
                    <Table.Th>Heading</Table.Th>
                    <Table.Th />
                  </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                  {shop.coords.map((c, i) => (
                    <Table.Tr key={i}>
                      <Table.Td>{i + 1}</Table.Td>
                      {(['x', 'y', 'z', 'w'] as const).map((k) => (
                        <Table.Td key={k}>
                          <NumberInput size="xs" decimalScale={3} step={0.1} value={c[k]} onChange={(v) => num(v) !== undefined && setCoord(i, k, num(v)!)} />
                        </Table.Td>
                      ))}
                      <Table.Td>
                        <Group gap={4} wrap="nowrap">
                          <ActionIcon variant="subtle" aria-label={`Teleport to location ${i + 1}`} onClick={() => teleport(c)}>
                            <IconWalk size={16} />
                          </ActionIcon>
                          <ActionIcon variant="subtle" color="red" aria-label={`Remove location ${i + 1}`} onClick={() => set({ coords: shop.coords.filter((_, idx) => idx !== i) })}>
                            <IconTrash size={16} />
                          </ActionIcon>
                        </Group>
                      </Table.Td>
                    </Table.Tr>
                  ))}
                </Table.Tbody>
              </Table>
            )}
          </Stack>
        </Tabs.Panel>

        <Tabs.Panel value="items" pt="md">
          <ItemsEditor products={shop.products} catalog={catalog} onChange={(products) => set({ products })} />
        </Tabs.Panel>
      </Tabs>
    </Stack>
  );
}

const round = (n: number) => Math.round(n * 1000) / 1000;
