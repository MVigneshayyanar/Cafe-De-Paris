<script>
  import { onMount } from 'svelte';
  import StatusBadge from '$lib/components/shared/StatusBadge.svelte';
  import { api } from '$lib/api.js';

  let payables = $state([]);
  let loading = $state(true);

  onMount(async () => { try { payables = await api.getPayables() || []; } catch(e) {} finally { loading = false; } });

  const pending = $derived(payables.filter(p => p.status === 'pending'));
  const overdue = $derived(payables.filter(p => p.status === 'overdue'));
  const totalOutstanding = $derived(payables.filter(p => p.status !== 'paid').reduce((s, p) => s + p.amount, 0));
  const totalPending = $derived(pending.reduce((s, p) => s + p.amount, 0));
  const totalOverdue = $derived(overdue.reduce((s, p) => s + p.amount, 0));

  async function markPaid(id) {
    try { await api.markPaid(id); payables = payables.map(p => p.id === id ? {...p, status: 'paid'} : p); } catch(e) {}
  }
</script>

<svelte:head><title>Payables — Cafe De Paris</title></svelte:head>

<div class="payables-page">
  <h2>Payables</h2>
  <p class="page-subtitle">Manage vendor invoices and payments</p>

  <div class="summary-row">
    <div class="card summary-card"><p class="summary-label">Total Outstanding</p><p class="summary-value">€{totalOutstanding.toFixed(2)}</p></div>
    <div class="card summary-card"><p class="summary-label">Pending</p><p class="summary-value" style="color:var(--warning-orange)">€{totalPending.toFixed(2)}</p></div>
    <div class="card summary-card overdue-card"><p class="summary-label">Overdue</p><p class="summary-value">€{totalOverdue.toFixed(2)}</p></div>
  </div>

  {#if loading}
    <div class="loading-state">Loading...</div>
  {:else}
    <div class="card">
      <table>
        <thead><tr><th>VENDOR</th><th>BILL REFERENCE</th><th>AMOUNT</th><th>DUE DATE</th><th>STATUS</th><th>ACTIONS</th></tr></thead>
        <tbody>
          {#each [...payables].sort((a,b) => a.status === 'overdue' ? -1 : 1) as p}
            <tr>
              <td class="fw500">{p.vendor}</td>
              <td class="muted">{p.billReference}</td>
              <td class="fw500">€{p.amount.toFixed(2)}</td>
              <td style="color: {p.status === 'overdue' ? 'var(--error-red)' : 'inherit'}; font-weight: {p.status === 'overdue' ? '600' : '400'}">{p.dueDate}</td>
              <td><StatusBadge status={p.status} /></td>
              <td>
                {#if p.status !== 'paid'}
                  <button class="btn btn-primary btn-sm" onclick={() => markPaid(p.id)}>Mark Paid</button>
                {:else}
                  <span class="muted">—</span>
                {/if}
              </td>
            </tr>
          {:else}
            <tr><td colspan="6" class="empty-cell">No payables</td></tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<style>
  .payables-page { display: flex; flex-direction: column; gap: 20px; }
  .payables-page h2 { font-family: var(--font-display); font-size: 22px; }
  .page-subtitle { font-size: 13px; color: var(--text-secondary); }
  .summary-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
  .summary-card { padding: 20px; }
  .summary-label { font-size: 13px; color: var(--text-secondary); margin-bottom: 4px; }
  .summary-value { font-family: var(--font-display); font-size: 24px; font-weight: 600; }
  .overdue-card { background: #FEF2F2; border-color: #fca5a5; }
  .overdue-card .summary-value { color: var(--error-red); }
  .fw500 { font-weight: 500; }
  .muted { color: var(--text-secondary); }
  .btn-sm { padding: 6px 14px; font-size: 12px; }
  .loading-state, .empty-cell { text-align: center; padding: 40px; color: var(--text-secondary); }
</style>
