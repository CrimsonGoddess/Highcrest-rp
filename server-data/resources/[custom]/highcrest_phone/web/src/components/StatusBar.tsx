import { IconAntennaBars5, IconBattery3, IconWifi } from '@tabler/icons-react';
import { pad2, usePhone } from '../state/phone';

export function StatusBar({ hideClock = false }: { hideClock?: boolean }) {
  const { clock } = usePhone();
  return (
    <div className="statusbar">
      <span className="statusbar-time">{hideClock ? '' : `${pad2(clock.hours)}:${pad2(clock.minutes)}`}</span>
      <span className="island" />
      <span className="statusbar-icons">
        <IconAntennaBars5 size={15} stroke={2.2} />
        <IconWifi size={15} stroke={2.2} />
        <IconBattery3 size={18} stroke={1.8} />
      </span>
    </div>
  );
}
