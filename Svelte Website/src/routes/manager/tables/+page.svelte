<script>
  import { onMount, onDestroy } from 'svelte';
  import StatusBadge from '$lib/components/shared/StatusBadge.svelte';
  import { api } from '$lib/api.js';

  let tables = $state([]);
  let waiters = $state([]);
  let loading = $state(true);
  let showAddTable = $state(false);
  let showAddWaiter = $state(false);
  let newTable = $state({ name: '', seats: 4 });
  let newWaiter = $state({ name: '', phone: '' });
  let pollInterval;

  onMount(async () => {
    try {
      const [t, w] = await Promise.all([api.getTables(), api.getWaiters()]);
      tables = t || []; waiters = w || [];
    } catch(e) {} finally { loading = false; }
    pollInterval = setInterval(async () => {
      try { tables = await api.getTables() || []; } catch(e) {}
    }, 5000);
  });

  onDestroy(() => { clearInterval(pollInterval); });

  async function addTable() {
    try { 
      // Ensure number is parsed if possible, or leave it to backend
      await api.createTable(newTable); 
      tables = await api.getTables() || []; 
      showAddTable = false; 
      newTable = { name: '', seats: 4 }; 
    } catch(e) { alert('Failed to add table: ' + e.message); }
  }
  async function deleteTable(id) {
    try { await api.deleteTable(id); tables = tables.filter(t => t.id !== id); } catch(e) { alert('Failed to delete table: ' + e.message); }
  }
  async function addWaiter() {
    try { 
      await api.addWaiter({ ...newWaiter, role: 'waiter' }); 
      waiters = await api.getWaiters() || []; 
      showAddWaiter = false; 
      newWaiter = { name: '', phone: '' }; 
    } catch(e) { alert('Failed to add waiter: ' + e.message); }
  }
  async function updateStatus(id, status) {
    try { await api.updateTableStatus(id, status); tables = await api.getTables() || []; } catch(e) { alert('Failed to update status: ' + e.message); }
  }
</script>

<svelte:head><title>Tables & Staff — Manager — Cafe De Paris</title></svelte:head>

<div class="tables-page">
  <div class="section">
    <div class="section-header">
      <div><h2>Tables</h2><p class="page-subtitle">Manage dining tables</p></div>
      <button class="btn btn-primary" onclick={() => showAddTable = true}>+ Add Table</button>
    </div>
    {#if loading}
      <div class="loading-state">Loading...</div>
    {:else}
      <div class="table-grid">
        {#each tables as t}
          <div class="card table-card">
            <div class="table-top"><h3>{t.name}</h3><button class="del-btn" onclick={() => deleteTable(t.id)}>×</button></div>
            <p class="muted">{t.seats} seats</p>
            <StatusBadge status={t.status} />
            
            <div class="table-actions">
              {#if t.status === 'eating'}
                <button class="btn btn-outline small-btn" onclick={() => updateStatus(t.id, 'billed')}>Billed</button>
              {:else if t.status === 'billed'}
                <button class="btn btn-primary small-btn" onclick={() => updateStatus(t.id, 'available')}>Make Available</button>
              {:else if t.status !== 'available'}
                <button class="btn btn-outline small-btn" onclick={() => updateStatus(t.id, 'available')}>Reset to Available</button>
              {/if}
            </div>
          </div>
        {:else}
          <p class="empty-cell">No tables</p>
        {/each}
      </div>
    {/if}
  </div>

  <div class="section">
    <div class="section-header">
      <div><h2>Waiters</h2><p class="page-subtitle">Manage waiter accounts</p></div>
      <button class="btn btn-primary" onclick={() => showAddWaiter = true}>+ Add Waiter</button>
    </div>
    <div class="card">
      <table>
        <thead><tr><th>NAME</th><th>PHONE</th><th>ROLE</th></tr></thead>
        <tbody>
          {#each waiters as w}
            <tr><td class="fw500">{w.name}</td><td class="muted">{w.phone}</td><td><StatusBadge status="ok" label="Waiter" /></td></tr>
          {:else}
            <tr><td colspan="3" class="empty-cell">No waiters</td></tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
</div>

{#if showAddTable}
  <div class="modal-overlay" onclick={() => showAddTable = false}>
    <div class="modal-card" onclick={(e) => e.stopPropagation()}>
      <h3>Add Table</h3>
      <label class="field-label">Table Name</label><input type="text" bind:value={newTable.name} placeholder="e.g. Table 9" />
      <label class="field-label">Seats</label><input type="number" bind:value={newTable.seats} min="1" max="20" />
      <div class="modal-actions"><button class="btn btn-outline" onclick={() => showAddTable = false}>Cancel</button><button class="btn btn-primary" onclick={addTable}>Add Table</button></div>
    </div>
  </div>
{/if}

{#if showAddWaiter}
  <div class="modal-overlay" onclick={() => showAddWaiter = false}>
    <div class="modal-card" onclick={(e) => e.stopPropagation()}>
      <h3>Add Waiter</h3>
      <label class="field-label">Name</label><input type="text" bind:value={newWaiter.name} placeholder="Full name" />
      <label class="field-label">Phone Number</label><input type="tel" bind:value={newWaiter.phone} placeholder="+33 6 12 34 56 78" />
      <div class="modal-actions"><button class="btn btn-outline" onclick={() => showAddWaiter = false}>Cancel</button><button class="btn btn-primary" onclick={addWaiter}>Add Waiter</button></div>
    </div>
  </div>
{/if}

<style>
  .tables-page { display: flex; flex-direction: column; gap: 32px; }
  .section-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 16px; }
  .section-header h2 { font-family: var(--font-display); font-size: 22px; }
  .page-subtitle { font-size: 13px; color: var(--text-secondary); }
  .table-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
  .table-card { padding: 16px; display: flex; flex-direction: column; gap: 6px; }
  .table-top { display: flex; justify-content: space-between; align-items: center; }
  .table-card h3 { font-size: 15px; font-weight: 600; }
  .del-btn { width: 24px; height: 24px; border-radius: 50%; background: var(--critical-bg); color: var(--error-red); border: none; font-size: 16px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
  .fw500 { font-weight: 500; }
  .muted { color: var(--text-secondary); font-size: 13px; }
  .loading-state, .empty-cell { text-align: center; padding: 40px; color: var(--text-secondary); }
  .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; }
  .modal-card { background: var(--card-surface); border-radius: 16px; padding: 32px; width: 400px; }
  .modal-card h3 { font-family: var(--font-display); font-size: 18px; margin-bottom: 16px; }
  .field-label { display: block; font-size: 13px; font-weight: 500; margin: 12px 0 4px; }
  .modal-card input { width: 100%; }
  .modal-actions { display: flex; gap: 12px; justify-content: flex-end; margin-top: 24px; }
  .table-actions { margin-top: 10px; display: flex; gap: 8px; border-top: 1px solid var(--border); pt: 10px; }
  .small-btn { padding: 4px 8px; font-size: 11px; flex: 1; }
</style>
