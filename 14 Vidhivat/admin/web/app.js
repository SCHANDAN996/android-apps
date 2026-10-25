'use strict';
const $ = (q, root = document) => root.querySelector(q);
const esc = value => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const n = value => Number(value || 0).toLocaleString('en-IN');
const date = value => new Date(value).toLocaleString('hi-IN', {day:'numeric', month:'short', hour:'2-digit', minute:'2-digit'});
const paths = {
  grid:'<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
  book:'<path d="M12 5c-3-2-6-2-9-1v15c3-1 6-1 9 1 3-2 6-2 9-1V4c-3-1-6-1-9 1v15"/>',
  image:'<rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="8" cy="8" r="1.5"/><path d="m3 17 5-5 4 4 4-6 5 7"/>',
  source:'<path d="M7 3h10l4 4v14H3V3h4Zm10 0v5h4M7 12h10M7 16h7"/>',
  check:'<path d="m5 12 4 4L19 6"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9"/>',
  edit:'<path d="m15 5 4 4M4 20l5-1L21 7a3 3 0 0 0-4-4L5 15l-1 5Z"/>',
  search:'<circle cx="10" cy="10" r="6"/><path d="m15 15 5 5"/>',
  refresh:'<path d="M20 8a8 8 0 1 0 0 9M20 3v5h-5"/>',
  shield:'<path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6l8-3Z"/><path d="m8 12 3 3 5-6"/>',
  plus:'<path d="M12 5v14M5 12h14"/>',
  arrow:'<path d="M4 12h16m-6-6 6 6-6 6"/>',
  folder:'<path d="M3 7V4h6l3 3h9v13H3V7Z"/>',
  clock:'<circle cx="12" cy="12" r="9"/><path d="M12 7v5l4 2"/>',
};
const icon = name => `<svg viewBox="0 0 24 24" aria-hidden="true">${paths[name] || paths.book}</svg>`;
const groups = {vidhi:'पूजा विधि',vrat:'व्रत',paath:'आरती और पाठ',granth:'ग्रंथ',parv:'पर्व',katha:'कथा'};
const sections = [['overview','grid','मुख्य पन्ना'],['content','book','सामग्री संग्रह'],['images','image','चित्र संग्रह'],['sources','source','स्रोत और समस्याएँ'],['drafts','edit','मेरे ड्राफ़्ट'],['tests','check','जाँच और रिपोर्ट']];
const state = {snapshot:null, images:[], token:'', view:'overview', group:'all', query:'', page:0, dirty:false, editor:null, detail:null, jobs:null, poll:null};
let previousFocus = null;

async function api(path, body) {
  const response = await fetch(path, body === undefined ? {} : {method:'POST',headers:{'Content-Type':'application/json','X-Admin-Token':state.token},body:JSON.stringify(body)});
  const result = await response.json();
  if (!response.ok) throw new Error(result.error || 'यह काम पूरा नहीं हुआ।');
  return result;
}
function toast(message) { const t = $('#toast'); t.textContent = message; t.hidden = false; clearTimeout(t.timer); t.timer = setTimeout(() => t.hidden = true, 5000); }
function imageUrl(path) { return '/api/image?path=' + encodeURIComponent(path); }
function badge(text, tone = '') { return `<span class="badge ${tone}">${esc(text)}</span>`; }
function heading(title, description, action = '') { return `<div class="page-head"><div><span class="eyebrow">आपका कार्यस्थल</span><h1>${title}</h1><p>${description}</p></div>${action || `<span class="head-tag">${icon('shield')} स्थानीय सामग्री</span>`}</div>`; }
function empty(title, text, action = '') { return `<div class="empty">${icon('folder')}<h3>${title}</h3><p>${text}</p>${action}</div>`; }
function action(name, label, extra = '', kind = '') { return `<button class="button ${kind}" data-action="${name}" ${extra}>${label}</button>`; }
function artFor(item) {
  const candidates = [`p_${item.id}`, `g_${String(item.id).split('_')[0]}`];
  if (String(item.path).includes('/saptashati/')) candidates.unshift('g_saptashati');
  return state.images.find(i => candidates.includes(i.id));
}
function feature(item) { const art = artFor(item); return `<button class="feature-card" data-action="content" data-path="${esc(item.path)}">${art ? `<img class="feature-art" src="${imageUrl(art.path)}" alt="">` : `<span class="feature-placeholder">${icon('book')}</span>`}<span><h3>${esc(item.name)}</h3><small>${groups[item.group]} <span class="arrow">↗</span></small></span></button>`; }

