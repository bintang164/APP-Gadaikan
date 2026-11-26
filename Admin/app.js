'use strict';

const $ = (id) => document.getElementById(id);
const escapeHtml = (value) =>
  String(value ?? '').replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  })[c]);

const DEMO = {
  stats: {
    total: 3, submitted: 1, under_review: 1, approved: 1, rejected: 0, active_transactions: 1,
  },
  applications: [
    {
      id: 'demo-1', code: 'GDK-DEMO-0001', customer_name: 'Nasabah Demo',
      category: 'elektronik', status: 'submitted', created_at: '2026-11-25T09:00:00',
      item_title: 'Laptop Demo', item_details: { 'Merek': 'Contoh', 'Model': 'Demo' },
      admin_note: '',
      documents: [{ id: 'd1', label: 'Foto Depan' }],
      status_history: [{ status: 'submitted', title: 'Dikirim', note: 'Data diterima.', timestamp: '2026-11-25T09:00:00' }],
    },
    {
      id: 'demo-2', code: 'GDK-DEMO-0002', customer_name: 'Nasabah Demo',
      category: 'emas', status: 'under_review', created_at: '2026-11-24T10:00:00',
      item_title: 'Cincin Emas Demo', item_details: { 'Berat': '5 gram' },
      admin_note: 'Menunggu pemeriksaan fisik (contoh).',
      documents: [{ id: 'd2', label: 'Foto Emas' }],
      status_history: [
        { status: 'submitted', title: 'Dikirim', note: 'Data diterima.', timestamp: '2026-11-24T10:00:00' },
        { status: 'under_review', title: 'Ditinjau', note: 'Dalam pemeriksaan.', timestamp: '2026-11-24T13:00:00' },
      ],
    },
  ],
};

const state = {
  mode: 'demo',
  base: '',
  token: sessionStorage.getItem('gadaikan_admin_token') || '',
  actor: '',
  page: 1,
  perPage: 10,
  detail: null,
  objectUrls: [],
};

function setConfig() {
  localStorage.setItem('gadaikan_admin_base', $('baseUrl').value.trim());
  localStorage.setItem('gadaikan_admin_mode', $('modeSelect').value);
}

function loadConfig() {
  $('baseUrl').value = localStorage.getItem('gadaikan_admin_base') || '';
  $('modeSelect').value = localStorage.getItem('gadaikan_admin_mode') || 'demo';
  state.base = $('baseUrl').value.replace(/\/+$/, '');
  state.mode = $('modeSelect').value;
}

function toast(message) {
  const el = $('toast');
  el.textContent = message;
  el.hidden = false;
  window.clearTimeout(toast.timer);
  toast.timer = window.setTimeout(() => { el.hidden = true; }, 4000);
}

async function api(path, options = {}) {
  if (!state.base) throw new Error('Isi API base URL terlebih dahulu.');
  const headers = { Accept: 'application/json', ...(options.headers || {}) };
  if (state.token) headers.Authorization = `Bearer ${state.token}`;
  if (options.body && !(options.body instanceof FormData)) {
    headers['Content-Type'] = 'application/json';
    options.body = JSON.stringify(options.body);
  }
  const response = await fetch(`${state.base}${path}`, { ...options, headers });
  let payload = null;
  try { payload = await response.json(); } catch (_) { /* respons kosong */ }
  if (!response.ok) {
    throw new Error(payload?.message || `Request gagal (${response.status}).`);
  }
  return payload;
}

function isAdmin(user) {
  if (!user) return false;
  const role = String(user.role || '').toLowerCase();
  const roles = Array.isArray(user.roles) ? user.roles.map((r) => String(r).toLowerCase()) : [];
  return role === 'admin' || roles.includes('admin');
}

function applyMode() {
  const demo = state.mode === 'demo';
  $('modeLabel').textContent = demo ? 'Mode demo' : 'Laravel API';
  $('loginCard').hidden = demo || Boolean(state.token);
  $('logoutBtn').hidden = demo || !state.token;
  $('actorLabel').textContent = state.actor || '';
  $('dashboardNote').textContent = demo
    ? 'Data contoh. Aksi admin nonaktif sampai backend terhubung.'
    : 'Data dan perubahan status berasal dari Laravel. Transisi divalidasi backend.';
}

