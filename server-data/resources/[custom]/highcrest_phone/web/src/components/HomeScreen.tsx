import { Text } from '@mantine/core';
import { APPS, type AppDef } from '../apps/registry';
import { pad2, usePhone } from '../state/phone';

const DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

function AppIcon({ app, showLabel = true }: { app: AppDef; showLabel?: boolean }) {
  const { open, phone } = usePhone();
  const Icon = app.icon;
  const badge = phone && app.badge ? app.badge(phone) : 0;
  return (
    <button className="app-icon" onClick={() => open(app.id)}>
      <span className="app-tile" style={{ background: `linear-gradient(145deg, ${app.colors[0]}, ${app.colors[1]})` }}>
        <Icon size={26} stroke={1.8} />
        {badge > 0 && <span className="app-badge">{badge > 99 ? '99+' : badge}</span>}
      </span>
      {showLabel && <span className="app-label">{app.label}</span>}
    </button>
  );
}

export function HomeScreen() {
  const { clock } = usePhone();
  const grid = APPS.filter((app) => !app.dock);
  const dock = APPS.filter((app) => app.dock);
  const now = new Date();

  return (
    <div className="home">
      <div className="widget glass">
        <Text className="widget-clock">{pad2(clock.hours)}:{pad2(clock.minutes)}</Text>
        <Text size="sm" c="dimmed">{DAYS[now.getDay()]} · Los Santos</Text>
        <Text className="widget-brand">HIGHCREST</Text>
      </div>
      <div className="app-grid">
        {grid.map((app) => <AppIcon key={app.id} app={app} />)}
      </div>
      <div className="dock glass">
        {dock.map((app) => <AppIcon key={app.id} app={app} showLabel={false} />)}
      </div>
    </div>
  );
}