async function load() {
  $('#refresh').disabled = true;
  try {
    state.token = (await api('/api/session')).token;
    const [snapshot, images] = await Promise.all([api('/api/snapshot'), api('/api/images')]);
    state.snapshot = snapshot; state.images = images;
    $('#scan-time').textContent = 'फ़ाइलें पढ़ीं · ' + date(snapshot.scannedAt);
    renderNav(); render();
  } catch (error) {
    $('#main').innerHTML = empty('कार्यस्थल नहीं खुला', esc(error.message), action('reload', 'फिर कोशिश करें'));
  } finally { $('#refresh').disabled = false; }
}
function renderNav() {
  if (!state.snapshot) return;
  $('#navigation').innerHTML = sections.map(([id, mark, label]) => `<a href="#${id}" class="nav-item ${state.view === id ? 'active' : ''}" ${state.view === id ? 'aria-current="page"' : ''}>${icon(mark)}<span>${label}</span><span>${id === 'drafts' ? n(state.snapshot.drafts.length) : '›'}</span></a>`).join('');
  $('#breadcrumb').textContent = sections.find(v => v[0] === state.view)?.[2] || 'मुख्य पन्ना';
}
function navigate(view) {
  if (!sections.some(v => v[0] === view)) view = 'overview';
  state.view = view; state.page = 0; clearInterval(state.poll); state.poll = null;
  renderNav(); render();
}
function render() {
  if (!state.snapshot) return;
  ({overview:renderOverview,content:renderContent,images:renderImages,sources:renderSources,drafts:renderDrafts,tests:renderTests}[state.view])();
}
function renderOverview() {
  const s = state.snapshot;
  const stats = [[s.items.length,'सामग्री की फ़ाइलें','पूजा, व्रत, पाठ और अध्याय','book'],[state.images.length,'चित्र संग्रह','ऐप में जुड़े स्थानीय चित्र','image'],[s.generatedCount,'मूल स्रोत जुड़े','मूल पाठ से बनी सामग्री','source'],[s.drafts.length,'सहेजे हुए ड्राफ़्ट','ऐप से अलग रखे बदलाव','edit']];
  const featured = ['hanuman_chalisa','ganesh_aarti','gita_01'].map(id => s.items.find(i => i.id === id)).filter(Boolean);
  $('#main').innerHTML = heading('आपकी सामग्री का कार्यस्थल','सामग्री सँवारें, स्रोत देखें और हर बदलाव का ध्यान रखें।') +
    `<div class="stats">${stats.map(([value,label,note,mark]) => `<article class="stat"><div class="stat-top">${label}<span class="stat-icon">${icon(mark)}</span></div><div class="stat-value">${n(value)}</div><div class="stat-note">${note}</div></article>`).join('')}</div>
    <div class="overview-grid"><article class="hero"><span class="eyebrow">एक अच्छी शुरुआत</span><h2>हर पाठ, सही जगह।<br>हर बदलाव, पूरे ध्यान से।</h2><p>अपनी सामग्री खोलें। मूल स्रोत पढ़ें, नया ड्राफ़्ट बनाएँ और आगे बढ़ने से पहले बदलाव देखें।</p>${action('go-content',`सामग्री खोलें ${icon('arrow')}`,'','primary')}</article>
    <article class="panel"><div class="panel-title"><h2>काम करने का सरल क्रम</h2><span class="subtext">01 — 03</span></div>${[['सामग्री चुनें','पूजा, आरती, व्रत या कोई अध्याय'],['मूल स्रोत देखें','स्रोत फ़ाइल और प्रमाण साथ रखें'],['ड्राफ़्ट और जाँच','बदलाव सहेजें; फिर जाँच चलाएँ']].map(([a,b],i) => `<div class="step-row"><span class="step-number">0${i+1}</span><span><strong>${a}</strong><small>${b}</small></span><span class="arrow">↗</span></div>`).join('')}</article></div>
    <div class="section-head"><div><h2>यहीं से आगे बढ़ें</h2><p>आपके संग्रह से कुछ परिचित पाठ</p></div><button class="text-link" data-action="go-content">पूरा संग्रह देखें <span class="arrow">→</span></button></div><div class="featured">${featured.map(feature).join('')}</div>
    <div class="section-head"><h2>समीक्षा और स्थिति</h2></div><div class="overview-grid"><article class="panel"><div class="panel-title"><h2>स्रोत और समस्या-पंजी</h2>${badge(n(s.issueReferences) + ' पहचान','gray')}</div><p class="subtext">श्लोकों की समीक्षा, संस्करण-भेद और दर्ज समस्याओं के मूल रिकॉर्ड पढ़ें। पंजी के संदर्भों की संख्या खुली समस्याओं की संख्या नहीं है।</p>${action('document','समस्या-पंजी खोलें','data-path="docs/JAANCH_SAMASYA_PANJI.md"','small')}</article><article class="panel"><div class="panel-title"><h2>जाँच का रिकॉर्ड</h2>${icon('check')}</div><p class="subtext">पिछली रिपोर्ट देखें या वर्तमान फ़ाइलों पर नई जाँच चलाएँ। पुराने परिणाम अपने समय की फ़ाइलों के लिए हैं।</p>${action('go-tests','जाँच और रिपोर्ट देखें','','small')}</article></div><div class="bottom-note">${icon('shield')} ड्राफ़्ट सहेजने से मोबाइल ऐप की मूल सामग्री नहीं बदलती।</div>`;
}
function contentMatches() {
  const q = state.query.toLowerCase().trim();
  return state.snapshot.items.filter(i => (state.group === 'all' || i.group === state.group) && (!q || `${i.name} ${i.id} ${i.aliases || ''} ${i.description} ${groups[i.group]}`.toLowerCase().includes(q)));
}
function renderContent() {
  $('#main').innerHTML = heading('सामग्री संग्रह','पूजा से ग्रंथ तक—हर सामग्री और उसका मूल स्रोत।') +
    `<div class="toolbar"><div class="tabs">${[['all','सभी'],...Object.entries(groups)].map(([id,name]) => `<button class="chip ${state.group === id ? 'active' : ''}" data-action="group" data-group="${id}">${name}</button>`).join('')}</div><input id="content-search" class="filter-search" type="search" value="${esc(state.query)}" placeholder="नाम या पहचान से खोजें" aria-label="संग्रह में खोजें"></div><div id="content-results"></div>`;
  $('#content-search').addEventListener('input', e => { state.query = e.target.value; state.page = 0; renderContentResults(); });
  renderContentResults();
}
function renderContentResults() {
  const all = contentMatches(), pageSize = 16, pages = Math.max(1, Math.ceil(all.length/pageSize));
  state.page = Math.min(state.page, pages - 1);
  const rows = all.slice(state.page*pageSize,(state.page+1)*pageSize);
  $('#content-results').innerHTML = rows.length ? `<div class="table-wrap"><table class="content-table"><thead><tr><th>सामग्री</th><th>श्रेणी</th><th>मूल स्रोत</th><th>खंड / चरण</th><th></th></tr></thead><tbody>${rows.map(i => `<tr><td><span class="content-name">${esc(i.name)}</span><span class="content-id">${esc(i.id)}</span></td><td>${groups[i.group]}</td><td>${badge(i.generated ? 'स्रोत से निर्मित' : 'संपादन फ़ाइल',i.generated ? '' : 'gray')}${!i.valid ? badge('JSON जाँचें','red') : ''}</td><td class="muted">${i.blocks ? n(i.blocks) : '—'}</td><td>${action('content','खोलें ↗',`data-path="${esc(i.path)}"`,'small')}</td></tr>`).join('')}</tbody></table></div><div class="pagination"><span>${n(all.length)} में से ${n(state.page*pageSize+1)}–${n(Math.min(all.length,(state.page+1)*pageSize))}</span><div><button class="button small" data-action="prev" ${state.page === 0 ? 'disabled' : ''}>← पिछला</button><button class="button small" data-action="next" ${state.page >= pages-1 ? 'disabled' : ''}>अगला →</button></div></div>` : empty('इस खोज में सामग्री नहीं मिली','दूसरा नाम लिखें या श्रेणी बदलें।');
}
function renderImages() {
  const hashes = {};
  state.images.forEach(i => hashes[i.hash] = (hashes[i.hash] || 0) + 1);
  $('#main').innerHTML = heading('चित्र संग्रह','नाम, मूल चित्र और ऐप में इस्तेमाल की समीक्षा करें।') + `<div class="toolbar"><span class="subtext">${n(state.images.length)} चित्र · ${n(Object.values(hashes).filter(v => v > 1).length)} एक जैसे फ़ाइल-समूह</span><input id="image-search" type="search" class="filter-search" placeholder="चित्र का नाम खोजें" aria-label="चित्र खोजें"></div><div class="image-grid" id="image-results"></div>`;
  const draw = q => $('#image-results').innerHTML = state.images.filter(i => `${i.name} ${i.path}`.toLowerCase().includes(q.toLowerCase())).map(i => `<button class="image-card" data-action="image" data-path="${esc(i.path)}"><span class="image-bg"><img src="${imageUrl(i.path)}" alt="${esc(i.name)}" loading="lazy"></span><div class="image-info"><strong>${esc(i.name)}</strong><small>${n(Math.round(i.bytes/1024))} KB · ${n(i.references)} कोड-संदर्भ ${hashes[i.hash] > 1 ? '· एक जैसी प्रति' : ''}</small></div></button>`).join('') || empty('चित्र नहीं मिला','दूसरा नाम खोजें।');
  draw(''); $('#image-search').addEventListener('input', e => draw(e.target.value));
}
function renderSources() {
  $('#main').innerHTML = heading('स्रोत और समस्याएँ','समीक्षा का मूल रिकॉर्ड पढ़ें। प्रमाण और बाकी काम स्पष्ट रखें।') + `<div class="notice">स्रोत की दो फ़ाइलें होना जाँच पूरी होने का प्रमाण नहीं है। छपे पन्ने पढ़ने और वास्तविक मिलान का रिकॉर्ड अलग रहता है।</div><div class="toolbar"><span class="subtext">प्रोजेक्ट के दस्तावेज़</span><input id="doc-search" type="search" class="filter-search" placeholder="स्रोत, पंजी या योजना खोजें" aria-label="दस्तावेज़ खोजें"></div><div class="doc-list" id="doc-results"></div>`;
  const priority = ['JAANCH_SAMASYA_PANJI','04_NEXT','31_DOOSRI_JAANCH','06_CONTENT_TRACKER','08_VERIFICATION'];
  const docs = [...state.snapshot.documents].sort((a,b) => { const rank = d => {const i = priority.indexOf(d.name); return i < 0 ? 99 : i;}; return rank(a)-rank(b); });
  const draw = q => $('#doc-results').innerHTML = docs.filter(d => d.name.toLowerCase().includes(q.toLowerCase())).map(d => `<button class="doc-row" data-action="document" data-path="${esc(d.path)}">${icon('source')}<span><strong>${esc(d.name.replaceAll('_',' '))}</strong><small>${date(d.modified)}</small></span><span class="arrow">↗</span></button>`).join('') || empty('दस्तावेज़ नहीं मिला','दूसरा शब्द लिखें।');
  draw(''); $('#doc-search').addEventListener('input', e => draw(e.target.value));
}
async function renderDrafts() {
  try {
    const [data,drafts] = await Promise.all([api('/api/changes'),api('/api/drafts')]);
    if (state.view !== 'drafts') return;
    state.receipts = data.receipts; state.snapshot.drafts = drafts; renderNav();
  } catch(error) {toast(error.message);return;}
  const drafts = state.snapshot.drafts;
  $('#main').innerHTML = heading('मेरे ड्राफ़्ट','पहले मिलान और जाँच, फिर बैकअप के साथ लागू करें।',action('go-content',`${icon('plus')} सामग्री से ड्राफ़्ट बनाएँ`,'','primary')) +
    (drafts.length ? `<div class="notice">समीक्षा में मूल स्रोत और उससे बनने वाली सभी फ़ाइलें दिखेंगी। लागू करने से पहले बैकअप बनेगा; फोन पर नया ऐप अपडेट अलग से देना होगा।</div><div class="doc-list">${drafts.map(d => {
      const applied = state.receipts.some(r=>r.draftId===d.id && r.status==='applied');
      return `<article class="panel draft-row"><span class="draft-icon">${icon('edit')}</span><div><h3>${esc(d.title)}</h3><p>${esc(d.source)} · ${date(d.savedAt)}</p></div>${badge(applied ? 'लागू किया' : d.conflict ? 'मूल फ़ाइल बदली है' : 'ड्राफ़्ट',applied ? '' : d.conflict ? 'red' : 'amber')}${action('draft','बदलाव देखें',`data-id="${esc(d.id)}"`,'small')}</article>`;
    }).join('')}</div>` : empty('आपका पहला ड्राफ़्ट यहीं मिलेगा','संग्रह से सामग्री खोलें, मूल फ़ाइल चुनें और ड्राफ़्ट सहेजें।',action('go-content','सामग्री संग्रह खोलें','','primary'))) +
    `<div class="section-head"><h2>बैकअप और वापसी</h2></div>` + (state.receipts.length ? `<div class="doc-list">${state.receipts.map(r=>`<article class="doc-row">${icon('clock')}<span><strong>${esc(r.title)}</strong><small>${date(r.appliedAt)} · ${n(r.paths.length)} फ़ाइलें</small></span><span class="arrow">${badge(receiptLabel(r.status),['restored','rolled_back'].includes(r.status)?'gray':r.status==='applied'?'':'red')} ${action('backup','रिकॉर्ड देखें',`data-id="${esc(r.id)}"`,'small')}</span></article>`).join('')}</div>` : empty('अभी कोई बदलाव लागू नहीं हुआ','लागू होने वाले हर बदलाव का बैकअप और वापसी का रिकॉर्ड यहाँ आएगा।'));
}
function receiptLabel(status) { return ({applied:'लागू किया',restored:'वापस लिया',rolled_back:'खुद वापस हुआ',applying:'अधूरा बदलाव',restoring:'अधूरी वापसी',rollback_needed:'वापसी जरूरी',restore_needed:'वापसी जरूरी'})[status] || 'रिकॉर्ड जाँचें'; }
async function renderTests() {
  $('#main').innerHTML = heading('जाँच और रिपोर्ट','वर्तमान फ़ाइलों की जाँच चलाएँ और पुराने परिणाम पढ़ें।') + `<div class="job-actions">${[['admin','पैनल की जाँच'],['app','ऐप की सभी जाँचें'],['engine','गणना इंजन'],['analyze','ऐप की कोड जाँच']].map(([id,label]) => action('run',`${icon('check')} ${label}`,`data-kind="${id}"`)).join('')}</div><div id="jobs"></div><div class="section-head"><div><h2>पुराने रिकॉर्ड</h2><p>हर रिपोर्ट अपने समय की फ़ाइलों के लिए है। ये वर्तमान जाँच की जगह नहीं लेते।</p></div></div><div class="doc-list">${state.snapshot.reports.slice(0,35).map(r => `<button class="doc-row" data-action="document" data-path="${esc(r.path)}">${icon('clock')}<span><strong>${esc(r.name)}</strong><small>${date(r.modified)} · पुराना रिकॉर्ड ${r.count ? '· '+n(r.count)+' जाँचें' : ''}</small></span><span class="arrow">${badge(r.outcome === 'passed' ? 'उस रन में पास' : r.outcome === 'failed' ? 'उस रन में असफल' : 'लॉग',r.outcome === 'failed' ? 'red' : 'gray')}</span></button>`).join('')}</div>`;
  async function poll() {
    try {
      const data = await api('/api/jobs');
      if (state.view !== 'tests') return;
      state.jobs = data;
      document.querySelectorAll('[data-action="run"]').forEach(b => b.disabled = Boolean(data.current?.running));
      const running = data.current?.running ? `<article class="panel job-current"><div class="panel-title"><h2>जाँच चल रही है…</h2>${badge(data.current.kind,'amber')}</div><pre class="job-log">${esc(data.current.lines || 'जाँच शुरू हो रही है…')}</pre></article>` : '';
      $('#jobs').innerHTML = running + data.history.map(h => `<article class="doc-row"><span>${icon('check')}</span><span><strong>${esc(h.kind)} · ${date(h.startedAt)}</strong><small>${h.stale ? 'इनपुट बदले हैं—नई जाँच जरूरी है' : 'सहेजी हुई जाँच के इनपुट समान हैं'}</small></span><span class="arrow">${badge(h.stale ? 'पुरानी जाँच' : h.exitCode === 0 ? 'पास' : 'असफल',h.stale ? 'gray' : h.exitCode === 0 ? '' : 'red')} ${action('document','लॉग',`data-path="${esc(h.logPath)}"`,'small')}</span></article>`).join('');
    } catch (error) { toast(error.message); }
  }
  await poll(); clearInterval(state.poll); if (state.view === 'tests') state.poll = setInterval(poll, 2500);
}

