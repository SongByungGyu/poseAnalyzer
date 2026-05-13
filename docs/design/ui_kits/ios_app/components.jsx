// components.jsx — shared UI primitives for PoseAnalyzer iOS kit
// Loaded via <script type="text/babel">. Exports to window for cross-file use.

const POSE_TYPES = [
  { id: 'forwardHead',         ko: '거북목',         view: 'side',  unit: '°', metric: 172, range: [160, 170], status: 'normal' },
  { id: 'roundShoulder',       ko: '라운드숄더',     view: 'side',  unit: '',  metric: 0.21, range: [0.15, 0.25], status: 'caution' },
  { id: 'kyphosis',            ko: '흉추 후만증',     view: 'side',  unit: '°', metric: 178, range: [165, 175], status: 'normal' },
  { id: 'anteriorPelvicTilt',  ko: '골반 전방경사',   view: 'side',  unit: '°', metric: 182, range: [170, 190], status: 'normal' },
  { id: 'kneeHyperextension',  ko: '무릎 과신전',     view: 'side',  unit: '°', metric: 187, range: [175, 190], status: 'caution' },
  { id: 'scoliosis',           ko: '척추측만',        view: 'front', unit: '°', metric: 1.4, range: [2, 5], status: 'normal' },
  { id: 'headTilt',            ko: '머리 좌우 기울기', view: 'front', unit: '°', metric: 5.8, range: [2, 5], status: 'suspect' },
  { id: 'kneeAlignment',       ko: '무릎 X자/O자',    view: 'front', unit: '°', metric: 177, range: [170, 185], status: 'normal' },
];

const STATUS_LABEL = {
  normal:  '정상',
  caution: '주의',
  suspect: '의심',
  unknown: '측정 불가',
};

const STATUS_COLOR = {
  normal:  { fg: '#22A06B', bg: '#E3F4EC', text: '#15784E' },
  caution: { fg: '#D9A106', bg: '#FBF1D2', text: '#8B6904' },
  suspect: { fg: '#E0683A', bg: '#FBE5D7', text: '#A94714' },
  unknown: { fg: '#8A94A6', bg: '#ECEEF2', text: '#4F5868' },
};

// ── Atoms ──────────────────────────────────────────────────────

function StatusBadge({ status, large, tone = 'soft' }) {
  const c = STATUS_COLOR[status];
  const big = large;
  if (tone === 'solid') {
    return (
      <span style={{
        display: 'inline-flex', alignItems: 'center', gap: 6,
        padding: big ? '6px 12px' : '4px 10px', borderRadius: 999,
        fontSize: big ? 13 : 11, fontWeight: 700, letterSpacing: '-0.005em',
        background: c.fg, color: '#fff',
      }}>
        <span style={{ width: big ? 8 : 6, height: big ? 8 : 6, borderRadius: 999, background: '#fff', opacity: 0.85 }} />
        {STATUS_LABEL[status]}
      </span>
    );
  }
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: big ? '5px 11px' : '3px 9px', borderRadius: 999,
      fontSize: big ? 12 : 11, fontWeight: 700, letterSpacing: '-0.005em',
      background: c.bg, color: c.text,
    }}>
      <span style={{ width: big ? 8 : 7, height: big ? 8 : 7, borderRadius: 999, background: c.fg }} />
      {STATUS_LABEL[status]}
    </span>
  );
}

function PrimaryButton({ children, onClick, variant = 'primary', size = 'lg', disabled, leftIcon, style }) {
  const variants = {
    primary:   { bg: '#3B5BDB', fg: '#fff' },
    secondary: { bg: '#E6EBFB', fg: '#2A47C3' },
    ghost:     { bg: 'transparent', fg: '#3B5BDB' },
    danger:    { bg: '#E0683A', fg: '#fff' },
  };
  const sizes = {
    lg: { pad: '16px 24px', font: 17, minH: 56, radius: 16 },
    md: { pad: '12px 20px', font: 16, minH: 48, radius: 14 },
    sm: { pad: '8px 14px',  font: 14, minH: 36, radius: 10 },
  };
  const v = variants[variant], s = sizes[size];
  return (
    <button
      onClick={disabled ? undefined : onClick}
      style={{
        background: disabled ? '#ECEEF2' : v.bg,
        color: disabled ? '#A2ABBC' : v.fg,
        padding: s.pad, fontSize: s.font, minHeight: s.minH, borderRadius: s.radius,
        border: 0, fontFamily: 'inherit', fontWeight: 600, letterSpacing: '-0.005em',
        cursor: disabled ? 'not-allowed' : 'pointer',
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        transition: 'transform 120ms cubic-bezier(0.16,1,0.3,1), background 120ms',
        ...style,
      }}
      onMouseDown={e => !disabled && (e.currentTarget.style.transform = 'scale(0.97)')}
      onMouseUp={e => (e.currentTarget.style.transform = 'scale(1)')}
      onMouseLeave={e => (e.currentTarget.style.transform = 'scale(1)')}
    >
      {leftIcon}
      {children}
    </button>
  );
}

