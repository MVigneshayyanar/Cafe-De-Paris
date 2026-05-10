<script>
  import { onMount } from 'svelte';
  import KpiCard from '$lib/components/shared/KpiCard.svelte';
  import { api } from '$lib/api.js';

  let data = $state(null);
  let loading = $state(true);

  onMount(async () => { try { data = await api.getInventoryInsights(); } catch(e) {} finally { loading = false; } });

  function severityColor(s) { return s === 'critical' ? 'var(--error-red)' : 'var(--warning-orange)'; }
</script>

<svelte:head><title>Inventory Insights — Owner — Cafe De Paris</title></svelte:head>

<div class="inv-page">
  {#if loading}<div class="loading-state">Loading...</div>
  {:else if data}
    <div class="kpi-row">
      <KpiCard label="LOW STOCK ITEMS" value={String(data.lowStockItems)} color="var(--warning-orange)" />
      <KpiCard label="CRITICAL ITEMS" value={String(data.criticalItems)} color="var(--error-red)" />
      <KpiCard label="STOCKOUTS THIS WEEK" value={String(data.stockoutsThisWeek)} trend="{Math.abs(data.stockoutsChange)}%" trendUp={data.stockoutsChange < 0} />
      <KpiCard label="INVENTORY HEALTH" value={data.inventoryHealth} color="var(--success-green)" />
    </div>

    <div class="card">
      <h3 class="card-title">Items Needing Attention</h3>
      <div class="items-list">
        {#each data.items || [] as item}
          <div class="item-row" style="border-left: 3px solid {severityColor(item.severity)}">
            <div class="item-info">
              <p class="item-name">{item.name}</p>
              <p class="item-sub">Threshold: {item.threshold}</p>
            </div>
            <div class="item-right">
              <p class="item-qty" style="color: {severityColor(item.severity)}">{item.current} {item.unit}</p>
              <span class="severity-badge" class:critical={item.severity === 'critical'} class:low={item.severity === 'low'}>{item.severity}</span>
            </div>
          </div>
        {:else}
          <p class="empty">All inventory levels are healthy</p>
        {/each}
      </div>
    </div>
  {/if}
</div>

<style>
  .inv-page { display: flex; flex-direction: column; gap: 24px; }
  .kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .card-title { font-family: var(--font-display); font-size: 16px; padding: 18px 20px 12px; }
  .items-list { padding: 0 20px 16px; }
  .item-row { display: flex; align-items: center; justify-content: space-between; padding: 14px 16px; margin: 6px 0; background: var(--background); border-radius: 8px; }
  .item-name { font-size: 14px; font-weight: 600; }
  .item-sub { font-size: 12px; color: var(--text-secondary); margin-top: 2px; }
  .item-right { text-align: right; }
  .item-qty { font-size: 18px; font-weight: 700; }
  .severity-badge { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 11px; font-weight: 500; margin-top: 4px; text-transform: capitalize; }
  .severity-badge.critical { background: var(--critical-bg); color: var(--critical-text); }
  .severity-badge.low { background: #FEF3C7; color: #92400E; }
  .loading-state, .empty { text-align: center; padding: 40px; color: var(--text-secondary); }
</style>