function openDrawer(title, label = 'सामग्री') {
  previousFocus = document.activeElement;
  $('#drawer-title').textContent = title; $('#drawer-label').textContent = label;
  $('#drawer').hidden = false; $('#drawer-backdrop').hidden = false;
  $('#drawer-content').innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  $('#close-drawer').focus(); document.body.classList.add('drawer-open');
}
function closeDrawer() {
  if (state.dirty && !confirm('असहेजा ड्राफ़्ट छोड़कर बन्द करें?')) return false;
  state.dirty = false; state.editor = null; state.detail = null; state.plan = null; state.backup = null;
  $('#drawer').hidden = true; $('#drawer-backdrop').hidden = true;
  document.body.classList.remove('drawer-open'); if (previousFocus?.isConnected) previousFocus.focus(); else $('#main').focus(); return true;
}
async function openContent(path) {
  openDrawer('सामग्री खुल रही है…');
  const item = await api('/api/content?path=' + encodeURIComponent(path)); state.detail = item;
  $('#drawer-title').textContent = item.name;
  detailTab('preview');
}
function detailTab(tab) {
  if (state.dirty && tab !== 'edit' && !confirm('असहेजे बदलाव छोड़कर यह पन्ना खोलें?')) return;
  if (tab !== 'edit') { state.dirty = false; state.editor = null; }
  const item = state.detail;
  $('#drawer-content').innerHTML = `<div class="detail-tabs">${[['preview','प्रीव्यू'],['source','मूल और स्रोत'],['edit','ड्राफ़्ट बनाएँ']].map(([id,label]) => `<button data-action="detail-tab" data-tab="${id}" class="${tab === id ? 'active' : ''}">${label}</button>`).join('')}</div><div class="drawer-body" id="detail-body"></div>`;
  if (tab === 'preview') {
    $('#detail-body').innerHTML = `<div class="detail-facts">${badge(groups[item.group])}${badge(item.generated ? 'मूल से निर्मित' : 'सामग्री फ़ाइल','gray')}</div><div class="preview-controls"><button class="chip active" data-action="preview-size" data-value="normal">सामान्य अक्षर</button><button class="chip" data-action="preview-size" data-value="large">बड़े अक्षर</button><button class="chip" data-action="preview-dark">हल्का / गहरा</button></div>${preview(item.data)}<p class="source-note">पढ़ने का स्थानीय प्रीव्यू · अंतिम ऐप का स्क्रीनशॉट अलग जाँच है</p>`;
  } else if (tab === 'source') {
    $('#detail-body').innerHTML = `<div class="file-path">${esc(item.path)}</div><h3>मूल संपादन फ़ाइलें</h3><div class="doc-list">${item.sourceFiles.map(s => `<button class="doc-row" data-action="source-file" data-path="${esc(s.path)}">${icon('source')}<strong>${esc(s.path)}</strong><span class="arrow">↗</span></button>`).join('')}</div><h3 class="section-head">ऐप में दर्ज स्रोत-नोट</h3><pre class="document-text">${esc(JSON.stringify(item.data.strot || item.data.jaanch || {},null,2))}</pre><p class="subtext">यह दर्ज जानकारी है; इससे नया स्रोत-मिलान अपने आप पूरा नहीं माना गया है।</p>`;
  } else {
    state.editor = null;
    $('#detail-body').innerHTML = `<div class="notice">बदलाव अलग ड्राफ़्ट में रहेंगे। प्रकाशित ऐप और मूल स्रोत अभी नहीं बदलेंगे।</div><label class="editor-label" for="source-select">मूल संपादन फ़ाइल</label><select id="source-select" class="editor-select">${item.sourceFiles.map((s,i) => `<option value="${i}">${esc(s.path)}</option>`).join('')}</select><div id="editor-body"></div>`;
    $('#source-select').addEventListener('change', e => {
      if (state.dirty && !confirm('इस फ़ाइल के असहेजे बदलाव छोड़ें?')) { e.target.value = state.editor.index; return; }
      buildEditor(Number(e.target.value));
    });
    buildEditor(0);
  }
}
function preview(data) {
  const blocks = Array.isArray(data.khand) ? data.khand : Array.isArray(data.charan) ? data.charan : [];
  return `<div class="phone-preview" id="phone-preview"><div class="phone-cap"><span></span></div><div class="phone-inside"><h2>${esc(data.naam || 'सामग्री')}</h2><p>${esc(data.parichay || data.ekLine || '')}</p>${blocks.slice(0,12).map(b => `<h3>${esc(b.shirshak || '')}</h3>${b.vivaran ? `<p>${esc(b.vivaran)}</p>` : ''}${b.dev ? `<p class="verse">${esc(b.dev)}</p>` : ''}${b.arth ? `<p class="meaning">${esc(b.arth)}</p>` : ''}`).join('')}${blocks.length > 12 ? '<p class="subtext">प्रीव्यू में पहले बारह खंड दिख रहे हैं।</p>' : ''}</div></div>`;
}
function buildEditor(index) {
  const source = state.detail.sourceFiles[index];
  if (!source) { $('#editor-body').innerHTML = '<p>मूल फ़ाइल नहीं मिली।</p>'; return; }
  state.dirty = false;
  state.editor = {...source, index, text:source.text, fields:null};
  if (source.path.endsWith('.json')) {
    const data = JSON.parse(source.text);
    state.editor.fields = data;
    const fields = [['naam','नाम'],['ekLine','छोटा परिचय'],['parichay','परिचय'],['kabPadhein','कब पढ़ें'],['kaisePadhein','कैसे पढ़ें']].filter(([id]) => typeof data[id] === 'string');
    $('#editor-body').innerHTML = `${fields.map(([id,label]) => `<label class="editor-label" for="field-${id}">${label}</label><textarea class="form-field" id="field-${id}" rows="${id === 'parichay' || id === 'kaisePadhein' ? 4 : 2}" data-field="${id}">${esc(data[id])}</textarea>`).join('')}<button class="text-link advanced-toggle" data-action="raw-toggle">पूरी स्रोत फ़ाइल देखें / संपादित करें</button><textarea id="raw-editor" class="editor" aria-label="मूल स्रोत का ड्राफ़्ट" ${fields.length ? 'hidden' : ''}>${esc(source.text)}</textarea>${editorTail()}`;
    document.querySelectorAll('[data-field]').forEach(field => field.addEventListener('input', () => {
      state.editor.fields[field.dataset.field] = field.value; state.editor.text = JSON.stringify(state.editor.fields,null,2) + '\n';
      $('#raw-editor').value = state.editor.text; state.dirty = true;
    }));
  } else {
    $('#editor-body').innerHTML = `<label class="editor-label" for="raw-editor">मूल पाठ / अर्थ का ड्राफ़्ट</label><textarea id="raw-editor" class="editor" spellcheck="false">${esc(source.text)}</textarea>${editorTail()}`;
  }
  $('#raw-editor').addEventListener('input', e => { state.editor.text = e.target.value; state.dirty = true; });
  $('#draft-note').addEventListener('input', () => state.dirty = true);
}
function editorTail() { return `<label class="editor-label" for="draft-note">इस बदलाव का आधार / स्रोत-नोट</label><textarea id="draft-note" class="form-field" rows="3" placeholder="किताब, संस्करण, पृष्ठ और बदलाव की वजह लिखें…"></textarea><div class="editor-actions">${action('save-draft',`${icon('edit')} ड्राफ़्ट सहेजें`,'','primary')}${action('draft-preview','ड्राफ़्ट का दृश्य')}<span class="subtext">मूल फ़ाइल सुरक्षित रहेगी</span></div>`; }
async function saveDraft() {
  const e = state.editor;
  const button = $('[data-action="save-draft"]'); button.disabled = true;
  try {
    await api('/api/drafts', {source:e.path, text:e.text, baseHash:e.hash, title:state.detail.name, note:$('#draft-note').value});
    state.dirty = false; state.snapshot.drafts = await api('/api/drafts'); renderNav(); if (state.view === 'overview' || state.view === 'drafts') render();
    toast('ड्राफ़्ट अलग सहेज दिया। मूल सामग्री नहीं बदली।');
  } finally { button.disabled = false; }
}
function showDraft(id) {
  const draft = state.snapshot.drafts.find(d => d.id === id); if (!draft) return;
  openDrawer(draft.title,'सहेजा हुआ ड्राफ़्ट');
  $('#drawer-content').innerHTML = `<div class="drawer-body"><div class="detail-facts">${badge('ड्राफ़्ट','amber')}${draft.conflict ? badge('मूल फ़ाइल बदली है','red') : badge('मूल हैश समान','gray')}</div><div class="file-path">${esc(draft.source)}</div><p class="subtext">${esc(draft.note || 'बदलाव का स्रोत-नोट नहीं जोड़ा गया है।')}</p><div class="diff"><div><h3>मूल पाठ</h3><pre>${esc(draft.before)}</pre></div><div><h3>सहेजा हुआ ड्राफ़्ट</h3><pre class="new">${esc(draft.text)}</pre></div></div><div class="editor-actions">${!draft.conflict ? action('prepare','जाँच और लागू करने का मिलान',`data-id="${esc(id)}"`,'primary') : ''}${action('download-draft','ड्राफ़्ट डाउनलोड करें',`data-id="${esc(id)}"`)}</div><p class="source-note">जाँच और मिलान बनाने से मूल फ़ाइलें नहीं बदलेंगी।</p></div>`;
}
async function prepareDraft(id,button) {
  const label = button.textContent; button.disabled = true; button.textContent = 'अस्थायी मिलान तैयार हो रहा है…';
  try {state.plan = await api('/api/prepare',{id});showPlan();}
  finally {if(button.isConnected){button.disabled=false;button.textContent=label;}}
}
function changeSelector(changes) {
  return `<label class="editor-label" for="change-file">मिलान वाली फ़ाइल</label><select class="editor-select" id="change-file">${changes.map((c,i)=>`<option value="${i}">${esc(c.path)}${c.kind==='generated'?' · दोबारा बनी':''}</option>`).join('')}</select><div id="change-diff"></div>`;
}
function drawChange(changes,index,restoring=false) {
  const c = changes[index];
  $('#change-diff').innerHTML = `<div class="diff"><div><h3>${restoring?'अभी लागू रूप':'पहले'}</h3><pre>${esc(restoring?c.after:c.before)}</pre></div><div><h3>${restoring?'वापसी का पुराना रूप':'तैयार बदलाव'}</h3><pre class="new">${esc(restoring?c.before:c.after)}</pre></div></div>`;
}
function evidenceForm(i) {
  return `<fieldset class="evidence-card"><legend>छपा स्रोत ${i+1}</legend><label class="editor-label" for="book-${i}">किताब</label><input class="form-field" id="book-${i}" autocomplete="off"><label class="editor-label" for="edition-${i}">संस्करण / प्रकाशक</label><input class="form-field" id="edition-${i}" autocomplete="off"><label class="editor-label" for="pages-${i}">पृष्ठ और श्लोक / पद की सीमा</label><input class="form-field" id="pages-${i}" autocomplete="off"><label class="review-check"><input type="checkbox" id="inspected-${i}">मैंने ये छपे पन्ने पढ़कर मिलान किया है।</label></fieldset>`;
}
function showPlan() {
  const plan = state.plan;
  $('#drawer-title').textContent = plan.title; $('#drawer-label').textContent = 'लागू करने से पहले समीक्षा';
  $('#drawer-content').innerHTML = `<div class="drawer-body"><div class="notice">${n(plan.changes.length)} फ़ाइलों का बदलाव तैयार है। मौजूदा स्रोत और ऐप का मिलान व ऐप के ढाँचे की जाँच हो चुकी है। लागू करने से पहले हर बदली फ़ाइल देखें।</div>${changeSelector(plan.changes)}<div class="review-panel"><h3>समीक्षा का आधार</h3>${plan.requiresEvidence?`<p class="subtext">पाठ, अर्थ या नियम बदलते समय दो अलग छपे ग्रंथों का विवरण दें। यह आपकी दर्ज समीक्षा है; पैनल स्वयं किताब पढ़ने या शुद्धता प्रमाणित करने का दावा नहीं करता।</p><div class="evidence-grid">${evidenceForm(0)}${evidenceForm(1)}</div>`:'<p class="subtext">यह JSON के स्वरूप का बदलाव है; सामग्री के मान वही हैं। पुराने और नये रूप का मिलान फिर भी जरूरी है।</p>'}<label class="editor-label" for="apply-reason">इस बदलाव की वजह</label><textarea class="form-field" id="apply-reason" rows="3"></textarea><label class="review-check"><input type="checkbox" id="apply-reviewed">मैंने मूल और तैयार सभी बदली फ़ाइलों का मिलान किया है।</label><div class="editor-actions">${action('apply','बैकअप लेकर लागू करें', 'disabled','primary')}</div><p class="subtext" id="review-hint">वजह और समीक्षा की पुष्टि पूरी करें।</p></div></div>`;
  drawChange(plan.changes,0);
  $('#change-file').addEventListener('change',e=>drawChange(plan.changes,Number(e.target.value)));
  function ready() {
    const reason = $('#apply-reason').value.trim(), checked = $('#apply-reviewed').checked;
    let evidence = true;
    if(plan.requiresEvidence) evidence = [0,1].every(i=>$('#book-'+i).value.trim() && $('#edition-'+i).value.trim() && $('#pages-'+i).value.trim() && $('#inspected-'+i).checked) && $('#book-0').value.trim().toLowerCase()!==$('#book-1').value.trim().toLowerCase();
    $('[data-action="apply"]').disabled = !(reason && checked && evidence);
    $('#review-hint').textContent = reason && checked && evidence ? 'लागू होने से पहले वापसी का पूरा बैकअप बनेगा।' : 'वजह, सभी फ़ाइलों की समीक्षा और आवश्यक स्रोत-विवरण पूरे करें।';
  }
  $('#drawer-content').querySelectorAll('input,textarea').forEach(el=>el.addEventListener('input',ready));
}
async function applyPlan(button) {
  const plan = state.plan; button.disabled = true;
  const evidence = plan.requiresEvidence ? [0,1].map(i=>({book:$('#book-'+i).value,edition:$('#edition-'+i).value,pages:$('#pages-'+i).value,inspected:$('#inspected-'+i).checked})) : [];
  try {
    const receipt = await api('/api/apply',{id:plan.id,reviewHash:plan.reviewHash,reviewed:$('#apply-reviewed').checked,reason:$('#apply-reason').value,evidence});
    state.dirty=false; state.snapshot=await api('/api/snapshot'); renderNav(); render();
    toast('बैकअप बनाकर कार्यप्रति में बदलाव लागू किया। फोन का ऐप अपडेट अलग है।');
    await openBackup(receipt.id);
  } finally {if(button.isConnected)button.disabled=false;}
}
async function openBackup(id) {
  const record = await api('/api/backup?id='+encodeURIComponent(id)); state.backup = record;
  openDrawer(record.title,'बैकअप और वापसी');
  $('#drawer-content').innerHTML = `<div class="drawer-body"><div class="detail-facts">${badge(receiptLabel(record.status),record.status==='applied'?'':'gray')}${badge(n(record.changes.length)+' फ़ाइलें','gray')}</div><p class="subtext">बैकअप बना: ${date(record.appliedAt)}। बाद में बाहर से बदली फ़ाइल को मिटाकर वापसी नहीं होगी।</p>${changeSelector(record.changes)}${record.restoreAllowed?`<label class="review-check"><input type="checkbox" id="restore-reviewed">मैंने वापसी का मिलान देखा है और इन्हीं फ़ाइलों का पिछला रूप वापस चाहता हूँ।</label><div class="editor-actions">${action('restore','इन फ़ाइलों को वापस लें',`data-id="${esc(id)}" disabled`,'primary')}</div>`:`<div class="notice">${esc(record.restoreReason || 'यह बदलाव पहले ही वापस लिया जा चुका है।')}</div>`}</div>`;
  drawChange(record.changes,0,true); $('#change-file').addEventListener('change',e=>drawChange(record.changes,Number(e.target.value),true));
  $('#restore-reviewed')?.addEventListener('change',e=>$('[data-action="restore"]').disabled=!e.target.checked);
}
async function restoreBackup(id,button) {
  button.disabled=true;
  try {
    await api('/api/restore',{id,confirmed:$('#restore-reviewed').checked});
    state.snapshot=await api('/api/snapshot');renderNav();render();
    toast('बैकअप से मूल रूप वापस आ गया।'); await openBackup(id);
  } finally {if(button.isConnected)button.disabled=false;}
}
async function documentView(path) {
  openDrawer(path.split('/').pop().replaceAll('_',' '),'मूल रिकॉर्ड');
  const record = await api('/api/document?path=' + encodeURIComponent(path));
  $('#drawer-content').innerHTML = `<div class="drawer-body"><div class="file-path">${esc(path)}</div><pre class="document-text">${esc(record.text)}</pre></div>`;
}
function imageView(path) {
  const item = state.images.find(i => i.path === path); if (!item) return;
  openDrawer(item.name,'चित्र संग्रह');
  $('#drawer-content').innerHTML = `<div class="drawer-body"><img class="image-detail" src="${imageUrl(path)}" alt="${esc(item.name)}"><div class="file-path">${esc(path)}</div><div class="detail-facts">${badge(n(Math.round(item.bytes/1024))+' KB','gray')}${badge(n(item.references)+' सीधे कोड-संदर्भ','gray')}${item.master ? badge('मूल export का रिकॉर्ड') : ''}</div><p class="subtext">शून्य सीधे संदर्भ का अर्थ निश्चित रूप से अनुपयोगी चित्र होना नहीं है; कुछ रास्ते नामों से बन सकते हैं।</p><p class="subtext">चित्र की पहचान: ${esc(item.hash.slice(0,24))}…</p></div>`;
}