async function login() {
  $('loginMessage').textContent = 'Memeriksa...';
  try {
    const result = await api('/login', {
      method: 'POST',
      body: {
        identifier: $('adminIdentifier').value.trim(),
        password: $('adminPassword').value,
      },
    });
    state.token = result.token || result.access_token || '';
    if (!state.token) throw new Error('Server tidak mengembalikan token.');
    sessionStorage.setItem('gadaikan_admin_token', state.token);
    const me = await api('/me');
    const user = me.user || me;
    if (!isAdmin(user)) {
      state.token = '';
      sessionStorage.removeItem('gadaikan_admin_token');
      throw new Error('Akun ini bukan admin. Akses ditolak.');
    }
    state.actor = user.name || user.email || 'Admin';
    applyMode();
    await loadAll();
    toast(`Selamat datang, ${state.actor}.`);
  } catch (error) {
    $('loginMessage').textContent = error.message;
  }
}

function logout() {
  state.token = '';
  state.actor = '';
  sessionStorage.removeItem('gadaikan_admin_token');
  applyMode();
  loadAll();
}

const STAT_KEYS = [
  ['total', 'Total pengajuan'],
  ['submitted', 'Menunggu pemeriksaan'],
  ['under_review', 'Sedang diproses'],
  ['approved', 'Disetujui'],
  ['rejected', 'Ditolak'],
  ['active_transactions', 'Transaksi aktif'],
];

async function loadDashboard() {
  let stats = DEMO.stats;
  if (!isDemo()) {
    try {
      const data = await api('/admin/dashboard');
      stats = data.data || data.stats || data || {};
    } catch (error) {
      $('dashboardNote').textContent = `Gagal memuat ringkasan: ${error.message}`;
      stats = {};
    }
  }
  $('stats').innerHTML = STAT_KEYS.map(([key, label]) =>
    `<div class="stat"><strong>${escapeHtml(stats[key] ?? '—')}</strong><span>${label}</span></div>`
  ).join('');
}

const isDemo = () => state.mode === 'demo';

function filteredDemo() {
  const search = $('searchInput').value.trim().toLowerCase();
  const status = $('statusFilter').value;
  const category = $('categoryFilter').value;
  return DEMO.applications.filter((app) => {
    if (status && app.status !== status) return false;
    if (category && app.category !== category) return false;
    if (search && !`${app.code} ${app.customer_name}`.toLowerCase().includes(search)) return false;
    return true;
  });
}

async function loadApplications() {
  let items = [];
  let total = 0;
  if (isDemo()) {
    const filtered = filteredDemo();
    total = filtered.length;
    items = filtered.slice((state.page - 1) * state.perPage, state.page * state.perPage);
  } else {
    try {
      const query = new URLSearchParams({
        search: $('searchInput').value.trim(),
        status: $('statusFilter').value,
        category: $('categoryFilter').value,
        page: String(state.page),
        per_page: String(state.perPage),
      });
      const data = await api(`/admin/applications?${query}`);
      items = Array.isArray(data) ? data : (data.data || []);
      const meta = data.meta || data.pagination || {};
      total = meta.total ?? items.length;
    } catch (error) {
      $('listMeta').textContent = error.message;
      items = [];
    }
  }
  $('listMeta').textContent = `${total} pengajuan ditemukan`;
  $('pageLabel').textContent = `Halaman ${state.page}`;
  $('applicationsBody').innerHTML = items.length
    ? items.map((app) => `
        <tr>
          <td>${escapeHtml(app.code)}</td>
          <td>${escapeHtml(app.customer_name || app.user?.name || '-')}</td>
          <td>${escapeHtml(app.category)}</td>
          <td><span class="badge ${escapeHtml(app.status)}">${escapeHtml(statusLabel(app.status))}</span></td>
          <td>${escapeHtml(String(app.created_at || '').slice(0, 10))}</td>
          <td><button class="btn small" data-detail="${escapeHtml(app.id)}">Detail</button></td>
        </tr>`).join('')
    : '<tr><td colspan="6" class="muted">Tidak ada pengajuan sesuai filter.</td></tr>';

  $('applicationsBody').querySelectorAll('[data-detail]').forEach((button) => {
    button.addEventListener('click', () => openDetail(button.dataset.detail));
  });
}

