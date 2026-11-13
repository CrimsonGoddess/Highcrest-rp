import { useCallback, useEffect, useState } from 'react';
import {
  ActionIcon,
  Alert,
  Badge,
  Box,
  Button,
  Center,
  Group,
  Loader,
  Modal,
  Paper,
  ScrollArea,
  SegmentedControl,
  Select,
  Stack,
  Table,
  Text,
  TextInput,
  Textarea,
  Title,
  UnstyledButton,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { IconBuildingStore, IconCopy, IconPlus, IconRefresh, IconSearch, IconX } from '@tabler/icons-react';
import { call, closePanel } from './api';
import { ShopEditor } from './ShopEditor';
import { blankShop, shopFromConfig, slugify, uniqueId } from './helpers';
import type { Bootstrap, LogRow, Shop } from './types';

type View = 'custom' | 'config' | 'log';

const copyOf = (s: Shop): Shop => JSON.parse(JSON.stringify(s));
const byLabel = (a: Shop, b: Shop) => a.label.localeCompare(b.label);

export default function App() {
  const [open, setOpen] = useState(false);
  const [boot, setBoot] = useState<Bootstrap | null>(null);
  const [view, setView] = useState<View>('custom');
  const [query, setQuery] = useState('');
  const [draft, setDraft] = useState<Shop | null>(null);
  const [saved, setSaved] = useState<Shop | null>(null);
  const [isNew, setIsNew] = useState(false);
  const [editorKey, setEditorKey] = useState(0);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ color: string; text: string } | null>(null);
  const [armed, setArmed] = useState(false); // a second click or Esc throws away unsaved changes
  const [logRows, setLogRows] = useState<LogRow[]>([]);
  const [newOpen, newModal] = useDisclosure(false);
  const [delOpen, delModal] = useDisclosure(false);
  const [jsonOpen, jsonModal] = useDisclosure(false);
  const [newLabel, setNewLabel] = useState('');
  const [newFrom, setNewFrom] = useState('blank');
  const [jsonText, setJsonText] = useState('');

  const dirty = !!draft && (isNew || JSON.stringify(draft) !== JSON.stringify(saved));
  const anyModal = newOpen || delOpen || jsonOpen;

  const flash = useCallback((color: string, text: string) => setNotice({ color, text }), []);

  useEffect(() => {
    if (!notice) return;
    const t = window.setTimeout(() => setNotice(null), 4500);
    return () => window.clearTimeout(t);
  }, [notice]);

  const act = useCallback(
    async <T,>(action: string, data?: unknown): Promise<T | undefined> => {
      setBusy(true);
      try {
        return await call<T>(action, data);
      } catch (e) {
        flash('red', e instanceof Error ? e.message : 'Request failed.');
        return undefined;
      } finally {
        setBusy(false);
      }
    },
    [flash],
  );

  const refresh = useCallback(async () => {
    const b = await act<Bootstrap>('bootstrap');
    if (b) setBoot(b);
  }, [act]);

  useEffect(() => {
    const onMessage = (e: MessageEvent) => {
      if (e.data?.action === 'open') {
        setOpen(true);
        refresh();
      } else if (e.data?.action === 'close') {
        setOpen(false);
      }
    };
    window.addEventListener('message', onMessage);
    return () => window.removeEventListener('message', onMessage);
  }, [refresh]);

  const closeAll = useCallback(() => {
    setOpen(false);
    setArmed(false);
    closePanel();
  }, []);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key !== 'Escape' || anyModal) return;
      if (dirty && !armed) {
        setArmed(true);
        flash('yellow', 'Unsaved changes. Press Esc again to discard them.');
        return;
      }
      closeAll();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, anyModal, dirty, armed, closeAll, flash]);

  useEffect(() => {
    if (open && view === 'log') act<LogRow[]>('log').then((rows) => rows && setLogRows(rows));
  }, [open, view, act]);

  // Switching shops with unsaved changes asks once more before throwing them away.
  const guard = (fn: () => void) => {
    if (dirty && !armed) {
      setArmed(true);
      flash('yellow', 'Unsaved changes. Click again to discard them.');
      return;
    }
    setArmed(false);
    fn();
  };

  const openShop = (s: Shop, fresh: boolean) => {
    setDraft(s);
    setSaved(fresh ? null : copyOf(s));
    setIsNew(fresh);
    setEditorKey((k) => k + 1);
    setArmed(false);
  };

  const save = async () => {
    if (!draft) return;
    const res = await act<Shop>('save', { isNew, shop: draft });
    if (!res) return;
    setBoot((b) => b && { ...b, shops: [...b.shops.filter((s) => s.id !== res.id), res].sort(byLabel) });
    setDraft(res);
    setSaved(copyOf(res));
    setIsNew(false);
    setArmed(false);
    if (!boot?.efRunning) flash('yellow', 'Saved. ef_shops is not running, so it goes live when ef_shops starts.');
    else if (!res.enabled) flash('green', 'Saved. The shop is off, so it is hidden in game.');
    else flash('green', 'Saved and live in game.');
  };

  const remove = async () => {
    if (!draft) return;
    const ok = await act<boolean>('delete', { id: draft.id });
    if (!ok) return;
    setBoot((b) => b && { ...b, shops: b.shops.filter((s) => s.id !== draft.id) });
    setDraft(null);
    setIsNew(false);
    delModal.close();
    flash('green', 'Shop deleted.');
  };

  const restock = async () => {
    if (!draft) return;
    const ok = await act<boolean>('restock', { id: draft.id });
    if (ok) flash('green', 'Restocked to item defaults.');
  };

  const duplicate = () => {
    if (!draft || !boot) return;
    const label = `${draft.label} copy`;
    const id = uniqueId(slugify(label), boot.shops.map((s) => s.id));
    openShop({ ...copyOf(draft), id, label }, true);
  };

  const createNew = () => {
    const label = newLabel.trim();
    if (!label || !boot) return;
    const id = uniqueId(slugify(label), boot.shops.map((s) => s.id));
    const cfg = boot.config.find((c) => c.id === newFrom);
    const base = cfg ? shopFromConfig(cfg, id) : blankShop(id, label);
    openShop({ ...base, label }, true);
    setView('custom');
    setNewLabel('');
    setNewFrom('blank');
    newModal.close();
  };

  const openJson = () => {
    if (!draft) return;
    setJsonText(JSON.stringify(draft, null, 2));
    jsonModal.open();
  };

  const applyJson = () => {
    try {
      const parsed = JSON.parse(jsonText) as Shop;
      if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error('not a shop object');
      setDraft({ ...parsed, id: isNew ? parsed.id : draft?.id ?? parsed.id });
      setEditorKey((k) => k + 1);
      jsonModal.close();
      flash('blue', 'JSON applied. Save to keep it.');
    } catch (e) {
      flash('red', `JSON not applied: ${e instanceof Error ? e.message : 'invalid'}`);
    }
  };

  if (!open) return null;

  const q = query.trim().toLowerCase();
  const match = (label: string, id: string) => !q || label.toLowerCase().includes(q) || id.toLowerCase().includes(q);
  const customRows = (boot?.shops ?? []).filter((s) => match(s.label, s.id));
  const configRows = (boot?.config ?? []).filter((c) => match(c.label, c.id));

  return (
    <Box className="backdrop">
      <Paper className="panel" withBorder shadow="xl" radius="md">
        <Group justify="space-between" p="md" wrap="nowrap">
          <Group gap="xs" wrap="nowrap">
            <IconBuildingStore size={22} />
            <Title order={4}>Shop admin</Title>
            {boot && (
              <Badge variant="light" color={boot.efRunning ? 'green' : 'red'}>
                {boot.efRunning ? 'ef_shops live' : 'ef_shops not running'}
              </Badge>
            )}
          </Group>
          <Group gap="xs" wrap="nowrap">
            <Text size="sm" c="dimmed">{boot?.actor}</Text>
            <ActionIcon variant="subtle" aria-label="Close" onClick={closeAll}>
              <IconX size={18} />
            </ActionIcon>
          </Group>
        </Group>

        {notice && (
          <Alert color={notice.color} variant="light" mx="md" mb="sm" onClose={() => setNotice(null)} withCloseButton>
            {notice.text}
          </Alert>
        )}

        {!boot ? (
          <Center flex={1}>
            <Loader />
          </Center>
        ) : (
          <Group align="stretch" wrap="nowrap" gap={0} className="panel-body">
            <Stack gap="xs" p="md" className="sidebar">
              <SegmentedControl
                fullWidth
                size="xs"
                value={view}
                onChange={(v) => setView(v as View)}
                data={[
                  { label: `Custom (${boot.shops.length})`, value: 'custom' },
                  { label: `Config (${boot.config.length})`, value: 'config' },
                  { label: 'Log', value: 'log' },
                ]}
              />
              {view !== 'log' && (
                <TextInput
                  placeholder="Search shops"
                  leftSection={<IconSearch size={16} />}
                  value={query}
                  onChange={(e) => setQuery(e.currentTarget.value)}
                />
              )}
              {view === 'custom' && (
                <Button leftSection={<IconPlus size={16} />} onClick={newModal.open}>
                  New shop
                </Button>
              )}
              {view === 'custom' && (
                <ScrollArea style={{ flex: 1, minHeight: 0 }}>
                  <Stack gap={4}>
                    {customRows.map((s) => (
                      <UnstyledButton
                        key={s.id}
                        className="shop-row"
                        data-active={draft?.id === s.id && !isNew ? true : undefined}
                        onClick={() => guard(() => openShop(copyOf(s), false))}
                      >
                        <Group justify="space-between" wrap="nowrap">
                          <div style={{ minWidth: 0 }}>
                            <Text size="sm" fw={500} truncate>{s.label}</Text>
                            <Text size="xs" c="dimmed" truncate>
                              {s.id} · {s.coords.length} loc · {s.products.length} items
                            </Text>
                          </div>
                          {!s.enabled && <Badge size="xs" color="gray">off</Badge>}
                        </Group>
                      </UnstyledButton>
                    ))}
                    {!customRows.length && (
                      <Text size="sm" c="dimmed" p="xs">
                        {boot.shops.length ? 'No shops match.' : 'No custom shops yet.'}
                      </Text>
                    )}
                  </Stack>
                </ScrollArea>
              )}
              {view === 'config' && (
                <ScrollArea style={{ flex: 1, minHeight: 0 }}>
                  <Stack gap={4}>
                    <Text size="xs" c="dimmed">Built into config/locations.lua. Read only. Copy one to make an editable version.</Text>
                    {configRows.map((c) => (
                      <Group key={c.id} justify="space-between" wrap="nowrap" className="shop-row">
                        <div style={{ minWidth: 0 }}>
                          <Text size="sm" fw={500} truncate>{c.label}</Text>
                          <Text size="xs" c="dimmed" truncate>
                            {c.id} · {c.coords.length} loc · {c.products.length} items
                          </Text>
                        </div>
                        <ActionIcon
                          variant="subtle"
                          aria-label={`Copy ${c.label}`}
                          onClick={() =>
                            guard(() => openShop(shopFromConfig(c, uniqueId(slugify(c.id), boot.shops.map((s) => s.id))), true))
                          }
                        >
                          <IconCopy size={16} />
                        </ActionIcon>
                      </Group>
                    ))}
                  </Stack>
                </ScrollArea>
              )}
            </Stack>

            <Box className="main" p="md">
              {view === 'log' ? (
                <Stack gap="sm">
                  <Group justify="space-between">
                    <Title order={5}>Recent changes</Title>
                    <Button variant="default" size="xs" leftSection={<IconRefresh size={14} />} onClick={() => act<LogRow[]>('log').then((rows) => rows && setLogRows(rows))}>
                      Refresh
                    </Button>
                  </Group>
                  <Table striped verticalSpacing={4}>
                    <Table.Thead>
                      <Table.Tr>
                        <Table.Th>When</Table.Th>
                        <Table.Th>Who</Table.Th>
                        <Table.Th>Action</Table.Th>
                        <Table.Th>Shop</Table.Th>
                        <Table.Th>Detail</Table.Th>
                      </Table.Tr>
                    </Table.Thead>
                    <Table.Tbody>
                      {logRows.map((r, i) => (
                        <Table.Tr key={i}>
                          <Table.Td><Text size="xs">{r.created_at}</Text></Table.Td>
                          <Table.Td>{r.actor}</Table.Td>
                          <Table.Td>{r.action}</Table.Td>
                          <Table.Td>{r.shop_id ?? ''}</Table.Td>
                          <Table.Td>{r.detail ?? ''}</Table.Td>
                        </Table.Tr>
                      ))}
                    </Table.Tbody>
                  </Table>
                  {!logRows.length && <Text c="dimmed" size="sm">No changes logged yet.</Text>}
                </Stack>
              ) : draft ? (
                <ShopEditor
                  key={editorKey}
                  shop={draft}
                  isNew={isNew}
                  dirty={dirty}
                  busy={busy}
                  catalog={boot.items}
                  onChange={setDraft}
                  onSave={save}
                  onDelete={delModal.open}
                  onRestock={restock}
                  onDuplicate={duplicate}
                  onJson={openJson}
                  act={act}
                />
              ) : (
                <Center h="100%">
                  <Text c="dimmed">Pick a shop, copy a config shop, or make a new one.</Text>
                </Center>
              )}
            </Box>
          </Group>
        )}
      </Paper>

      <Modal opened={newOpen} onClose={newModal.close} title="New shop" centered>
        <Stack>
          <TextInput label="Name" placeholder="Corner Store" value={newLabel} onChange={(e) => setNewLabel(e.currentTarget.value)} maxLength={48} data-autofocus />
          <Text size="xs" c="dimmed">ID: c_{slugify(newLabel) || '...'}</Text>
          <Select
            label="Start from"
            value={newFrom}
            onChange={(v) => setNewFrom(v ?? 'blank')}
            allowDeselect={false}
            data={[
              { value: 'blank', label: 'Blank shop' },
              ...(boot?.config ?? []).map((c) => ({ value: c.id, label: `Copy of ${c.label} (${c.id})` })),
            ]}
          />
          <Button onClick={createNew} disabled={!newLabel.trim()}>
            Create
          </Button>
        </Stack>
      </Modal>

      <Modal opened={delOpen} onClose={delModal.close} title="Delete shop" centered>
        <Stack>
          <Text size="sm">
            Delete <b>{draft?.label}</b>? It disappears from the game right away. Its log entries stay.
          </Text>
          <Group justify="flex-end">
            <Button variant="default" onClick={delModal.close}>Cancel</Button>
            <Button color="red" onClick={remove} loading={busy}>Delete</Button>
          </Group>
        </Stack>
      </Modal>

      <Modal opened={jsonOpen} onClose={jsonModal.close} title="Shop as JSON" size="lg" centered>
        <Stack>
          <Text size="xs" c="dimmed">Copy it out, or paste a shop in and apply it. Nothing is saved until you press Save.</Text>
          <Textarea
            value={jsonText}
            onChange={(e) => setJsonText(e.currentTarget.value)}
            autosize
            minRows={14}
            maxRows={22}
            styles={{ input: { fontFamily: 'monospace', fontSize: 12 } }}
          />
          <Group justify="flex-end">
            <Button variant="default" onClick={jsonModal.close}>Close</Button>
            <Button onClick={applyJson}>Apply</Button>
          </Group>
        </Stack>
      </Modal>
    </Box>
  );
}