// Inline icon paths — Lucide. Self-contained so we don't depend on external SVG <use> loading.
const ICONS = {
  'camera': 'M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3Z|circle:12,13,4',
  'bar-chart': 'M3 3v18h18|rect:7,13,3,5|rect:12,8,3,10|rect:17,5,3,13',
  'settings': 'M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2Z|circle:12,12,3',
  'circle-dot': 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z|circle:12,12,3',
  'chevron-left': 'm15 18-6-6 6-6',
  'chevron-right': 'm9 18 6-6-6-6',
  'trending-up': 'm22 7-8.5 8.5L8.5 10.5 2 17M16 7h6v6',
  'trending-down': 'm22 17-8.5-8.5L8.5 13.5 2 7M16 17h6v-6',
  'arrow-right': 'M5 12h14M13 5l7 7-7 7',
  'rotate-ccw': 'M3 12a9 9 0 1 0 9-9 9.74 9.74 0 0 0-6.74 2.74L3 8M3 3v5h5',
  'check-circle': 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z|m9 12 2 2 4-4',
  'image': 'M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z|circle:9,9,2|m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21',
  'info': 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20ZM12 16v-4M12 8h.01',
  'alert': 'm21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3ZM12 9v4M12 17h.01',
  'x': 'M18 6 6 18M6 6l12 12',
  'plus': 'M5 12h14M12 5v14',
  'calendar': 'M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2ZM16 2v4M8 2v4M3 10h18',
  'clock': 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20ZM12 6v6l4 2',
  'user': 'M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2|circle:12,7,4',
};
function Icon({ name, size = 24, color = 'currentColor', stroke = 2 }) {
  const def = ICONS[name];
  if (!def) return <svg width={size} height={size}/>;
  const parts = def.split('|');
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round" style={{ flex: 'none' }}>
      {parts.map((p, i) => {
        if (p.startsWith('circle:')) {
          const [cx, cy, r] = p.slice(7).split(',').map(Number);
          return <circle key={i} cx={cx} cy={cy} r={r}/>;
        }
        if (p.startsWith('rect:')) {
          const [x, y, w, h] = p.slice(5).split(',').map(Number);
          return <rect key={i} x={x} y={y} width={w} height={h}/>;
        }
        return <path key={i} d={p}/>;
      })}
    </svg>
  );
}

// ── Surface / layout ───────────────────────────────────────────

function Card({ children, style }) {
  return (
    <div style={{
      background: '#FFFFFF',
      borderRadius: 20,
      border: '1px solid #E2E6EE',
      boxShadow: '0 1px 2px rgba(15,27,45,0.04), 0 4px 16px rgba(15,27,45,0.05)',
      padding: 16,
      ...style,
    }}>{children}</div>
  );
}

function NavTop({ title, leftIcon, rightIcon, onLeft, onRight, subtitle }) {
  return (
    <div style={{
      paddingTop: 8, paddingBottom: 8, paddingLeft: 12, paddingRight: 12,
      display: 'flex', alignItems: 'center', minHeight: 44,
      background: 'rgba(244,246,250,0.0)',
    }}>
      <div style={{ width: 44, display: 'flex', justifyContent: 'flex-start' }}>
        {leftIcon && (
          <button onClick={onLeft} style={{ background:'transparent', border:0, padding:8, color:'#3B5BDB', cursor:'pointer' }}>
            {leftIcon}
          </button>
        )}
      </div>
      <div style={{ flex:1, textAlign: 'center', display: 'flex', flexDirection: 'column', gap: 1 }}>
        <div style={{ fontSize: 17, fontWeight: 700, letterSpacing: '-0.01em', color: '#0F1B2D' }}>{title}</div>
        {subtitle && <div style={{ fontSize: 11, fontWeight: 600, color: '#707A8E', letterSpacing: '0.01em' }}>{subtitle}</div>}
      </div>
      <div style={{ width: 44, display: 'flex', justifyContent: 'flex-end' }}>
        {rightIcon && (
          <button onClick={onRight} style={{ background:'transparent', border:0, padding:8, color:'#3B5BDB', cursor:'pointer' }}>
            {rightIcon}
          </button>
        )}
      </div>
    </div>
  );
}

