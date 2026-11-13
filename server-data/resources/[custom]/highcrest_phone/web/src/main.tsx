import { Component, StrictMode, type ReactNode } from 'react';
import { createRoot } from 'react-dom/client';
import '@mantine/core/styles.css';
import './global.css';
import App from './App';
import { fetchNui, reportError } from './nui';

window.addEventListener('error', (e) => reportError(`${e.message} @ ${e.filename}:${e.lineno}`));
window.addEventListener('unhandledrejection', (e) => reportError(`Unhandled promise: ${String(e.reason?.stack || e.reason)}`));

/** If a screen crashes: log it, show it on the phone, and give the mouse back instead of a blank screen. */
class Crash extends Component<{ children: ReactNode }, { error: Error | null }> {
  state = { error: null as Error | null };
  static getDerivedStateFromError(error: Error) { return { error }; }
  componentDidCatch(error: Error, info: { componentStack?: string | null }) {
    reportError(`${error.stack || error.message}\n${info.componentStack || ''}`);
  }
  render() {
    if (!this.state.error) return this.props.children;
    const restart = () => { fetchNui('close'); this.setState({ error: null }); };
    return (
      <div style={{ position: 'fixed', right: '3vh', bottom: '3vh', width: '34vh', padding: '2vh', borderRadius: '2vh',
        background: 'rgba(11,11,13,0.92)', color: '#f5f5f5', fontFamily: 'sans-serif', fontSize: '1.4vh' }}>
        <b style={{ color: '#ff6b6b' }}>The phone hit an error</b>
        <p style={{ opacity: 0.8, wordBreak: 'break-word' }}>{this.state.error.message}</p>
        <button onClick={restart} style={{ padding: '0.8vh 1.6vh', borderRadius: '1vh', border: 0, background: '#C8102E', color: '#fff' }}>Close phone</button>
      </div>
    );
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Crash>
      <App />
    </Crash>
  </StrictMode>,
);
