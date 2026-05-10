<script>
  import { onMount } from 'svelte';
  import KpiCard from '$lib/components/shared/KpiCard.svelte';
  import { api } from '$lib/api.js';

  let reports = $state([]);
  let loading = $state(true);

  onMount(async () => { try { reports = await api.getReports() || []; } catch(e) {} finally { loading = false; } });

  function downloadReport(id) { api.downloadReport(id); }
</script>

<svelte:head><title>Reports — Owner — Cafe De Paris</title></svelte:head>

<div class="reports-page">
  <h2>Reports</h2>
  <p class="page-subtitle">Download and review business reports</p>

  <div class="kpi-row">
    <KpiCard label="TOTAL REPORTS" value={String(reports.length)} />
    <KpiCard label="DAILY REPORTS" value={String(reports.filter(r => r.frequency === 'Daily').length)} />
    <KpiCard label="WEEKLY REPORTS" value={String(reports.filter(r => r.frequency === 'Weekly').length)} />
    <KpiCard label="MONTHLY REPORTS" value={String(reports.filter(r => r.frequency === 'Monthly').length)} />
  </div>

  {#if loading}<div class="loading-state">Loading...</div>
  {:else}
    <div class="reports-list">
      {#each reports as report}
        <div class="card report-card">
          <div class="report-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
          <div class="report-info">
            <h3>{report.name}</h3>
            <p class="report-desc">{report.description}</p>
            <div class="report-meta">
              <span class="freq-badge">{report.frequency}</span>
              <span class="meta-text">Generated {new Date(report.generatedAt).toLocaleDateString()}</span>
              <span class="meta-text">{report.size}</span>
            </div>
          </div>
          <button class="btn btn-outline dl-btn" onclick={() => downloadReport(report.id)}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            Download
          </button>
        </div>
      {:else}
        <div class="empty">No reports available</div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .reports-page { display: flex; flex-direction: column; gap: 24px; }
  .reports-page h2 { font-family: var(--font-display); font-size: 22px; }
  .page-subtitle { font-size: 13px; color: var(--text-secondary); }
  .kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
  .reports-list { display: flex; flex-direction: column; gap: 12px; }
  .report-card { display: flex; align-items: center; gap: 16px; padding: 20px; }
  .report-icon { width: 44px; height: 44px; background: rgba(30,95,116,0.08); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: var(--primary-teal); flex-shrink: 0; }
  .report-info { flex: 1; }
  .report-info h3 { font-size: 15px; font-weight: 600; }
  .report-desc { font-size: 13px; color: var(--text-secondary); margin-top: 2px; }
  .report-meta { display: flex; align-items: center; gap: 12px; margin-top: 8px; }
  .freq-badge { background: rgba(30,95,116,0.08); color: var(--primary-teal); padding: 2px 10px; border-radius: 999px; font-size: 11px; font-weight: 500; }
  .meta-text { font-size: 12px; color: var(--text-secondary); }
  .dl-btn { display: flex; align-items: center; gap: 6px; padding: 8px 16px; font-size: 13px; }
  .loading-state, .empty { text-align: center; padding: 40px; color: var(--text-secondary); }
</style>
