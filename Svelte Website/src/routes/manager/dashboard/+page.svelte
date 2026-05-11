<script>
  import { onMount, tick } from 'svelte';
  import KpiCard from '$lib/components/shared/KpiCard.svelte';
  import StatusBadge from '$lib/components/shared/StatusBadge.svelte';
  import Chart from 'chart.js/auto';
  import { api } from '$lib/api.js';

  let inventory = $state([]);
  let payables = $state([]);
  let alerts = $state([]);
  let loading = $state(true);
  let error = $state('');
  let inventoryCanvas = $state();

  onMount(async () => {
    try {
      const [inv, pay, al] = await Promise.all([api.getInventory(), api.getPayables(), api.getAlerts()]);
      inventory = inv || []; payables = pay || []; alerts = al || [];
    } catch (e) { error = e.message; } finally { loading = false; }

    await tick();

    if (inventoryCanvas && inventory.length > 0) {
      new Chart(inventoryCanvas, {
        type: 'bar',
        data: {
          labels: inventory.slice(0, 8).map(i => i.name),
          datasets: [{
            label: 'Current Stock',
            data: $state.snapshot(inventory.slice(0, 8).map(i => i.quantity)),
            backgroundColor: inventory.slice(0, 8).map(i => i.status === 'critical' ? '#EF4444' : i.status === 'low' ? '#F59E0B' : '#1E5F74'),
            borderRadius: 4
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true }, x: { grid: { display: false } } }
        }
      });
    }
  });

  const criticalItems = $derived(inventory.filter(i => i.status === 'critical'));
  const lowItems = $derived(inventory.filter(i => i.status === 'low'));
  const pendingPay = $derived(payables.filter(b => b.status === 'pending'));
  const overduePay = $derived(payables.filter(b => b.status === 'overdue'));
  const totalOutstanding = $derived([...pendingPay, ...overduePay].reduce((s, b) => s + (b.amount || 0), 0));
  const unreadAlerts = $derived(alerts.filter(a => !a.read));
</script>

<svelte:head><title>Dashboard — Manager — Cafe De Paris</title></svelte:head>

