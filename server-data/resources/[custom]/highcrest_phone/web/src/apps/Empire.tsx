import { useCallback, useEffect, useState } from 'react';
import { ActionIcon, Badge, Button, Chip, Group, Menu, NumberInput, Stack, Text, TextInput, UnstyledButton } from '@mantine/core';
import {
  IconBuildingStore, IconCash, IconChevronRight, IconCrown, IconDots, IconMapPin, IconSettings, IconUserMinus, IconUserPlus,
} from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui } from '../nui';
import { usePhone } from '../state/phone';
import { Card, ConfirmButton, ErrorText, SectionTitle, failure, timeAgo, type Result } from '../kit';
import { Empty, dollars, setWaypoint } from '../util';

type Overview = {
  offers: { id: number; businessName: string; rankName: string }[];
  mine: { id: number; name: string; typeLabel: string; rankName: string }[];
  market: { id: number; name: string; typeLabel: string; price: number; x: number; y: number }[];
};
type Rank = { id: number; name: string; level: number; permissions: string[]; isOwnerRank: boolean };
type Member = { id: number; name: string; rankId: number; rankName: string; level: number; manageable: boolean };
type Business = {
  id: number; name: string; typeLabel: string; rankName: string; isOwner: boolean; sellPrice: number; balance?: number | null;
  notice?: string;
  can: { hire?: boolean; fire?: boolean; promote?: boolean; deposit?: boolean; withdraw?: boolean; pay?: boolean; ledger?: boolean };
  staff: Member[]; ranks: Rank[]; permissionList: { id: string; label: string }[];
  ledger?: { type: string; amount: number; actor: string; note?: string; createdAt: number }[];
  x: number; y: number;
};

const empire = <T,>(op: string, args?: unknown, mock?: T) => fetchNui<Result<T>>('empire', { op, args }, mock as Result<T>);

const MOCK_OVERVIEW: Overview = {
  offers: [{ id: 1, businessName: 'Vanilla Lounge', rankName: 'Employee' }],
  mine: [{ id: 2, name: 'Crimson Room', typeLabel: 'Nightclub', rankName: 'Owner' }],
  market: [{ id: 3, name: 'Legion Auto', typeLabel: 'Mechanic', price: 250000, x: 0, y: 0 }],
};
const MOCK_BUSINESS: Business = {
  id: 2, name: 'Crimson Room', typeLabel: 'Nightclub', rankName: 'Owner', isOwner: true, sellPrice: 500000, balance: 182500,
  can: { hire: true, fire: true, promote: true, deposit: true, withdraw: true, pay: true, ledger: true },
  staff: [
    { id: 1, name: 'Crim Johnson', rankId: 1, rankName: 'Owner', level: 100, manageable: false },
    { id: 2, name: 'Night Shift', rankId: 2, rankName: 'Manager', level: 50, manageable: true },
  ],
  ranks: [
    { id: 1, name: 'Owner', level: 100, permissions: [], isOwnerRank: true },
    { id: 2, name: 'Manager', level: 50, permissions: ['hire', 'deposit'], isOwnerRank: false },
    { id: 3, name: 'Employee', level: 10, permissions: [], isOwnerRank: false },
  ],
  permissionList: [
    { id: 'hire', label: 'Hire staff' }, { id: 'fire', label: 'Fire staff' }, { id: 'promote', label: 'Change ranks' },
    { id: 'deposit', label: 'Deposit money' }, { id: 'withdraw', label: 'Withdraw money' }, { id: 'pay', label: 'Pay staff' }, { id: 'ledger', label: 'See transactions' },
  ],
  ledger: [{ type: 'deposit', amount: 5000, actor: 'Crim Johnson', note: '', createdAt: 1793000000 }],
  x: 0, y: 0,
};

const LEDGER_LABELS: Record<string, string> = { deposit: 'Deposit', withdraw: 'Withdrawal', pay: 'Wage', revenue: 'Revenue', purchase: 'Ownership', staff: 'Staff' };

// The business page and the ranks page share the latest copy of the business.
let current: Business | null = null;

