<script>
  import { onMount, tick } from 'svelte';
  import KpiCard from '$lib/components/shared/KpiCard.svelte';
  import Chart from 'chart.js/auto';
  import { api } from '$lib/api.js';

  let data = $state(null);
  let revenueCanvas;
  let loading = $state(true);

  onMount(async () => {
    try {
      data = await api.getOverview();
      console.log('Overview data:', data);
    } catch(e) { 
      console.error('Failed to load overview:', e);
      data = null; 
    } finally { 
      loading = false; 
    }

    await tick(); // Wait for DOM to render the canvas

    if (data && revenueCanvas) {
      console.log('Initializing Chart on', revenueCanvas);
      new Chart(revenueCanvas, {
        type: 'line',
        data: { 
          labels: data.weeklyLabels || ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'], 
          datasets: [{ 
            label: 'Revenue (€)', 
            data: $state.snapshot((data.weeklyRevenue && data.weeklyRevenue.length > 0) ? data.weeklyRevenue : [0,0,0,0,0,0,0]), 
            borderColor: '#1E5F74', 
            backgroundColor: 'rgba(30,95,116,0.1)', 
            fill: true, 
            tension: 0.4, 
            pointBackgroundColor: '#1E5F74' 
          }] 
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, grid: { color: '#E5E7EB' } }, x: { grid: { display: false } } } }
      });
    } else {
      console.warn('Canvas not found or data missing:', { data, revenueCanvas });
    }
  });
</script>

<svelte:head><title>Overview — Owner — Cafe De Paris</title></svelte:head>

<div class="overview-page">
  {#if loading}
    <div class="skeleton-row">{#each [1,2,3,4] as _}<div class="skeleton-card"></div>{/each}</div>
  {:else if data}
    <div class="kpi-row">
      <KpiCard label="TODAY'S REVENUE" value="€{data.todayRevenue?.toLocaleString()}" trend="{data.revenueChange}%" trendUp={data.revenueChange > 0} color="var(--primary-teal)" />
      <KpiCard label="ORDERS TODAY" value={String(data.ordersToday)} trend="{data.ordersChange}%" trendUp={data.ordersChange > 0} />
      <KpiCard label="AVG ORDER VALUE" value="€{data.avgOrderValue}" trend="{Math.abs(data.avgOrderChange)}%" trendUp={data.avgOrderChange > 0} />
      <KpiCard label="CUSTOMERS SERVED" value={String(data.customersServed)} trend="{data.customersChange}%" trendUp={data.customersChange > 0} />
    </div>

    <div class="two-col">
      <div class="card chart-card"><div class="card-header"><h3>Weekly Revenue</h3></div><div class="chart-box"><canvas bind:this={revenueCanvas}></canvas></div></div>
      <div class="card">
        <div class="card-header"><h3>Top Selling Items</h3></div>
        <div class="top-items">
          {#each data.topItems || [] as item}
            <div class="top-item-row">
              <span class="rank">#{item.rank}</span>
              <div class="top-item-info"><p class="top-item-name">{item.name}</p><p class="top-item-sub">{item.unitsSold} sold · €{item.revenue}</p></div>
              <span class="top-item-growth" class:positive={item.growth > 0}>↑{item.growth}%</span>
            </div>
          {/each}
        </div>
      </div>
    </div>
  {:else}
    <div class="error-state">Failed to load overview data</div>
  {/if}
</div>

<style>
  .overview-page { display: flex; flex-direction: column; gap: 24px; }
  .skeleton-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .skeleton-card { height: 100px; background: var(--border); border-radius: var(--card-radius); animation: pulse 1.5s infinite; }
  @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.5; } }
  .kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .two-col { display: grid; grid-template-columns: 1.5fr 1fr; gap: 20px; }
  .chart-card { padding: 20px; }
  .card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
  .card-header h3 { font-family: var(--font-display); font-size: 16px; }
  .chart-box { height: 260px; position: relative; }
  .top-items { padding: 0 20px 16px; }
  .top-item-row { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--border); }
  .top-item-row:last-child { border-bottom: none; }
  .rank { width: 28px; height: 28px; background: rgba(30,95,116,0.08); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600; color: var(--primary-teal); }
  .top-item-info { flex: 1; }
  .top-item-name { font-size: 14px; font-weight: 500; }
  .top-item-sub { font-size: 12px; color: var(--text-secondary); margin-top: 2px; }
  .top-item-growth { font-size: 12px; font-weight: 500; color: var(--success-green); }
  .error-state { text-align: center; padding: 60px; color: var(--text-secondary); }
</style>