<div class="dashboard">
  {#if loading}
    <div class="skeleton-row">{#each [1,2,3,4] as _}<div class="skeleton-card"></div>{/each}</div>
  {:else if error}
    <div class="error-banner">{error} <button class="btn btn-outline" onclick={() => location.reload()}>Retry</button></div>
  {:else}
    {#if criticalItems.length > 0}
      <div class="alert-banner">
        <div class="alert-banner-content">
          <div class="alert-icon-circle"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>
          <div><strong>Critical Stock Alert</strong><br><span class="alert-sub">{criticalItems.length} items require immediate attention</span></div>
        </div>
        <a href="/manager/inventory?filter=critical" class="btn alert-action-btn">View Items</a>
      </div>
    {/if}

    <div class="kpi-row">
      <KpiCard label="CRITICAL STOCK" value={String(criticalItems.length)} color="var(--error-red)" subtitle="items need reorder" />
      <KpiCard label="LOW STOCK" value={String(lowItems.length)} color="var(--warning-orange)" subtitle="items running low" />
      <KpiCard label="PENDING PAYABLES" value="€{totalOutstanding.toFixed(2)}" color="var(--primary-teal)" subtitle="{pendingPay.length + overduePay.length} invoices" />
      <KpiCard label="UNREAD ALERTS" value={String(unreadAlerts.length)} subtitle="need attention" />
    </div>

    <div class="card chart-section-card">
      <div class="card-header"><h3>Inventory Levels</h3></div>
      <div class="chart-box"><canvas bind:this={inventoryCanvas}></canvas></div>
    </div>

    <div class="two-col">
      <div class="card table-card">
        <div class="card-header"><h3>Low Stock Items</h3><a href="/manager/inventory">View All →</a></div>
        <table>
          <thead><tr><th>ITEM</th><th>CATEGORY</th><th>QTY</th><th>STATUS</th><th>VENDOR</th></tr></thead>
          <tbody>
            {#each [...criticalItems, ...lowItems].slice(0, 6) as item}
              <tr>
                <td class="fw500">{item.name}</td>
                <td class="muted">{item.category || '—'}</td>
                <td style="color: {item.status === 'critical' ? 'var(--error-red)' : 'var(--warning-orange)'}; font-weight:600">{item.quantity} {item.unit}</td>
                <td><StatusBadge status={item.status} /></td>
                <td class="muted">{item.vendor || '—'}</td>
              </tr>
            {:else}
              <tr><td colspan="5" class="empty-cell">All items are well stocked ✓</td></tr>
            {/each}
          </tbody>
        </table>
      </div>

      <div class="card alerts-card">
        <div class="card-header"><h3>Recent Alerts</h3><a href="/manager/alerts">View All →</a></div>
        <div class="alerts-list">
          {#each alerts.slice(0, 5) as alert}
            <div class="alert-row">
              <span class="alert-dot" style="background: {alert.type === 'critical' ? 'var(--error-red)' : alert.type === 'overdue' ? 'var(--warning-orange)' : 'var(--warning-orange)'}"></span>
              <div class="alert-info">
                <p class="alert-title">{alert.title || alert.message || 'Alert'}</p>
                <p class="alert-desc">{alert.description || ''}</p>
              </div>
            </div>
          {:else}
            <p class="empty-cell">No alerts</p>
          {/each}
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .dashboard { display: flex; flex-direction: column; gap: 24px; }
  .skeleton-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .skeleton-card { height: 100px; background: var(--border); border-radius: var(--card-radius); animation: pulse 1.5s infinite; }
  @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.5; } }
  .error-banner { background: var(--critical-bg); color: var(--critical-text); padding: 14px 20px; border-radius: var(--card-radius); font-size: 14px; display: flex; align-items: center; gap: 12px; }
  .alert-banner {
    display: flex; align-items: center; justify-content: space-between;
    background: #FEF2F2; border: 1px solid #fca5a5; border-radius: var(--card-radius); padding: 16px 20px;
  }
  .alert-banner-content { display: flex; align-items: center; gap: 12px; color: var(--critical-text); font-size: 14px; }
  .alert-icon-circle { width: 36px; height: 36px; background: #FEE2E2; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--error-red); flex-shrink: 0; }
  .alert-sub { font-size: 13px; color: var(--critical-text); opacity: 0.8; }
  .alert-action-btn { background: var(--error-red); color: #fff; font-size: 13px; padding: 8px 16px; border-radius: var(--button-radius); text-decoration: none; }
  .kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .chart-section-card { padding-bottom: 20px; }
  .chart-box { height: 240px; padding: 0 20px; position: relative; }
  .two-col { display: grid; grid-template-columns: 1fr 360px; gap: 20px; }
  .card-header { display: flex; align-items: center; justify-content: space-between; padding: 18px 20px 12px; }
  .card-header h3 { font-family: var(--font-display); font-size: 16px; font-weight: 600; }
  .card-header a { font-size: 13px; color: var(--primary-teal); text-decoration: none; }
  .fw500 { font-weight: 500; }
  .muted { color: var(--text-secondary); }
  .empty-cell { text-align: center; padding: 24px; color: var(--text-secondary); font-size: 13px; }
  .alerts-list { padding: 0 20px 16px; display: flex; flex-direction: column; gap: 2px; }
  .alert-row { display: flex; align-items: flex-start; gap: 12px; padding: 12px 0; border-bottom: 1px solid var(--border); }
  .alert-row:last-child { border-bottom: none; }
  .alert-dot { width: 8px; height: 8px; border-radius: 50%; margin-top: 6px; flex-shrink: 0; }
  .alert-info { flex: 1; }
  .alert-title { font-size: 14px; font-weight: 500; color: var(--text-primary); }
  .alert-desc { font-size: 12px; color: var(--text-secondary); margin-top: 2px; }
</style>