function OverviewPage() {
  const { push } = usePhone();
  const [data, setData] = useState<Overview | null>(null);
  const [error, setError] = useState<string | null>(null);
  const load = useCallback(async () => {
    const r = await empire<Overview>('overview', undefined, MOCK_OVERVIEW);
    if (r && !failure(r)) setData(r as Overview);
  }, []);
  useEffect(() => { load(); }, [load]);

  const apply = (r: Result<Overview>) => {
    const err = failure(r);
    setError(err);
    if (!err && r) setData(r as Overview);
    else load();
  };

  return (
    <AppPage title="Empire" subtitle="Own the city">
      <Stack gap="sm">
        <ErrorText>{error}</ErrorText>
        {(data?.offers || []).length > 0 && <SectionTitle>Job offers</SectionTitle>}
        {(data?.offers || []).map((o) => (
          <Card key={o.id} style={{ borderColor: 'rgba(212,175,55,0.5)' }}>
            <Text fw={700}>{o.businessName}</Text>
            <Text size="xs" c="dimmed">Job offer: {o.rankName}</Text>
            <Group grow mt="sm" gap="xs">
              <Button size="xs" variant="light" color="gray" onClick={async () => apply(await empire('respondOffer', { id: o.id, accept: false }, MOCK_OVERVIEW))}>Decline</Button>
              <Button size="xs" color="gold" c="dark" onClick={async () => apply(await empire('respondOffer', { id: o.id, accept: true }, MOCK_OVERVIEW))}>Accept</Button>
            </Group>
          </Card>
        ))}

        <SectionTitle>My businesses</SectionTitle>
        {data && data.mine.length === 0 && <Text size="sm" c="dimmed">You don't own or work at a business yet.</Text>}
        {(data?.mine || []).map((b) => (
          <UnstyledButton key={b.id} onClick={() => push('business', { id: b.id })}>
            <Card>
              <Group wrap="nowrap">
                <div className="biz-icon"><IconCrown size={20} /></div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <Text fw={700} truncate>{b.name}</Text>
                  <Text size="xs" c="dimmed">{b.typeLabel} · {b.rankName}</Text>
                </div>
                <IconChevronRight size={18} opacity={0.5} />
              </Group>
            </Card>
          </UnstyledButton>
        ))}

        <SectionTitle>For sale</SectionTitle>
        {data && data.market.length === 0 && <Empty icon={<IconBuildingStore size={32} />}>Nothing for sale right now.</Empty>}
        {(data?.market || []).map((b) => (
          <Card key={b.id}>
            <Group justify="space-between" wrap="nowrap">
              <div style={{ minWidth: 0 }}>
                <Text fw={700} truncate>{b.name}</Text>
                <Text size="xs" c="dimmed">{b.typeLabel}</Text>
              </div>
              <Text fw={700} c="gold.6">{dollars(b.price)}</Text>
            </Group>
            <Group grow mt="sm" gap="xs">
              <Button size="xs" variant="light" leftSection={<IconMapPin size={16} />} onClick={() => setWaypoint(b)}>Waypoint</Button>
              <ConfirmButton size="xs" color="gold" c="dark" label="Buy" confirmLabel={`Tap again to pay ${dollars(b.price)}`}
                onConfirm={async () => apply(await empire('buy', b.id, MOCK_OVERVIEW))} />
            </Group>
          </Card>
        ))}
      </Stack>
    </AppPage>
  );
}

function BusinessPage({ id }: { id: number }) {
  const { push, back } = usePhone();
  const [biz, setBiz] = useState<Business | null>(current && current.id === id ? current : null);
  const [error, setError] = useState<string | null>(null);
  const [amount, setAmount] = useState<number | string>('');
  const [hireNumber, setHireNumber] = useState('');

  const show = (b: Business) => { current = b; setBiz(b); };
  useEffect(() => {
    empire<Business>('business', id, MOCK_BUSINESS).then((r) => {
      const err = failure(r);
      if (err) return setError(err);
      show(r as Business);
    });
  }, [id]);

  // Every action returns the updated business.
  const run = async (op: string, args: Record<string, unknown>) => {
    const r = await empire<Business>(op, { id, ...args }, current || MOCK_BUSINESS);
    const err = failure(r);
    setError(err);
    if (!err && r) show(r as Business);
    return !err;
  };

  if (!biz) return <AppPage title="Business"><ErrorText>{error}</ErrorText></AppPage>;
  const can = biz.can;

  return (
    <AppPage title={biz.name} subtitle={`${biz.typeLabel} · Your rank: ${biz.rankName}`} right={
      <Group gap={4}>
        <ActionIcon variant="light" radius="xl" size="lg" onClick={() => setWaypoint(biz)} aria-label="Waypoint"><IconMapPin size={18} /></ActionIcon>
        {biz.isOwner && <ActionIcon variant="light" radius="xl" size="lg" onClick={() => push('ranks', { id })} aria-label="Ranks"><IconSettings size={18} /></ActionIcon>}
      </Group>
    }>
      <Stack gap="sm">
        {biz.notice && <Text size="sm" c="gold.6">{biz.notice}</Text>}
        <ErrorText>{error}</ErrorText>

        {biz.balance != null && (
          <Card className="glass biz-balance">
            <Text size="xs" tt="uppercase" fw={700} c="dimmed">Business account</Text>
            <Text className="biz-money">{dollars(biz.balance)}</Text>
            {(can.deposit || can.withdraw || can.pay) && (
              <NumberInput mt="xs" placeholder="Amount" prefix="$" min={1} thousandSeparator="," hideControls value={amount} onChange={setAmount} />
            )}
            <Group grow mt="xs" gap="xs">
              {can.deposit && <Button size="xs" variant="light" color="green" onClick={async () => { if (await run('deposit', { amount })) setAmount(''); }}>Deposit</Button>}
              {can.withdraw && <Button size="xs" variant="light" onClick={async () => { if (await run('withdraw', { amount })) setAmount(''); }}>Withdraw</Button>}
            </Group>
          </Card>
        )}

        <SectionTitle>Staff</SectionTitle>
        {can.hire && (
          <Group gap={6} wrap="nowrap">
            <TextInput style={{ flex: 1 }} placeholder="Phone number to hire" maxLength={15} value={hireNumber}
              onChange={(e) => setHireNumber(e.currentTarget.value.replace(/[^\d]/g, ''))} />
            <Button leftSection={<IconUserPlus size={16} />} onClick={async () => { if (await run('hire', { number: hireNumber })) setHireNumber(''); }}>Hire</Button>
          </Group>
        )}
        {biz.staff.map((m) => {
          const ranks = biz.ranks.filter((r) => r.id !== m.rankId && !r.isOwnerRank);
          const canManage = m.manageable && (can.promote || can.fire);
          return (
            <Card key={m.id}>
              <Group wrap="nowrap">
                <div style={{ flex: 1, minWidth: 0 }}>
                  <Text fw={700} truncate>{m.name}</Text>
                  <Badge size="sm" variant="light" color={m.level >= 100 ? 'gold' : 'gray'}>{m.rankName}</Badge>
                </div>
                {can.pay && (
                  <Button size="compact-sm" variant="light" color="green" leftSection={<IconCash size={14} />}
                    onClick={() => (amount ? run('pay', { memberId: m.id, amount }) : setError('Enter an amount in the business account first.'))}>Pay</Button>
                )}
                {canManage && (
                  <Menu position="bottom-end" withinPortal={false}>
                    <Menu.Target><ActionIcon variant="subtle" color="gray" radius="xl"><IconDots size={18} /></ActionIcon></Menu.Target>
                    <Menu.Dropdown>
                      {can.promote && ranks.map((r) => (
                        <Menu.Item key={r.id} onClick={() => run('setRank', { memberId: m.id, rankId: r.id })}>Make {r.name}</Menu.Item>
                      ))}
                      {can.fire && <Menu.Item color="red" leftSection={<IconUserMinus size={14} />} onClick={() => run('fire', { memberId: m.id })}>Fire</Menu.Item>}
                    </Menu.Dropdown>
                  </Menu>
                )}
              </Group>
            </Card>
          );
        })}

        {can.ledger && (
          <>
            <SectionTitle>Transactions</SectionTitle>
            {(biz.ledger || []).length === 0 && <Text size="sm" c="dimmed">No transactions yet.</Text>}
            {(biz.ledger || []).map((e, i) => (
              <Group key={i} justify="space-between" wrap="nowrap" className="ledger-row">
                <div style={{ minWidth: 0 }}>
                  <Text size="sm" fw={600}>{LEDGER_LABELS[e.type] || e.type}{Number(e.amount) > 0 ? ` ${dollars(e.amount)}` : ''}</Text>
                  <Text size="xs" c="dimmed" truncate>{e.note ? `${e.actor}: ${e.note}` : e.actor}</Text>
                </div>
                <Text size="xs" c="dimmed" style={{ flexShrink: 0 }}>{timeAgo(e.createdAt)}</Text>
              </Group>
            ))}
          </>
        )}

        {biz.isOwner ? (
          <ConfirmButton mt="md" variant="subtle" color="red" label={`Sell for ${dollars(biz.sellPrice)}`} confirmLabel="Tap again to sell. Staff will be let go."
            onConfirm={async () => { const r = await empire('sell', id, MOCK_OVERVIEW); const err = failure(r); setError(err); if (!err) back(); }} />
        ) : (
          <ConfirmButton mt="md" variant="subtle" color="red" label="Leave this job" confirmLabel="Tap again to leave"
            onConfirm={async () => { const r = await empire('leave', id, MOCK_OVERVIEW); const err = failure(r); setError(err); if (!err) back(); }} />
        )}
      </Stack>
    </AppPage>
  );
}

function RankCard({ rank, biz, onSaved }: { rank: Rank; biz: Business; onSaved: (b: Business, name: string) => void }) {
  const [name, setName] = useState(rank.name);
  const [perms, setPerms] = useState<string[]>(rank.permissions);
  const [error, setError] = useState<string | null>(null);
  return (
    <Card>
      <TextInput value={name} maxLength={30} onChange={(e) => setName(e.currentTarget.value)} />
      {rank.isOwnerRank ? (
        <Text size="xs" c="dimmed" mt="xs">Owners can always do everything.</Text>
      ) : (
        <Chip.Group multiple value={perms} onChange={setPerms}>
          <Group gap={6} mt="xs">
            {biz.permissionList.map((p) => <Chip key={p.id} value={p.id} size="xs" radius="sm">{p.label}</Chip>)}
          </Group>
        </Chip.Group>
      )}
      <ErrorText>{error}</ErrorText>
      <Button size="xs" mt="sm" fullWidth onClick={async () => {
        const r = await empire<Business>('saveRank', { id: biz.id, rankId: rank.id, name, permissions: perms }, biz);
        const err = failure(r);
        setError(err);
        if (!err && r) onSaved(r as Business, name);
      }}>Save rank</Button>
    </Card>
  );
}

function RanksPage() {
  const [biz, setBiz] = useState<Business | null>(current);
  const [saved, setSaved] = useState('');
  if (!biz) return <AppPage title="Ranks"><Text c="dimmed">Open the business first.</Text></AppPage>;
  return (
    <AppPage title="Ranks and permissions" subtitle={biz.name}>
      <Stack gap="sm">
        {saved && <Text size="sm" c="green.4">{saved}</Text>}
        {biz.ranks.map((r) => (
          <RankCard key={`${r.id}-${r.name}`} rank={r} biz={biz} onSaved={(b, name) => { current = b; setBiz(b); setSaved(`${name} saved.`); }} />
        ))}
      </Stack>
    </AppPage>
  );
}

export function EmpireApp() {
  const { route } = usePhone();
  if (route?.page === 'business') return <BusinessPage id={Number(route.params?.id)} />;
  if (route?.page === 'ranks') return <RanksPage />;
  return <OverviewPage />;
}