function TabBar({ active, onChange }) {
  const tabs = [
    { id: 'home',    label: '측정', icon: 'camera' },
    { id: 'history', label: '기록', icon: 'bar-chart' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      height: 83, paddingTop: 8, paddingBottom: 32,
      background: 'rgba(255,255,255,0.78)',
      backdropFilter: 'blur(20px) saturate(180%)',
      WebkitBackdropFilter: 'blur(20px) saturate(180%)',
      borderTop: '1px solid #E2E6EE',
      display: 'flex', alignItems: 'flex-start', justifyContent: 'space-around',
      zIndex: 40,
    }}>
      {tabs.map(t => (
        <button key={t.id} onClick={() => onChange(t.id)} style={{
          background:'transparent', border:0, cursor:'pointer',
          display:'flex', flexDirection:'column', alignItems:'center', gap:2,
          color: active === t.id ? '#3B5BDB' : '#8A94A6',
          fontSize: 11, fontWeight: 600, fontFamily: 'inherit', padding: '4px 12px',
        }}>
          <Icon name={t.icon} size={26} />
          {t.label}
        </button>
      ))}
    </div>
  );
}

// ── Photo / overlay ────────────────────────────────────────────

function PoseSilhouette({ view = 'front', joints = true, status }) {
  const accent = status ? STATUS_COLOR[status].fg : '#56BAB0';
  return (
    <div style={{
      position: 'relative',
      width: '100%', aspectRatio: '3 / 4',
      borderRadius: 14,
      background: 'linear-gradient(180deg, #707A8E 0%, #353D4B 100%)',
      overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute', inset: 0,
        background:
          view === 'front'
            ? `radial-gradient(ellipse 12% 8% at 50% 14%, #1F2532 60%, transparent 62%),
               radial-gradient(ellipse 20% 14% at 50% 30%, #1F2532 60%, transparent 62%),
               radial-gradient(ellipse 14% 26% at 50% 56%, #1F2532 60%, transparent 62%),
               radial-gradient(ellipse 16% 14% at 38% 82%, #1F2532 60%, transparent 62%),
               radial-gradient(ellipse 16% 14% at 62% 82%, #1F2532 60%, transparent 62%)`
            : `radial-gradient(ellipse 10% 8% at 56% 14%, #1F2532 60%, transparent 62%),
               radial-gradient(ellipse 14% 16% at 52% 32%, #1F2532 60%, transparent 62%),
               radial-gradient(ellipse 12% 30% at 49% 58%, #1F2532 60%, transparent 62%),
               radial-gradient(ellipse 14% 14% at 50% 85%, #1F2532 60%, transparent 62%)`,
        filter: 'blur(2px)',
      }}/>
      {joints && (
        <svg viewBox="0 0 100 133" preserveAspectRatio="none" style={{ position:'absolute', inset:0, width:'100%', height:'100%' }}>
          {view === 'front' ? (
            <g>
              <g stroke="#56BAB0" strokeWidth="0.8" strokeLinecap="round" fill="none" opacity="0.92">
                <line x1="50" y1="18" x2="50" y2="32"/>
                <line x1="38" y1="40" x2="62" y2="40"/>
                <line x1="38" y1="40" x2="38" y2="70"/>
                <line x1="62" y1="40" x2="62" y2="70"/>
                <line x1="42" y1="72" x2="58" y2="72"/>
                <line x1="42" y1="72" x2="40" y2="110"/>
                <line x1="58" y1="72" x2="60" y2="110"/>
              </g>
              <g fill="#3B5BDB" stroke="#FFFFFF" strokeWidth="0.5">
                {[
                  [50,18,2.2],[38,40,1.8],[62,40,1.8],[38,70,1.6],[62,70,1.6],
                  [42,72,1.6],[58,72,1.6],[40,110,1.6],[60,110,1.6],
                ].map(([x,y,r], i) => <circle key={i} cx={x} cy={y} r={r}/>)}
              </g>
            </g>
          ) : (
            <g>
              <g stroke="#56BAB0" strokeWidth="0.8" strokeLinecap="round" fill="none" opacity="0.92">
                <line x1="58" y1="18" x2="52" y2="34"/>
                <line x1="52" y1="34" x2="48" y2="74"/>
                <line x1="48" y1="74" x2="50" y2="108"/>
              </g>
              <path d="M 56 22 A 8 8 0 0 1 53 30" stroke={accent} strokeWidth="0.9" fill="none" strokeDasharray="1.5 1.5"/>
              <g fill="#3B5BDB" stroke="#FFFFFF" strokeWidth="0.5">
                {[[58,18,2.2],[52,34,1.8],[48,74,1.8],[50,108,1.6]].map(([x,y,r],i)=>(<circle key={i} cx={x} cy={y} r={r}/>))}
              </g>
            </g>
          )}
        </svg>
      )}
    </div>
  );
}

Object.assign(window, {
  POSE_TYPES, STATUS_LABEL, STATUS_COLOR,
  StatusBadge, PrimaryButton, Icon, Card,
  NavTop, TabBar, PoseSilhouette,
});
