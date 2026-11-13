import { useCallback, useEffect, useState } from 'react';
import { ActionIcon, Button, Group, SegmentedControl, Stack, Text, TextInput, Textarea, UnstyledButton } from '@mantine/core';
import { IconBolt, IconHeart, IconHeartFilled, IconMessageCircle, IconSend, IconTrash } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { PhotoAvatar, PhotoField, PostPhoto } from '../components/PhotoPicker';
import { fetchNui } from '../nui';
import { usePhoto } from '../photos';
import { usePhone } from '../state/phone';
import { ConfirmButton, Card, ErrorText, failure, timeAgo, type Result } from '../kit';
import { Empty } from '../util';

type Post = { id: number; body: string; handle: string; displayName: string; avatarId?: number | null; photoId?: number | null; createdAt: number; likes: number; comments: number; liked: number | boolean; mine: number | boolean };
type Profile = { handle: string; displayName: string; bio?: string; avatarId?: number | null; bannerId?: number | null; isMine?: boolean; isFollowing?: boolean; postCount?: number; followers?: number; following?: number; posts?: Post[] };
type Feed = { tab?: string; profile: Profile | null; posts: Post[] };
type Comment = { id: number; body: string; handle: string; displayName: string; avatarId?: number | null; createdAt: number; mine: number | boolean };

const SAMPLE: Post[] = [
  { id: 1, body: 'Just landed at the Vanilla Unicorn. Who is out tonight?', handle: 'crim', displayName: 'Crim Johnson', createdAt: 1793000000, likes: 12, comments: 3, liked: 1, mine: 1, photoId: 2 },
  { id: 2, body: 'Car meet at the docks, midnight. Bring something loud.', handle: 'nightshift', displayName: 'Night Shift', createdAt: 1792990000, likes: 41, comments: 9, liked: 0, mine: 0 },
];
const MOCK_FEED: Feed = { tab: 'all', profile: { handle: 'crim', displayName: 'Crim Johnson' }, posts: SAMPLE };
const MOCK_PROFILE: Profile = { handle: 'crim', displayName: 'Crim Johnson', bio: 'Everybody wants the top.', isMine: true, postCount: 24, followers: 318, following: 77, posts: SAMPLE, bannerId: 3 };

function Author({ item }: { item: { handle: string; displayName: string; avatarId?: number | null; createdAt: number } }) {
  const { push } = usePhone();
  return (
    <UnstyledButton onClick={() => push('profile', { handle: item.handle })}>
      <Group gap="xs" wrap="nowrap">
        <PhotoAvatar photoId={item.avatarId} name={item.displayName} size="md" />
        <div style={{ minWidth: 0 }}>
          <Text fw={700} size="sm" truncate>{item.displayName}</Text>
          <Text size="xs" c="dimmed" truncate>@{item.handle} · {timeAgo(item.createdAt)}</Text>
        </div>
      </Group>
    </UnstyledButton>
  );
}

function PostCard({ item, refresh }: { item: Post; refresh: () => void }) {
  const { push } = usePhone();
  const liked = !!Number(item.liked);
  return (
    <Card>
      <Author item={item} />
      <Text size="sm" mt="xs" style={{ whiteSpace: 'pre-line', userSelect: 'text' }}>{item.body}</Text>
      {item.photoId ? <PostPhoto id={item.photoId} /> : null}
      <Group gap="md" mt="xs">
        <UnstyledButton className="post-action" onClick={() => push('thread', { id: item.id })}>
          <IconMessageCircle size={17} /> {item.comments}
        </UnstyledButton>
        <UnstyledButton className={`post-action ${liked ? 'liked' : ''}`} onClick={async () => { await fetchNui('feedLike', item.id, true); refresh(); }}>
          {liked ? <IconHeartFilled size={17} /> : <IconHeart size={17} />} {item.likes}
        </UnstyledButton>
        {!!Number(item.mine) && (
          <ConfirmButton size="compact-xs" variant="subtle" color="gray" label={<IconTrash size={15} />} confirmLabel="Delete?"
            onConfirm={async () => { await fetchNui('feedDelete', item.id, true); refresh(); }} />
        )}
      </Group>
    </Card>
  );
}

// Posts are remembered between screens so the thread page can show the original.
const postCache = new Map<number, Post>();