function statusLabel(status) {
  const labels = {
    submitted: 'Menunggu', under_review: 'Diproses', revision_required: 'Perlu Perbaikan',
    approved: 'Disetujui', rejected: 'Ditolak', offer_accepted: 'Penawaran Diterima',
    offer_declined: 'Penawaran Ditolak', cancelled: 'Dibatalkan',
  };
  return labels[status] || status || '-';
}

async function loadAll() {
  applyMode();
  await Promise.all([loadDashboard(), loadApplications()]);
}

function clearObjectUrls() {
  state.objectUrls.forEach((url) => URL.revokeObjectURL(url));
  state.objectUrls = [];
}

async function openDetail(id) {
  let app;
  if (isDemo()) {
    app = DEMO.applications.find((item) => item.id === id) || null;
  } else {
    try {
      const data = await api(`/admin/applications/${encodeURIComponent(id)}?include=status_history`);
      app = data.application || data;
    } catch (error) {
      toast(error.message);
      return;
    }
  }
  if (!app) { toast('Detail tidak ditemukan.'); return; }
  state.detail = app;
  $('detailTitle').textContent = `Detail ${app.code || ''}`.trim();
  $('detailBody').innerHTML = renderDetail(app);
  $('detailOverlay').hidden = false;
  bindDetailEvents();
}

function renderDetail(app) {
  const customer = app.user || {};
  const details = app.item_details || {};
  const docs = app.documents || [];
  const history = app.status_history || [];
  const disabled = isDemo() ? 'disabled title="Hubungkan backend untuk memproses"' : '';

  return `
    <div class="detail-grid">
      <div><span>Nomor</span><strong>${escapeHtml(app.code)}</strong></div>
      <div><span>Status</span><strong>${escapeHtml(statusLabel(app.status))}</strong></div>
      <div><span>Kategori</span><strong>${escapeHtml(app.category)}</strong></div>
      <div><span>Tanggal</span><strong>${escapeHtml(String(app.created_at || '').slice(0, 10))}</strong></div>
      <div><span>Nasabah</span><strong>${escapeHtml(customer.name || app.customer_name || '-')}</strong></div>
      <div><span>Kontak</span><strong>${escapeHtml(customer.phone || '-')} ${escapeHtml(customer.email || '')}</strong></div>
    </div>
    <h3>Data Barang</h3>
    <div class="detail-grid">${Object.entries(details).map(([k, v]) =>
      `<div><span>${escapeHtml(k)}</span><strong>${escapeHtml(v)}</strong></div>`).join('') || '<div><span>Tidak ada data</span></div>'}</div>
    <h3>Dokumen (akses terotorisasi)</h3>
    <p class="hint">Berkas privat tidak memiliki URL publik. Preview ditampilkan lewat endpoint dengan Bearer token.</p>
    ${docs.map((doc) => `<div class="doc">
      <span>${escapeHtml(doc.label || 'Berkas')}${doc.is_sensitive ? ' (sensitif)' : ''}</span>
      <button class="btn small" data-doc="${escapeHtml(doc.id)}" ${disabled}>Lihat</button>
    </div>`).join('') || '<p class="muted">Belum ada berkas.</p>'}
    <div id="docViewer"></div>
    <h3>Riwayat Status</h3>
    <ul class="timeline">${history.map((item) => `<li>
      <strong>${escapeHtml(item.title || statusLabel(item.status))}</strong>
      <small>${escapeHtml(item.note || '')} • ${escapeHtml(String(item.timestamp || '').slice(0, 16))}</small>
    </li>`).join('') || '<li><small>Belum ada riwayat</small></li>'}</ul>
    <h3>Catatan Internal</h3>
    <textarea id="internalNote" placeholder="Catatan internal (hanya admin)">${escapeHtml(app.admin_note || '')}</textarea>
    <label style="margin-top:10px"><span>Alasan (wajib untuk revisi/tolak)</span><textarea id="actionReason" placeholder="Alasan yang dipakai untuk nasabah"></textarea></label>
    <div class="actions">
      <button class="btn" data-action="revision" ${disabled}>Minta Revisi</button>
      <button class="btn" data-action="review" ${disabled}>Proses Pemeriksaan</button>
      <button class="btn primary" data-action="approve" ${disabled}>Setujui</button>
      <button class="btn danger" data-action="reject" ${disabled}>Tolak</button>
    </div>
    <p class="hint">Setiap perubahan status dicatat di backend beserta aktor. Panel ini tidak mengubah status secara lokal.</p>
  `;
}

