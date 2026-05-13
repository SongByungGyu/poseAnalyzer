// app.jsx — root for PoseAnalyzer iOS UI kit.
// Renders a single IOSDevice frame. Switches between screens with simple state.

const { useState, useEffect } = React;

const MOCK_SESSIONS = [
  { date: '2026.05.13 화', time: '19:24',
    statuses: ['normal','caution','normal','normal','caution','normal','suspect','normal'],
    delta: '직전 대비 +2° 개선 · 거북목', deltaSign: 'up' },
  { date: '2026.05.06 화', time: '08:11',
    statuses: ['normal','caution','caution','normal','normal','unknown','suspect','normal'],
    delta: '직전 대비 −3° 악화 · 라운드숄더', deltaSign: 'down' },
  { date: '2026.04.29 화', time: '07:58',
    statuses: ['caution','suspect','caution','normal','normal','normal','suspect','normal'],
    delta: '직전 대비 −1° 악화 · 거북목', deltaSign: 'down' },
  { date: '2026.04.22 화', time: '20:02',
    statuses: ['caution','suspect','caution','caution','normal','normal','caution','normal'],
    delta: '첫 측정', deltaSign: 'flat' },
];

const LAST = MOCK_SESSIONS[0];

function App() {
  // screen: home | wiz1 | wiz2 | wiz3 | analyzing | result | history | trend
  const [screen, setScreen] = useState('home');
  const [tab, setTab] = useState('home');
  const [analyzePhase, setAnalyzePhase] = useState(0);

  useEffect(() => {
    if (screen === 'analyzing') {
      setAnalyzePhase(0);
      const t1 = setTimeout(() => setAnalyzePhase(1), 900);
      const t2 = setTimeout(() => setScreen('result'), 1800);
      return () => { clearTimeout(t1); clearTimeout(t2); };
    }
  }, [screen]);

  const onTab = (id) => {
    setTab(id);
    setScreen(id === 'home' ? 'home' : 'history');
  };

  let content;
  if (screen === 'home') {
    content = <HomeScreen
      onStart={() => setScreen('wiz1')}
      onTrend={() => { setTab('history'); setScreen('history'); }}
      lastSession={LAST}
    />;
  } else if (screen === 'wiz1') {
    content = <WizardScreen step={1} onBack={() => setScreen('home')} onNext={() => setScreen('wiz2')}/>;
  } else if (screen === 'wiz2') {
    content = <WizardScreen step={2} onBack={() => setScreen('wiz1')} onNext={() => setScreen('wiz3')}/>;
  } else if (screen === 'wiz3') {
    content = <WizardScreen step={3} onBack={() => setScreen('wiz2')} onNext={() => setScreen('analyzing')}/>;
  } else if (screen === 'analyzing') {
    content = <AnalyzingScreen phase={analyzePhase}/>;
  } else if (screen === 'result') {
    content = <ResultScreen
      onRetry={() => setScreen('home')}
      onSave={() => { setTab('history'); setScreen('history'); }}
    />;
  } else if (screen === 'history') {
    content = <HistoryScreen sessions={MOCK_SESSIONS} onOpen={() => setScreen('result')} onTrend={() => setScreen('trend')}/>;
  } else if (screen === 'trend') {
    content = <TrendScreen onBack={() => setScreen('history')}/>;
  }

  // Hide tab bar on certain screens (wizard, analyzing, result) per iOS HIG-ish convention
  const showTabBar = ['home', 'history', 'trend'].includes(screen);

  return (
    <div style={{ position: 'relative', width: 402, height: 874 }}>
      <IOSDevice width={402} height={874}>
        <div style={{ paddingTop: 56, position: 'relative', minHeight: '100%', background: '#F4F6FA' }}>
          {content}
          {showTabBar && <TabBar active={tab} onChange={onTab}/>}
        </div>
      </IOSDevice>
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App/>);
