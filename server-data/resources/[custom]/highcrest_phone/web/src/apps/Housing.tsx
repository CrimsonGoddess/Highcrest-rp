import { useCallback, useEffect, useState } from 'react';
import { Alert, Badge, Button, Group, Image, Stack, Text } from '@mantine/core';
import { IconHome, IconKey, IconMapPin, IconTrash } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui, isBrowser, useNuiEvent } from '../nui';
import { Card, ConfirmButton, ErrorText, SectionTitle, failure, type Result } from '../kit';
import { Empty, dollars, setWaypoint } from '../util';

type House = { id: number; address: string; salePrice?: number; rentPrice?: number; rentHours?: number; shellLabel?: string; hasPhoto?: boolean; x: number; y: number };
type Home = { address: string; renting?: boolean; rentPrice?: number; rentHours?: number; x: number; y: number };
type Data = { mine: Home[]; houses: House[]; canManage?: boolean };

const MOCK: Data = {
  canManage: true,
  mine: [{ address: '12 Grove Street', renting: true, rentPrice: 900, rentHours: 24, x: 0, y: 0 }],
  houses: [
    { id: 1, address: '3671 Whispymound Drive', salePrice: 450000, rentPrice: 2500, rentHours: 24, shellLabel: 'Modern 2 bedroom', hasPhoto: true, x: 0, y: 0 },
    { id: 2, address: '7 Mirror Park Blvd', salePrice: 210000, x: 0, y: 0 },
  ],
};

// House photos come from the game one at a time ('housePhoto' messages) and are kept for this session.
const photoCache = new Map<number, string>();
const photoWaiters = new Map<number, ((src: string | null) => void)[]>();

function finishHousePhoto(id: number, src: string | null) {
  const waiters = photoWaiters.get(id);
  if (!waiters) return;
  photoWaiters.delete(id);
  if (src) photoCache.set(id, src);
  waiters.forEach((resolve) => resolve(src));
}

function requestHousePhoto(id: number): Promise<string | null> {
  const hit = photoCache.get(id);
  if (hit) return Promise.resolve(hit);
  return new Promise((resolve) => {
    if (!photoWaiters.has(id)) {
      photoWaiters.set(id, []);
      if (isBrowser) setTimeout(() => finishHousePhoto(id, `https://picsum.photos/seed/house${id}/600/360`), 150);
      else fetchNui('housingPhotoGet', id);
      setTimeout(() => finishHousePhoto(id, null), 20000);
    }
    photoWaiters.get(id)!.push(resolve);
  });
}

function HousePhoto({ id }: { id: number }) {
  const [src, setSrc] = useState<string | null>(photoCache.get(id) ?? null);
  useEffect(() => {
    let alive = true;
    requestHousePhoto(id).then((s) => { if (alive) setSrc(s); });
    return () => { alive = false; };
  }, [id]);
  return src ? <Image src={src} radius="md" h={130} fit="cover" /> : <div className="photo-loading" style={{ height: 130 }} />;
}

export function HousingApp() {
  const [data, setData] = useState<Data | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);

  useNuiEvent<{ action: string; id: number; src?: string }>('housePhoto', (m) => finishHousePhoto(m.id, m.src || null));

  const load = useCallback(async () => {
    const d = await fetchNui<Data | false>('housingGet', {}, MOCK);
    if (d) setData(d);
  }, []);
  useEffect(() => { load(); }, [load]);

  const act = async (op: string, id: number) => {
    const r = await fetchNui<Result<{ message?: string }>>(op, id, { message: 'Done.' });
    const err = failure(r);
    setError(err);
    setNotice(!err && r ? (r as { message?: string }).message || null : null);
    if (!err) load();
  };

  return (
    <AppPage title="Housing" subtitle="Dynasty 8 listings">
      <Stack gap="sm">
        <ErrorText>{error}</ErrorText>
        {notice && <Alert color="green" variant="light" py={6}>{notice}</Alert>}

        {(data?.mine || []).length > 0 && <SectionTitle>My homes</SectionTitle>}
        {(data?.mine || []).map((h, i) => (
          <Card key={i}>
            <Group wrap="nowrap">
              <div className="biz-icon"><IconKey size={20} /></div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <Text fw={700} truncate>{h.address}</Text>
                <Text size="xs" c="dimmed">{h.renting ? `Renting, ${dollars(h.rentPrice || 0)} every ${h.rentHours}h` : 'Owned'}</Text>
              </div>
              <Button size="compact-sm" variant="light" leftSection={<IconMapPin size={14} />} onClick={() => setWaypoint(h)}>Go</Button>
            </Group>
          </Card>
        ))}

        <SectionTitle>On the market</SectionTitle>
        {data?.canManage && <Text size="xs" c="dimmed">Realtor: list a house with /addhouse at its front door.</Text>}
        {data && data.houses.length === 0 && <Empty icon={<IconHome size={36} />}>No houses for sale or rent right now.</Empty>}
        {(data?.houses || []).map((h) => (
          <Card key={h.id} p={0} style={{ overflow: 'hidden' }}>
            {h.hasPhoto && <HousePhoto id={h.id} />}
            <div style={{ padding: 'var(--mantine-spacing-sm)' }}>
              <Text fw={700}>{h.address}</Text>
              <Group gap={6} mt={4}>
                {h.salePrice ? <Badge color="green" variant="light">Buy {dollars(h.salePrice)}</Badge> : null}
                {h.rentPrice ? <Badge color="blue" variant="light">Rent {dollars(h.rentPrice)} / {h.rentHours}h</Badge> : null}
              </Group>
              {h.shellLabel && <Text size="xs" c="dimmed" mt={4}>{h.shellLabel}</Text>}
              <Group grow mt="sm" gap="xs">
                <Button size="xs" variant="light" leftSection={<IconMapPin size={16} />} onClick={() => setWaypoint(h)}>Waypoint</Button>
                {h.salePrice ? (
                  <ConfirmButton size="xs" color="green" label="Buy" confirmLabel={`Pay ${dollars(h.salePrice)}?`} onConfirm={() => act('housingBuy', h.id)} />
                ) : null}
                {h.rentPrice ? (
                  <ConfirmButton size="xs" color="blue" label="Rent" confirmLabel={`Rent for ${dollars(h.rentPrice)}?`} onConfirm={() => act('housingRent', h.id)} />
                ) : null}
              </Group>
              {data?.canManage && (
                <ConfirmButton size="xs" mt="xs" fullWidth variant="subtle" color="gray" leftSection={<IconTrash size={14} />}
                  label="Remove listing" confirmLabel="Tap again to remove" onConfirm={() => act('housingRemove', h.id)} />
              )}
            </div>
          </Card>
        ))}
      </Stack>
    </AppPage>
  );
}