function bindDetailEvents() {
  $('detailBody').querySelectorAll('[data-doc]').forEach((button) => {
    button.addEventListener('click', () => viewDocument(button.dataset.doc));
  });
  $('detailBody').querySelectorAll('[data-action]').forEach((button) => {
    button.addEventListener('click', () => performAction(button.dataset.action));
  });
}

async function viewDocument(docId) {
  try {
    if (!state.base) throw new Error('API base URL belum diisi.');
    const response = await fetch(
      `${state.base}/admin/applications/${encodeURIComponent(state.detail.id)}/documents/${encodeURIComponent(docId)}`,
      { headers: { Authorization: `Bearer ${state.token}` } },
    );
    if (!response.ok) throw new Error('Akses dokumen ditolak.');
    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    state.objectUrls.push(url);
    const viewer = $('docViewer');
    viewer.innerHTML = blob.type.startsWith('image/')
      ? `<img src="${url}" alt="Pratinjau dokumen" style="max-width:100%;border-radius:10px" />`
      : `<iframe src="${url}" title="Pratinjau dokumen" style="width:100%;height:420px;border:1px solid var(--border);border-radius:10px"></iframe>`;
  } catch (error) {
    toast(error.message);
  }
}

const ACTIONS = {
  revision: { path: 'request-revision', method: 'POST', needsReason: true, label: 'Permintaan revisi dikirim.' },
  review: { path: 'review', method: 'POST', needsReason: false, label: 'Pemeriksaan diproses.' },
  approve: { path: 'decision', method: 'POST', needsReason: false, label: 'Penawaran disetujui.' },
  reject: { path: 'decision', method: 'POST', needsReason: true, label: 'Pengajuan ditolak.' },
};

async function performAction(type) {
  const action = ACTIONS[type];
  const reason = $('actionReason').value.trim();
  if (action.needsReason && !reason) {
    toast('Alasan wajib diisi untuk revisi/penolakan.');
    return;
  }
  const body = {
    action: type,
    internal_note: $('internalNote').value.trim(),
  };
  if (type === 'revision') body.reason = reason;
  if (type === 'approve') body.decision = 'approved';
  if (type === 'reject') { body.decision = 'rejected'; body.reason = reason; }

  try {
    await api(`/admin/applications/${encodeURIComponent(state.detail.id)}/${action.path}`, {
      method: action.method,
      body,
    });
    toast(action.label);
    await loadAll();
    await openDetail(state.detail.id);
  } catch (error) {
    toast(error.message);
  }
}

function bindEvents() {
  $('baseUrl').addEventListener('change', () => { setConfig(); state.base = $('baseUrl').value.replace(/\/+$/, ''); loadAll(); });
  $('modeSelect').addEventListener('change', () => { setConfig(); state.mode = $('modeSelect').value; state.page = 1; loadAll(); });
  $('loginBtn').addEventListener('click', login);
  $('logoutBtn').addEventListener('click', logout);
  $('refreshBtn').addEventListener('click', loadAll);
  $('searchInput').addEventListener('input', () => { state.page = 1; loadApplications(); });
  $('statusFilter').addEventListener('change', () => { state.page = 1; loadApplications(); });
  $('categoryFilter').addEventListener('change', () => { state.page = 1; loadApplications(); });
  $('prevPage').addEventListener('click', () => { if (state.page > 1) { state.page -= 1; loadApplications(); } });
  $('nextPage').addEventListener('click', () => { state.page += 1; loadApplications(); });
  $('closeDetail').addEventListener('click', () => {
    $('detailOverlay').hidden = true;
    state.detail = null;
    clearObjectUrls();
  });
}

loadConfig();
bindEvents();
loadAll();