document.addEventListener('click', async event => {
  const button = event.target.closest('[data-action]'); if (!button) return;
  const a = button.dataset.action;
  try {
    if (a === 'reload') await load();
    if (a.startsWith('go-')) location.hash = a.slice(3);
    if (a === 'group') { state.group = button.dataset.group; state.page = 0; renderContent(); }
    if (a === 'prev' || a === 'next') { state.page += a === 'next' ? 1 : -1; renderContentResults(); }
    if (a === 'content') await openContent(button.dataset.path);
    if (a === 'document') await documentView(button.dataset.path);
    if (a === 'source-file') { const source = state.detail.sourceFiles.find(s => s.path === button.dataset.path); $('#detail-body').innerHTML = `<div class="file-path">${esc(source.path)}</div><pre class="document-text">${esc(source.text)}</pre>`; }
    if (a === 'image') imageView(button.dataset.path);
    if (a === 'detail-tab') detailTab(button.dataset.tab);
    if (a === 'preview-dark') $('#phone-preview').classList.toggle('dark');
    if (a === 'preview-size') { $('#phone-preview').classList.toggle('large',button.dataset.value === 'large'); document.querySelectorAll('[data-action="preview-size"]').forEach(b => b.classList.toggle('active', b === button)); }
    if (a === 'raw-toggle') {
      const raw = $('#raw-editor');
      if (!raw.hidden) {
        let parsed; try { parsed = JSON.parse(state.editor.text); } catch { throw new Error('पूरी फ़ाइल में JSON ठीक करके ही सरल फॉर्म पर लौटें।'); }
        state.editor.fields = parsed;
        document.querySelectorAll('[data-field]').forEach(f => f.value = typeof parsed[f.dataset.field] === 'string' ? parsed[f.dataset.field] : '');
      }
      raw.hidden = !raw.hidden; document.querySelectorAll('[data-field]').forEach(f => f.disabled = !raw.hidden);
    }
    if (a === 'save-draft') await saveDraft();
    if (a === 'draft-preview') { const e = state.editor; let data; try { data = JSON.parse(e.text); } catch {} const pane = document.createElement('div'); pane.className = 'draft-inline-preview'; pane.innerHTML = `<h3 class="section-head">ड्राफ़्ट का दृश्य</h3>${data ? preview(data).replace('id="phone-preview"','') : `<pre class="document-text">${esc(e.text)}</pre>`}`; $('.draft-inline-preview')?.remove(); $('#editor-body').append(pane); pane.scrollIntoView({block:'start',behavior:'smooth'}); }
    if (a === 'draft') showDraft(button.dataset.id);
    if (a === 'prepare') await prepareDraft(button.dataset.id,button);
    if (a === 'apply') await applyPlan(button);
    if (a === 'backup') await openBackup(button.dataset.id);
    if (a === 'restore') await restoreBackup(button.dataset.id,button);
    if (a === 'download-draft') { const d = state.snapshot.drafts.find(x => x.id === button.dataset.id); const url = URL.createObjectURL(new Blob([d.text],{type:'text/plain;charset=utf-8'})); const link = document.createElement('a'); link.href = url; link.download = d.source.split('/').pop(); link.click(); setTimeout(() => URL.revokeObjectURL(url),1000); }
    if (a === 'run') { button.disabled = true; await api('/api/jobs',{kind:button.dataset.kind}); await renderTests(); toast('जाँच शुरू हो गई है। नतीजे यहीं आएँगे।'); }
  } catch (error) { toast(error.message); if (a === 'run') button.disabled = false; if (a === 'content' || a === 'document') $('#drawer-content').innerHTML = `<div class="drawer-body"><div class="notice">${esc(error.message)}</div></div>`; }
});
$('#refresh').innerHTML = icon('refresh'); $('#search-icon').innerHTML = icon('search');
$('#refresh').addEventListener('click', () => { if (state.dirty && !confirm('असहेजे बदलाव छोड़कर फिर पढ़ें?')) return; state.dirty = false; closeDrawer(); load(); });
$('#workspace-info').addEventListener('click', () => { if (!state.snapshot) return; openDrawer('आपका प्रोजेक्ट','स्थानीय कार्यस्थल'); $('#drawer-content').innerHTML = `<div class="drawer-body"><div class="file-path">${esc(state.snapshot.workspace)}</div><p class="subtext">यह पैनल इसी कंप्यूटर की सामग्री पढ़ता है। सहेजे हुए ड्राफ़्ट admin/.workspace/drafts में अलग रखे जाते हैं।</p></div>`; });
$('#close-drawer').addEventListener('click', closeDrawer); $('#drawer-backdrop').addEventListener('click', closeDrawer);
window.addEventListener('keydown', event => { if (event.key === 'Escape' && !$('#drawer').hidden) closeDrawer();
  if (event.key === 'Tab' && !$('#drawer').hidden) { const nodes = [...$('#drawer').querySelectorAll('button,input,select,textarea,a[href]')].filter(e => !e.disabled && e.getClientRects().length); const first = nodes[0], last = nodes.at(-1); if (event.shiftKey && document.activeElement === first) {last.focus();event.preventDefault();} else if (!event.shiftKey && document.activeElement === last) {first.focus();event.preventDefault();} }
});
window.addEventListener('beforeunload', event => { if (state.dirty) {event.preventDefault();event.returnValue = '';} });
window.addEventListener('hashchange', () => { if (!$('#drawer').hidden && !closeDrawer()) {history.replaceState(null,'','#'+state.view);return;} navigate(location.hash.slice(1)); });
$('#global-search').addEventListener('input', event => { state.query = event.target.value; state.page = 0; if (!state.snapshot) return; if (state.view !== 'content') { state.group = 'all'; location.hash = 'content'; } else {if ($('#content-search')) $('#content-search').value = state.query; renderContentResults();} });
state.view = sections.some(s => '#'+s[0] === location.hash) ? location.hash.slice(1) : 'overview';
load();
