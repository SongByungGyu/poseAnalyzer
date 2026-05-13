// screens.jsx — screen-level components for PoseAnalyzer iOS kit
// Depends on globals from components.jsx

const { useState } = React;

// ── PostureResultCard ──────────────────────────────────────────
function PostureResultCard({ pose }) {
  const c = STATUS_COLOR[pose.status];
  return (
    <div style={{
      position: 'relative', background: '#FFFFFF',
      borderRadius: 18, border: '1px solid #E2E6EE',
      boxShadow: '0 1px 2px rgba(15,27,45,0.04), 0 4px 14px rgba(15,27,45,0.04)',
      padding: '14px 14px 12px 18px', overflow: 'hidden',
      display: 'flex', flexDirection: 'column', gap: 8,
    }}>
      <div style={{
        position: 'absolute', left: 0, top: 12, bottom: 12, width: 4,
        background: c.fg, borderRadius: '0 4px 4px 0',
      }}/>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: '#0F1B2D', letterSpacing: '-0.005em' }}>{pose.ko}</div>
        <StatusBadge status={pose.status} />
      </div>
      <div style={{
        fontFamily: '-apple-system, "SF Pro Display", system-ui',
        fontSize: 26, fontWeight: 700, letterSpacing: '-0.024em', lineHeight: 1,
        fontVariantNumeric: 'tabular-nums', color: '#0F1B2D',
      }}>
        {pose.metric}{pose.unit && <span style={{ fontSize: 14, color: '#707A8E', fontWeight: 600, marginLeft: 3 }}>{pose.unit}</span>}
      </div>
      <div style={{ height: 4, background: '#EEF1F5', borderRadius: 4, position:'relative', overflow:'hidden' }}>
        <div style={{
          position:'absolute', inset: 0,
          background: 'linear-gradient(90deg, #22A06B 0 33%, #D9A106 33% 66%, #E0683A 66%)',
          opacity: 0.22,
        }}/>
        <div style={{ position:'absolute', top:-3, width: 3, height: 10, borderRadius: 2,
          background: '#0F1B2D',
          left: pose.status === 'normal' ? '18%' : pose.status === 'caution' ? '52%' : pose.status === 'suspect' ? '84%' : '50%',
        }}/>
      </div>
    </div>
  );
}