function FeedPage() {
  const { push } = usePhone();
  const [tab, setTab] = useState('all');
  const [feed, setFeed] = useState<Feed | null>(null);
  const [body, setBody] = useState('');
  const [photo, setPhoto] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    const data = await fetchNui<Feed | false>('feedGet', { tab }, MOCK_FEED);
    if (!data) return;
    if (!data.profile) return push('edit', { create: true });
    data.posts.forEach((p) => postCache.set(p.id, p));
    setFeed(data);
  }, [tab, push]);
  useEffect(() => { load(); }, [load]);

  return (
    <AppPage title="Pulse" right={feed?.profile && (
      <UnstyledButton onClick={() => push('profile', { handle: feed.profile!.handle })}>
        <PhotoAvatar photoId={feed.profile.avatarId} name={feed.profile.displayName} size="md" />
      </UnstyledButton>
    )}>
      <Stack gap="sm">
        <SegmentedControl fullWidth radius="xl" value={tab} onChange={setTab} data={[{ label: 'For you', value: 'all' }, { label: 'Following', value: 'following' }]} />
        <Card>
          <Textarea variant="unstyled" placeholder="What is happening in the city?" value={body} maxLength={280} autosize minRows={2}
            onChange={(e) => setBody(e.currentTarget.value)} />
          <PhotoField value={photo} onChange={setPhoto} />
          <ErrorText>{error}</ErrorText>
          <Group justify="space-between" mt="xs">
            <Text size="xs" c="dimmed">{body.length}/280</Text>
            <Button size="xs" radius="xl" leftSection={<IconSend size={14} />} onClick={async () => {
              const result = await fetchNui<Result<Feed>>('feedPost', { body, photoId: photo, tab }, MOCK_FEED);
              const err = failure(result);
              setError(err);
              if (err || !result) return;
              setBody(''); setPhoto(null);
              setFeed(result as Feed);
            }}>Post</Button>
          </Group>
        </Card>
        {feed && feed.posts.length === 0 && <Empty icon={<IconBolt size={36} />}>{tab === 'following' ? 'Follow people to see their posts here.' : 'No posts yet. Be the first.'}</Empty>}
        {(feed?.posts || []).map((p) => <PostCard key={p.id} item={p} refresh={load} />)}
      </Stack>
    </AppPage>
  );
}

function ProfilePage({ handle }: { handle: string }) {
  const { push } = usePhone();
  const [profile, setProfile] = useState<Profile | null>(null);
  const load = useCallback(async () => {
    const data = await fetchNui<Profile | false>('feedProfile', handle, MOCK_PROFILE);
    if (data) { (data.posts || []).forEach((p) => postCache.set(p.id, p)); setProfile(data); }
  }, [handle]);
  useEffect(() => { load(); }, [load]);
  const banner = usePhoto(profile?.bannerId ?? null);

  return (
    <AppPage title={profile?.displayName || 'Profile'} subtitle={profile ? `@${profile.handle}` : undefined} padded={false}>
      {profile && (
        <>
          <div className="profile-banner" style={banner ? { backgroundImage: `url("${banner}")` } : undefined} />
          <div style={{ padding: '0 var(--mantine-spacing-md)' }}>
            <Group justify="space-between" align="flex-end" mt={-36}>
              <PhotoAvatar photoId={profile.avatarId} name={profile.displayName} size={72} className="profile-avatar" />
              {profile.isMine
                ? <Button size="xs" radius="xl" variant="light" onClick={() => push('edit')}>Edit profile</Button>
                : <Button size="xs" radius="xl" variant={profile.isFollowing ? 'light' : 'filled'} onClick={async () => {
                    const data = await fetchNui<Profile | false>('feedFollow', profile.handle, { ...profile, isFollowing: !profile.isFollowing });
                    if (data) setProfile(data);
                  }}>{profile.isFollowing ? 'Following' : 'Follow'}</Button>}
            </Group>
            <Text fw={700} size="lg" mt="xs">{profile.displayName}</Text>
            <Text size="sm" c="dimmed">@{profile.handle}</Text>
            {profile.bio && <Text size="sm" mt={4}>{profile.bio}</Text>}
            <Group gap="lg" mt="xs">
              <Text size="sm"><b>{profile.postCount ?? 0}</b> <Text span c="dimmed">posts</Text></Text>
              <Text size="sm"><b>{profile.followers ?? 0}</b> <Text span c="dimmed">followers</Text></Text>
              <Text size="sm"><b>{profile.following ?? 0}</b> <Text span c="dimmed">following</Text></Text>
            </Group>
            <Stack gap="sm" mt="md" pb="xl">
              {(profile.posts || []).length === 0 && <Empty icon={<IconBolt size={32} />}>No posts yet.</Empty>}
              {(profile.posts || []).map((p) => <PostCard key={p.id} item={p} refresh={load} />)}
            </Stack>
          </div>
        </>
      )}
    </AppPage>
  );
}

