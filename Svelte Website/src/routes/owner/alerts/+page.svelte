<script>
  import { onMount } from 'svelte';
  import { api } from '$lib/api.js';

  let alerts = $state([]);
  let loading = $state(true);
  let activeFilter = $state('all');

  onMount(async () => { try { alerts = await api.getAlerts() || []; } catch(e) {} finally { loading = false; } });

  const filtered = $derived(() => {
    if (activeFilter === 'all') return alerts;
    if (activeFilter === 'unread') return alerts.filter(a => !a.read);
    return alerts.filter(a => a.type === activeFilter);
  });

  async function markRead(id) {
    try { await api.markAlertRead(id); alerts = alerts.map(a => a.id === id ? {...a, read: true} : a); } catch(e) {}
  }

  function dotColor(type) { return type === 'critical' ? 'var(--error-red)' : 'var(--warning-orange)'; }
</script>

<svelte:head><title>Alerts — Owner — Cafe De Paris</title></svelte:head>

<div class="alerts-page">
  <h2>Alerts</h2>
  <div class="filter-row">
    {#each [['all','All'],['critical','Critical'],['low','Low Stock'],['overdue','Overdue'],['unread','Unread']] as [key, label]}
      <button class="filter-pill" class:active={activeFilter === key} onclick={() => activeFilter = key}>{label}</button>
    {/each}
  </div>
  {#if loading}<div class="loading-state">Loading...</div>
  {:else}
    <div class="alerts-list">
      {#each filtered() as alert}
        <div class="alert-card card" class:unread={!alert.read} onclick={() => markRead(alert.id)}>
          <span class="alert-dot" style="background: {dotColor(alert.type)}"></span>
          <div class="alert-content"><p class="alert-title">{alert.title}</p><p class="alert-desc">{alert.description}</p></div>
          <span class="alert-time">{new Date(alert.createdAt).toLocaleDateString()}</span>
        </div>
      {:else}<div class="empty">No alerts</div>{/each}
    </div>
  {/if}
</div>

<style>
  .alerts-page { display: flex; flex-direction: column; gap: 20px; }
  .alerts-page h2 { font-family: var(--font-display); font-size: 22px; }
  .filter-row { display: flex; gap: 8px; }
  .filter-pill { padding: 6px 16px; border-radius: var(--badge-radius); background: var(--card-surface); border: 1px solid var(--border); font-size: 13px; font-weight: 500; color: var(--text-secondary); cursor: pointer; }
  .filter-pill.active { background: var(--primary-teal); color: #fff; border-color: var(--primary-teal); }
  .alerts-list { display: flex; flex-direction: column; gap: 8px; }
  .alert-card { display: flex; align-items: flex-start; gap: 12px; padding: 14px 16px; cursor: pointer; }
  .alert-card.unread { background: #FFFBF0; }
  .alert-dot { width: 8px; height: 8px; border-radius: 50%; margin-top: 6px; flex-shrink: 0; }
  .alert-content { flex: 1; }
  .alert-title { font-size: 14px; font-weight: 500; }
  .alert-desc { font-size: 12px; color: var(--text-secondary); margin-top: 2px; }
  .alert-time { font-size: 11px; color: var(--text-secondary); }
  .loading-state, .empty { text-align: center; padding: 40px; color: var(--text-secondary); }
</style>
