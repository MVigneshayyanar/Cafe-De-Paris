<script>
  let fullName = $state('Manager');
  let email = $state('manager@cafedeparis.com');
  let criticalAlerts = $state(true);
  let lowStockAlerts = $state(true);
  let overdueAlerts = $state(true);
</script>

<svelte:head><title>Settings — Cafe De Paris</title></svelte:head>

<div class="settings-page">
  <h2>Settings</h2>
  <p class="page-subtitle">Manage your account and preferences</p>

  <div class="card settings-card">
    <h3>Profile</h3>
    <label class="field-label">Full Name</label>
    <input type="text" bind:value={fullName} />
    <label class="field-label">Email</label>
    <input type="email" bind:value={email} readonly style="opacity:0.6" />
    <button class="btn btn-primary save-btn">Save Changes</button>
  </div>

  <div class="card settings-card">
    <h3>Notification Preferences</h3>
    <div class="toggle-row"><span>Critical stock alerts (email)</span><label class="toggle"><input type="checkbox" bind:checked={criticalAlerts} /><span class="slider"></span></label></div>
    <div class="toggle-row"><span>Low stock alerts (email)</span><label class="toggle"><input type="checkbox" bind:checked={lowStockAlerts} /><span class="slider"></span></label></div>
    <div class="toggle-row"><span>Overdue payment alerts (email)</span><label class="toggle"><input type="checkbox" bind:checked={overdueAlerts} /><span class="slider"></span></label></div>
    <button class="btn btn-primary save-btn">Save Preferences</button>
  </div>
</div>

<style>
  .settings-page { display: flex; flex-direction: column; gap: 20px; max-width: 600px; }
  .settings-page h2 { font-family: var(--font-display); font-size: 22px; }
  .page-subtitle { font-size: 13px; color: var(--text-secondary); }
  .settings-card { padding: 24px; }
  .settings-card h3 { font-family: var(--font-display); font-size: 16px; margin-bottom: 16px; }
  .field-label { display: block; font-size: 13px; font-weight: 500; margin: 12px 0 4px; }
  .settings-card input[type="text"], .settings-card input[type="email"] { width: 100%; }
  .save-btn { margin-top: 20px; width: auto; padding: 10px 24px; }
  .toggle-row { display: flex; align-items: center; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid var(--border); font-size: 14px; }
  .toggle-row:last-of-type { border-bottom: none; }
  .toggle { position: relative; width: 44px; height: 24px; }
  .toggle input { opacity: 0; width: 0; height: 0; }
  .slider { position: absolute; inset: 0; background: var(--border); border-radius: 24px; cursor: pointer; transition: 0.3s; }
  .slider::before { content: ''; position: absolute; width: 18px; height: 18px; left: 3px; bottom: 3px; background: #fff; border-radius: 50%; transition: 0.3s; }
  .toggle input:checked + .slider { background: var(--primary-teal); }
  .toggle input:checked + .slider::before { transform: translateX(20px); }
</style>
