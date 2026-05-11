<script>
  import { onMount, tick } from 'svelte';
  import KpiCard from '$lib/components/shared/KpiCard.svelte';
  import Chart from 'chart.js/auto';
  import { api } from '$lib/api.js';

  let data = $state(null);
  let dailyCanvas, monthlyCanvas;
  let loading = $state(true);

  onMount(async () => {
    try { 
      data = await api.getRevenue(); 
      console.log('Revenue data:', data);
    } catch(e) {
      console.error('Failed to load revenue:', e);
    } finally { 
      loading = false; 
    }
    
    await tick();

    if (!data) return;

    if (dailyCanvas) {
      new Chart(dailyCanvas, {
        type: 'line',
        data: { 
          labels: data.dailyLabels || ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'], 
          datasets: [{ 
            label: 'Revenue', 
            data: $state.snapshot((data.daily && data.daily.length > 0) ? data.daily : [0,0,0,0,0,0,0]), 
            borderColor: '#1E5F74', 
            backgroundColor: 'rgba(30,95,116,0.08)', 
            fill: true, 
            tension: 0.4 
          }] 
        },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true }, x: { grid: { display: false } } } }
      });
    }
    if (monthlyCanvas && data.monthlyComparison) {
      new Chart(monthlyCanvas, {
        type: 'bar',
        data: { 
          labels: ['Week 1','Week 2','Week 3','Week 4'], 
          datasets: [
            { label: 'This Month', data: $state.snapshot(data.monthlyComparison.thisMonth || [0,0,0,0]), backgroundColor: '#1E5F74', borderRadius: 4 },
            { label: 'Last Month', data: $state.snapshot(data.monthlyComparison.lastMonth || [0,0,0,0]), backgroundColor: '#E5E7EB', borderRadius: 4 },
          ] 
        },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } }, scales: { y: { beginAtZero: true }, x: { grid: { display: false } } } }
      });
    }
  });
</script>

<svelte:head><title>Revenue — Owner — Cafe De Paris</title></svelte:head>

<div class="revenue-page">
  {#if loading}
    <div class="loading-state">Loading...</div>
  {:else if data}
    <div class="kpi-row">
      <KpiCard label="TODAY'S REVENUE" value="€{data.todayRevenue?.toLocaleString()}" trend="{data.todayChange}%" trendUp={data.todayChange > 0} />
      <KpiCard label="WEEKLY REVENUE" value="€{data.weeklyRevenue?.toLocaleString()}" trend="{data.weeklyChange}%" trendUp={data.weeklyChange > 0} />
      <KpiCard label="MONTHLY REVENUE" value="€{data.monthlyRevenue?.toLocaleString()}" trend="{data.monthlyChange}%" trendUp={data.monthlyChange > 0} color="var(--primary-teal)" />
      <KpiCard label="YOY GROWTH" value="{data.yoyGrowth}%" trend="{data.yoyChange}%" trendUp={data.yoyChange > 0} />
    </div>
    <div class="card chart-card"><h3>Daily Revenue</h3><div class="chart-box"><canvas bind:this={dailyCanvas}></canvas></div></div>
    <div class="card chart-card"><h3>Monthly Comparison</h3><div class="chart-box"><canvas bind:this={monthlyCanvas}></canvas></div></div>
  {/if}
</div>

<style>
  .revenue-page { display: flex; flex-direction: column; gap: 24px; }
  .kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .chart-card { padding: 24px; }
  .chart-card h3 { font-family: var(--font-display); font-size: 16px; margin-bottom: 16px; }
  .chart-box { height: 300px; position: relative; }
  .loading-state { text-align: center; padding: 60px; color: var(--text-secondary); }
</style>
