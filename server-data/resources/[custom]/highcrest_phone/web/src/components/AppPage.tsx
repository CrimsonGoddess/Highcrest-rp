import type { ReactNode } from 'react';
import { ActionIcon, Group, ScrollArea, Text } from '@mantine/core';
import { IconChevronLeft } from '@tabler/icons-react';
import { usePhone } from '../state/phone';

/** Standard app screen: a header with a back button, then scrolling content. */
export function AppPage({ title, subtitle, right, children, padded = true }: {
  title: ReactNode;
  subtitle?: ReactNode;
  right?: ReactNode;
  children: ReactNode;
  padded?: boolean;
}) {
  const { back } = usePhone();
  return (
    <div className="app-page">
      <Group className="app-header" gap={4} wrap="nowrap">
        <ActionIcon variant="subtle" color="gray" size="lg" radius="xl" onClick={back} aria-label="Back">
          <IconChevronLeft size={22} />
        </ActionIcon>
        <div style={{ flex: 1, minWidth: 0 }}>
          <Text fw={700} size="xl" lh={1.1} truncate>{title}</Text>
          {subtitle && <Text size="xs" c="dimmed" truncate>{subtitle}</Text>}
        </div>
        {right}
      </Group>
      <ScrollArea className="app-body" type="never">
        <div style={{ padding: padded ? '0 var(--mantine-spacing-md) var(--mantine-spacing-xl)' : undefined }}>{children}</div>
      </ScrollArea>
    </div>
  );
}