function EditPage({ create }: { create: boolean }) {
  const { back, push } = usePhone();
  const [form, setForm] = useState({ handle: '', displayName: '', bio: '', avatarId: null as number | null, bannerId: null as number | null });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (create) return;
    fetchNui<Feed | false>('feedGet', { tab: 'all' }, MOCK_FEED).then(async (feed) => {
      if (!feed || !feed.profile) return;
      const p = await fetchNui<Profile | false>('feedProfile', feed.profile.handle, MOCK_PROFILE);
      if (p) setForm({ handle: p.handle, displayName: p.displayName, bio: p.bio || '', avatarId: p.avatarId ?? null, bannerId: p.bannerId ?? null });
    });
  }, [create]);

  return (
    <AppPage title={create ? 'Create your profile' : 'Edit profile'}>
      <Stack gap="sm">
        <TextInput label="Display name" maxLength={40} value={form.displayName} onChange={(e) => setForm({ ...form, displayName: e.currentTarget.value })} />
        <TextInput label="Handle" leftSection="@" maxLength={20} value={form.handle} onChange={(e) => setForm({ ...form, handle: e.currentTarget.value })} />
        <Textarea label="Bio" maxLength={160} autosize minRows={2} value={form.bio} onChange={(e) => setForm({ ...form, bio: e.currentTarget.value })} />
        <Text size="sm" fw={500}>Profile picture</Text>
        <PhotoField value={form.avatarId} onChange={(id) => setForm({ ...form, avatarId: id })} label="Add profile picture" />
        <Text size="sm" fw={500}>Banner</Text>
        <PhotoField value={form.bannerId} onChange={(id) => setForm({ ...form, bannerId: id })} label="Add banner" />
        <ErrorText>{error}</ErrorText>
        <Button onClick={async () => {
          const result = await fetchNui<Result<Profile>>('feedSaveProfile', form, { ...MOCK_PROFILE, ...form });
          const err = failure(result);
          setError(err);
          if (err || !result) return;
          back();
          if (create) push('profile', { handle: (result as Profile).handle });
        }}>Save</Button>
      </Stack>
    </AppPage>
  );
}

function ThreadPage({ id }: { id: number }) {
  const post = postCache.get(id);
  const [comments, setComments] = useState<Comment[] | null>(null);
  const [body, setBody] = useState('');
  const [error, setError] = useState<string | null>(null);
  const mock = { comments: [{ id: 1, body: 'Pull up!', handle: 'nightshift', displayName: 'Night Shift', createdAt: 1793000100, mine: 0 }] };

  useEffect(() => {
    fetchNui<{ comments: Comment[] } | false>('feedComments', id, mock).then((r) => { if (r) setComments(r.comments); });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const send = async () => {
    const result = await fetchNui<Result<{ comments: Comment[] }>>('feedComment', { postId: id, body }, mock);
    const err = failure(result);
    setError(err);
    if (err || !result) return;
    setBody('');
    setComments((result as { comments: Comment[] }).comments);
  };

  return (
    <AppPage title="Comments">
      <Stack gap="sm">
        {post && (
          <Card>
            <Author item={post} />
            <Text size="sm" mt="xs">{post.body}</Text>
            {post.photoId ? <PostPhoto id={post.photoId} /> : null}
          </Card>
        )}
        <Group gap={6} wrap="nowrap">
          <TextInput style={{ flex: 1 }} radius="xl" placeholder="Add a comment" maxLength={200} value={body}
            onChange={(e) => setBody(e.currentTarget.value)} onKeyDown={(e) => { if (e.key === 'Enter' && body.trim()) send(); }} />
          <ActionIcon size="lg" radius="xl" disabled={!body.trim()} onClick={send}><IconSend size={16} /></ActionIcon>
        </Group>
        <ErrorText>{error}</ErrorText>
        {comments && comments.length === 0 && <Text c="dimmed" size="sm" ta="center">No comments yet.</Text>}
        {(comments || []).map((c) => (
          <Card key={c.id}>
            <Group justify="space-between" wrap="nowrap" align="flex-start">
              <Author item={c} />
              {!!Number(c.mine) && (
                <ConfirmButton size="compact-xs" variant="subtle" color="gray" label={<IconTrash size={14} />} confirmLabel="Delete?"
                  onConfirm={async () => {
                    const r = await fetchNui<{ comments: Comment[] } | false>('feedDeleteComment', { id: c.id, postId: id }, { comments: [] });
                    if (r) setComments(r.comments);
                  }} />
              )}
            </Group>
            <Text size="sm" mt={6}>{c.body}</Text>
          </Card>
        ))}
      </Stack>
    </AppPage>
  );
}

export function PulseApp() {
  const { route } = usePhone();
  switch (route?.page) {
    case 'profile': return <ProfilePage key={String(route.params?.handle)} handle={String(route.params?.handle)} />;
    case 'edit': return <EditPage create={!!route.params?.create} />;
    case 'thread': return <ThreadPage id={Number(route.params?.id)} />;
    default: return <FeedPage />;
  }
}