// ── HomeScreen ─────────────────────────────────────────────────
function HomeScreen({ onStart, onTrend, lastSession }) {
  return (
    <div style={{ padding: '0 16px 100px' }}>
      <NavTop
        title="PoseAnalyzer"
        rightIcon={<Icon name="settings" size={22} />}
      />
      <div style={{ marginTop: 8, marginBottom: 18 }}>
        <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: '-0.02em', color: '#0F1B2D', lineHeight: 1.22 }}>
          오늘의 자세를<br/>측정해보세요
        </div>
        <div style={{ fontSize: 14, color: '#4F5868', marginTop: 6, lineHeight: 1.5 }}>
          정면·측면 사진 2장이면 충분합니다.
        </div>
      </div>

      {/* Hero CTA card */}
      <div onClick={onStart} style={{
        background: 'linear-gradient(135deg, #3B5BDB 0%, #5B6EE8 100%)',
        borderRadius: 22, padding: 18, color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        boxShadow: '0 12px 32px rgba(59,91,219,0.32)',
        cursor: 'pointer',
      }}>
        <div>
          <div style={{ fontSize: 13, fontWeight: 600, opacity: 0.85, letterSpacing: 0.04, textTransform: 'uppercase' }}>3 STEPS · 약 30초</div>
          <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-0.014em', marginTop: 6 }}>측정 시작</div>
        </div>
        <div style={{
          width: 52, height: 52, borderRadius: 999,
          background: 'rgba(255,255,255,0.18)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="camera" size={26} color="#fff"/>
        </div>
      </div>

      {/* Recent summary */}
      <div style={{ marginTop: 22, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.01em' }}>최근 측정</div>
        <button onClick={onTrend} style={{ background:'transparent', border:0, color:'#3B5BDB', fontSize:13, fontWeight:600, cursor:'pointer' }}>
          전체 보기 ›
        </button>
      </div>

      {lastSession ? (
        <Card style={{ marginTop: 10, padding: 14 }}>
          <div style={{ display:'flex', gap: 10, alignItems:'flex-start' }}>
            <div style={{ width: 56, height: 72, borderRadius: 10, overflow:'hidden', flex:'none' }}>
              <PoseSilhouette view="front" joints={false} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between' }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: '#0F1B2D' }}>{lastSession.date}</div>
                <div style={{ fontSize: 12, color: '#707A8E', fontVariantNumeric:'tabular-nums' }}>{lastSession.time}</div>
              </div>
              <div style={{ display:'flex', gap: 4, marginTop: 6 }}>
                {POSE_TYPES.map((p,i)=>(
                  <span key={i} style={{ width: 10, height: 10, borderRadius: 999, background: STATUS_COLOR[p.status].fg }}/>
                ))}
              </div>
              <div style={{ marginTop: 6, fontSize: 12, fontWeight: 600, color: '#22A06B', fontVariantNumeric: 'tabular-nums' }}>
                직전 대비 +2° 개선 · 거북목
              </div>
            </div>
          </div>
        </Card>
      ) : (
        <Card style={{ marginTop: 10, padding: 20, textAlign: 'center' }}>
          <div style={{ fontSize: 13, color: '#707A8E' }}>아직 기록이 없습니다.</div>
          <div style={{ fontSize: 12, color: '#A2ABBC', marginTop: 4 }}>측정을 시작하면 여기에 표시됩니다.</div>
        </Card>
      )}

      {/* 8 conditions teaser */}
      <div style={{ marginTop: 22 }}>
        <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.01em', marginBottom: 10 }}>분석 가능한 자세 8가지</div>
        <div style={{ display:'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
          {POSE_TYPES.map(p => (
            <div key={p.id} style={{
              background:'#FFFFFF', border:'1px solid #E2E6EE', borderRadius: 12,
              padding:'10px 12px', display:'flex', alignItems:'center', justifyContent:'space-between',
            }}>
              <div style={{ fontSize: 13, fontWeight: 600, color: '#0F1B2D' }}>{p.ko}</div>
              <div style={{
                fontSize: 10, fontWeight: 600, color: '#707A8E',
                background: '#F4F6FA', padding: '2px 6px', borderRadius: 6,
              }}>{p.view === 'front' ? '정면' : '측면'}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ── WizardScreen ───────────────────────────────────────────────
function WizardScreen({ step, total = 3, onBack, onNext }) {
  const stepData = [
    { title: '정면 사진', subtitle: '어깨와 골반이 보이도록 정면을 향해주세요', view: 'front' },
    { title: '측면 사진', subtitle: '한쪽 옆모습 전체가 보이도록 서주세요', view: 'side' },
    { title: '키 입력', subtitle: '키를 입력하면 cm 단위로 비대칭을 분석합니다', view: null },
  ];
  const s = stepData[step - 1];
  return (
    <div style={{ paddingBottom: 100, display: 'flex', flexDirection: 'column', minHeight: '100%' }}>
      <NavTop
        title={s.title}
        subtitle={`STEP ${step} / ${total}`}
        leftIcon={<Icon name="chevron-left" size={22}/>}
        onLeft={onBack}
      />
      {/* progress bar */}
      <div style={{ height: 3, background: '#EEF1F5', margin: '0 16px', borderRadius: 999, overflow:'hidden' }}>
        <div style={{ width: `${(step/total)*100}%`, height:'100%', background:'#3B5BDB', transition:'width 220ms cubic-bezier(0.16,1,0.3,1)' }}/>
      </div>

      <div style={{ padding: '16px 16px 0', flex: 1, display:'flex', flexDirection:'column' }}>
        <div style={{ fontSize: 14, color: '#4F5868', lineHeight: 1.5, marginBottom: 16 }}>{s.subtitle}</div>

        {s.view ? (
          <>
            <div style={{ position: 'relative' }}>
              <PoseSilhouette view={s.view} joints={false} />
              {/* guide overlay */}
              <div style={{
                position:'absolute', inset:'5%', borderRadius: 12,
                border: '1.5px dashed rgba(255,255,255,0.55)',
                pointerEvents:'none',
              }}/>
              <div style={{
                position:'absolute', left: 12, top: 12,
                background:'rgba(15,27,45,0.55)', color:'#fff',
                fontSize: 11, fontWeight: 600, padding: '4px 10px', borderRadius: 999,
              }}>
                {s.view === 'front' ? '정면' : '측면'} 가이드
              </div>
            </div>

            <div style={{ display:'flex', gap: 12, marginTop: 16 }}>
              <PrimaryButton variant="secondary" size="md" style={{ flex: 1 }} leftIcon={<Icon name="image" size={18}/>}>
                라이브러리
              </PrimaryButton>
              <PrimaryButton size="md" style={{ flex: 1 }} onClick={onNext} leftIcon={<Icon name="camera" size={18}/>}>
                촬영
              </PrimaryButton>
            </div>
          </>
        ) : (
          <div style={{ marginTop: 8 }}>
            <div style={{ fontSize: 12, fontWeight: 600, color: '#4F5868', marginBottom: 6 }}>키 (cm)</div>
            <div style={{
              height: 56, display:'flex', alignItems:'center',
              background:'#FFFFFF', border:'1.5px solid #3B5BDB',
              borderRadius: 14, padding: '0 16px', gap: 6,
            }}>
              <span style={{
                fontFamily: '-apple-system, "SF Pro Display"', fontSize: 28, fontWeight: 600,
                fontVariantNumeric:'tabular-nums', color:'#0F1B2D',
              }}>172.5</span>
              <span style={{ marginLeft: 'auto', color: '#707A8E', fontSize: 16, fontWeight: 500 }}>cm</span>
            </div>
            <div style={{ fontSize: 12, color: '#707A8E', marginTop: 6 }}>50–250cm 범위로 입력해주세요.</div>

            <div style={{ marginTop: 16, padding: 12, borderRadius: 12, background: '#E6EBFB', display:'flex', gap: 8 }}>
              <Icon name="info" size={18} color="#2A47C3"/>
              <div style={{ fontSize: 12, color: '#2A47C3', lineHeight: 1.5 }}>
                키를 입력하면 좌우 비대칭을 <b>cm 단위</b>로 표시합니다. 입력하지 않으면 <b>어깨너비 비율</b>로 표시합니다.
              </div>
            </div>
          </div>
        )}

        <div style={{ marginTop: 'auto', paddingTop: 16, paddingBottom: 16 }}>
          {step === 3 && (
            <PrimaryButton onClick={onNext} style={{ width:'100%' }}>분석 시작</PrimaryButton>
          )}
        </div>
      </div>
    </div>
  );
}

// ── AnalyzingScreen ────────────────────────────────────────────
function AnalyzingScreen({ phase = 0 }) {
  const phases = ['관절 인식 중…', '자세 분석 중…'];
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 24, padding: 24, paddingBottom: 100 }}>
      <div style={{
        width: 132, height: 132, borderRadius: 999,
        background: 'radial-gradient(circle at 50% 50%, rgba(59,91,219,0.18) 0%, transparent 65%)',
        display:'flex', alignItems:'center', justifyContent:'center',
        animation: 'breathe 1.4s ease-in-out infinite',
      }}>
        <div style={{
          width: 80, height: 80, borderRadius: 999,
          background:'linear-gradient(135deg, #3B5BDB, #5B6EE8)',
          display:'flex', alignItems:'center', justifyContent:'center',
          boxShadow:'0 12px 24px rgba(59,91,219,0.32)',
        }}>
          <Icon name="user" size={36} color="#fff"/>
        </div>
      </div>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-0.014em', color: '#0F1B2D' }}>{phases[phase]}</div>
        <div style={{ fontSize: 13, color: '#707A8E', marginTop: 6 }}>잠시만 기다려주세요</div>
      </div>
      <style>{`@keyframes breathe { 0%,100% { transform: scale(0.92); opacity: 0.8 } 50% { transform: scale(1.04); opacity: 1 } }`}</style>
    </div>
  );
}

// ── ResultScreen ───────────────────────────────────────────────
function ResultScreen({ onSave, onRetry }) {
  return (
    <div style={{ paddingBottom: 110 }}>
      <NavTop
        title="분석 결과"
        subtitle="2026.05.13 · 19:24"
        leftIcon={<Icon name="chevron-left" size={22}/>}
        onLeft={onRetry}
      />
      {/* photos with overlay */}
      <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
        <div>
          <PoseSilhouette view="front" />
          <div style={{ fontSize: 11, color: '#707A8E', textAlign:'center', marginTop: 6, fontFamily:'-apple-system, system-ui' }}>정면 · conf 0.88</div>
        </div>
        <div>
          <PoseSilhouette view="side" status="caution"/>
          <div style={{ fontSize: 11, color: '#707A8E', textAlign:'center', marginTop: 6, fontFamily:'-apple-system, system-ui' }}>측면 · conf 0.83</div>
        </div>
      </div>

      {/* asymmetry */}
      <div style={{ padding: '16px 16px 0' }}>
        <Card style={{ padding: 14 }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#707A8E', letterSpacing: 0.04, textTransform: 'uppercase', marginBottom: 8 }}>좌우 비대칭</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div>
              <div style={{ fontSize: 12, color: '#4F5868', marginBottom: 2 }}>어깨</div>
              <div style={{ fontSize: 18, fontWeight: 700, color: '#0F1B2D', fontVariantNumeric: 'tabular-nums' }}>
                우측 +1.8 <span style={{ fontSize: 13, color: '#707A8E', fontWeight: 600 }}>cm</span>
              </div>
            </div>
            <div>
              <div style={{ fontSize: 12, color: '#4F5868', marginBottom: 2 }}>골반</div>
              <div style={{ fontSize: 18, fontWeight: 700, color: '#0F1B2D', fontVariantNumeric: 'tabular-nums' }}>
                균형 <span style={{ fontSize: 13, color: '#707A8E', fontWeight: 600 }}>±0.2 cm</span>
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* 8 cards */}
      <div style={{ padding: '16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        {POSE_TYPES.map(p => <PostureResultCard key={p.id} pose={p}/>)}
      </div>

      {/* save / retry */}
      <div style={{ padding: '0 16px', display: 'flex', gap: 12 }}>
        <PrimaryButton variant="secondary" size="md" style={{ flex: 1 }} onClick={onRetry}>다시 측정</PrimaryButton>
        <PrimaryButton size="md" style={{ flex: 1 }} onClick={onSave}>저장하기</PrimaryButton>
      </div>
    </div>
  );
}

// ── HistoryScreen ──────────────────────────────────────────────
function HistoryScreen({ sessions, onOpen, onTrend }) {
  return (
    <div style={{ padding: '0 16px 110px' }}>
      <NavTop title="기록" rightIcon={<Icon name="trending-up" size={22}/>} onRight={onTrend}/>
      <div style={{ display:'flex', flexDirection:'column', gap: 10, marginTop: 8 }}>
        {sessions.map((s, i) => (
          <div key={i} onClick={() => onOpen(s)} style={{
            background:'#FFFFFF', border:'1px solid #E2E6EE', borderRadius: 16,
            padding: 12, display:'flex', alignItems:'center', gap: 12, cursor: 'pointer',
          }}>
            <div style={{ display: 'flex', gap: 4, flex: 'none' }}>
              <div style={{ width: 44, height: 60, borderRadius: 8, overflow: 'hidden' }}><PoseSilhouette view="front" joints={false}/></div>
              <div style={{ width: 44, height: 60, borderRadius: 8, overflow: 'hidden' }}><PoseSilhouette view="side" joints={false}/></div>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between' }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: '#0F1B2D' }}>{s.date}</div>
                <div style={{ fontSize: 12, color: '#707A8E', fontVariantNumeric: 'tabular-nums' }}>{s.time}</div>
              </div>
              <div style={{ display:'flex', gap: 4, marginTop: 6 }}>
                {s.statuses.map((st, j) => (
                  <span key={j} style={{ width: 9, height: 9, borderRadius: 999, background: STATUS_COLOR[st].fg }}/>
                ))}
              </div>
              <div style={{ marginTop: 6, fontSize: 12, fontWeight: 600,
                color: s.deltaSign === 'up' ? '#22A06B' : s.deltaSign === 'down' ? '#E0683A' : '#707A8E',
                fontVariantNumeric: 'tabular-nums',
              }}>{s.delta}</div>
            </div>
            <Icon name="chevron-right" size={16} color="#A2ABBC"/>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── TrendScreen ────────────────────────────────────────────────
function TrendScreen({ onBack }) {
  const [pose, setPose] = useState('forwardHead');
  const [range, setRange] = useState('30일');
  // Mock points (angle over time)
  const pts = [168, 165, 170, 167, 172, 169, 171, 174, 172];
  const min = 155, max = 180;
  const pathD = pts.map((v, i) => {
    const x = (i / (pts.length - 1)) * 100;
    const y = 100 - ((v - min) / (max - min)) * 100;
    return `${i === 0 ? 'M' : 'L'} ${x} ${y}`;
  }).join(' ');

  return (
    <div style={{ paddingBottom: 110 }}>
      <NavTop title="추이" leftIcon={<Icon name="chevron-left" size={22}/>} onLeft={onBack}/>
      <div style={{ padding: '0 16px' }}>
        {/* Period seg */}
        <div style={{ display:'inline-flex', background:'#EEF1F5', borderRadius: 10, padding: 3, marginBottom: 14 }}>
          {['7일', '30일', '전체'].map(r => (
            <button key={r} onClick={() => setRange(r)} style={{
              border: 0, padding: '7px 16px', borderRadius: 8, cursor: 'pointer',
              fontFamily:'inherit', fontWeight: 600, fontSize: 13,
              background: range === r ? '#FFFFFF' : 'transparent',
              color: range === r ? '#0F1B2D' : '#707A8E',
              boxShadow: range === r ? '0 1px 2px rgba(15,27,45,0.08)' : 'none',
            }}>{r}</button>
          ))}
        </div>

        {/* Chart */}
        <Card style={{ padding: 16 }}>
          <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', marginBottom: 6 }}>
            <div style={{ fontSize: 14, fontWeight: 600, color: '#0F1B2D' }}>{POSE_TYPES.find(p => p.id === pose).ko}</div>
            <div style={{ fontSize: 11, color: '#707A8E', fontFamily:'-apple-system, system-ui' }}>최근 {pts.length}회</div>
          </div>
          <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: '-0.018em', color: '#0F1B2D', fontVariantNumeric: 'tabular-nums' }}>
            172° <span style={{ fontSize: 13, fontWeight: 600, color: '#22A06B', marginLeft: 6 }}>+6° vs 시작</span>
          </div>
          <div style={{ position: 'relative', height: 160, marginTop: 12 }}>
            <svg viewBox="0 0 100 100" preserveAspectRatio="none" style={{ width: '100%', height: '100%' }}>
              {/* threshold bands */}
              <rect x="0" y="0" width="100" height="20" fill="#E3F4EC" opacity="0.6"/>
              <rect x="0" y="20" width="100" height="20" fill="#FBF1D2" opacity="0.6"/>
              <rect x="0" y="40" width="100" height="60" fill="#FBE5D7" opacity="0.5"/>
              <path d={pathD} stroke="#3B5BDB" strokeWidth="1.5" fill="none" vectorEffect="non-scaling-stroke" strokeLinecap="round" strokeLinejoin="round"/>
              {pts.map((v, i) => {
                const x = (i / (pts.length - 1)) * 100;
                const y = 100 - ((v - min) / (max - min)) * 100;
                return <circle key={i} cx={x} cy={y} r="1.4" fill="#3B5BDB" stroke="#fff" strokeWidth="0.6"/>;
              })}
            </svg>
            <div style={{ position:'absolute', right: 4, top: 2, fontSize: 9, color: '#22A06B', fontFamily:'-apple-system, ui-monospace', fontWeight: 600 }}>정상 ≥170°</div>
            <div style={{ position:'absolute', right: 4, bottom: 24, fontSize: 9, color: '#A94714', fontFamily:'-apple-system, ui-monospace', fontWeight: 600 }}>의심 &lt;160°</div>
          </div>
        </Card>

        {/* pose selector */}
        <div style={{ marginTop: 14 }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: '#707A8E', letterSpacing: 0.04, textTransform: 'uppercase', marginBottom: 8 }}>자세 선택</div>
          <div style={{ display:'grid', gridTemplateColumns:'repeat(2, 1fr)', gap: 6 }}>
            {POSE_TYPES.map(p => (
              <button key={p.id} onClick={() => setPose(p.id)} style={{
                background: pose === p.id ? '#E6EBFB' : '#FFFFFF',
                border: '1px solid', borderColor: pose === p.id ? '#3B5BDB' : '#E2E6EE',
                color: pose === p.id ? '#2A47C3' : '#0F1B2D',
                fontFamily: 'inherit', fontSize: 13, fontWeight: 600,
                padding: '10px 12px', borderRadius: 12, cursor: 'pointer', textAlign:'left',
              }}>{p.ko}</button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  PostureResultCard, HomeScreen, WizardScreen, AnalyzingScreen,
  ResultScreen, HistoryScreen, TrendScreen,
});
