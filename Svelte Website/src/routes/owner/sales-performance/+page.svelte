<script>
  import { onMount, tick } from 'svelte';
  import KpiCard from '$lib/components/shared/KpiCard.svelte';
  import Chart from 'chart.js/auto';
  import { api } from '$lib/api.js';

  let data = $state(null);
  let donutCanvas = $state();
  let peakCanvas = $state();
  let loading = $state(true);

  onMount(async () => {
    try { 
      data = await api.getSales(); 
      console.log('Sales data:', data);
    } catch(e) {
      console.error('Failed to load sales:', e);
    } finally { 
      loading = false; 
    }

    await tick();

    if (!data) return;

    if (donutCanvas && data.categories && data.categories.length > 0) {
      new Chart(donutCanvas, {
        type: 'doughnut',
        data: { labels: data.categories.map(c => c.name), datasets: [{ data: $state.snapshot(data.categories.map(c => c.percentage)), backgroundColor: data.categories.map(c => c.color), borderWidth: 0 }] },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } }, cutout: '70%' }
      });
    }
    if (peakCanvas && data.peakHours && data.peakHours.length > 0) {
      new Chart(peakCanvas, {
        type: 'bar',
        data: { labels: data.peakHours.map(h => h.hour), datasets: [{ label: 'Orders', data: $state.snapshot(data.peakHours.map(h => h.orders)), backgroundColor: '#1E5F74', borderRadius: 4 }] },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true }, x: { grid: { display: false } } } }
      });
    }
  });
</script>

<svelte:head><title>Sales Performance — Owner — Cafe De Paris</title></svelte:head>

<div class="sales-page">
  {#if loading}<div class="loading-state">Loading...</div>
  {:else if data}
    <div class="kpi-row">
      <KpiCard label="TOTAL SALES" value={String(data.totalSales)} trend="{data.salesChange}%" trendUp={true} />
      <KpiCard label="TOP CATEGORY" value={data.topCategory} />
      <KpiCard label="PEAK HOUR" value={data.peakHour} />
      <KpiCard label="AVG ITEMS/ORDER" value={String(data.avgItemsPerOrder)} trend="{data.avgItemsChange}%" trendUp={true} />
    </div>
    <div class="two-col">
      <div class="card chart-card"><h3>Sales by Category</h3><div class="chart-box"><canvas bind:this={donutCanvas}></canvas></div></div>
      <div class="card chart-card"><h3>Peak Hours</h3><div class="chart-box"><canvas bind:this={peakCanvas}></canvas></div></div>
    </div>
    <div class="card">
      <h3 class="list-title">Top Selling Items</h3>
      <table>
        <thead><tr><th>#</th><th>ITEM</th><th>UNITS SOLD</th><th>REVENUE</th><th>GROWTH</th></tr></thead>
        <tbody>
          {#each data.topItems || [] as item}
            <tr>
              <td class="rank">#{item.rank}</td>
              <td class="fw500">{item.name}</td>
              <td>{item.unitsSold}</td>
              <td>€{item.revenue}</td>
              <td class="growth">↑{item.growth}%</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<style>
  .sales-page { display: flex; flex-direction: column; gap: 24px; }
  .kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
  .chart-card { padding: 24px; }
  .chart-card h3 { font-family: var(--font-display); font-size: 16px; margin-bottom: 16px; }
  .chart-box { height: 280px; position: relative; }
  .list-title { font-family: var(--font-display); font-size: 16px; padding: 18px 20px 12px; }
  .rank { color: var(--primary-teal); font-weight: 600; }
  .fw500 { font-weight: 500; }
  .growth { color: var(--success-green); font-weight: 500; }
  .loading-state { text-align: center; padding: 60px; color: var(--text-secondary); }
</style>
