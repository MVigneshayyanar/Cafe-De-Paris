<script>
  import { onMount } from 'svelte';
  import { api } from '$lib/api.js';

  let vendors = $state([]);
  let loading = $state(true);
  let search = $state('');
  let showAdd = $state(false);
  let newVendor = $state({ name: '', email: '', phone: '', address: '' });

  onMount(async () => { try { vendors = await api.getVendors() || []; } catch(e) {} finally { loading = false; } });

  const filtered = $derived(search ? vendors.filter(v => v.name.toLowerCase().includes(search.toLowerCase())) : vendors);

  async function addVendor() {
    try { await api.addVendor(newVendor); vendors = await api.getVendors() || []; showAdd = false; newVendor = { name: '', email: '', phone: '', address: '' }; } catch(e) {}
  }
</script>

<svelte:head><title>Vendors — Cafe De Paris</title></svelte:head>

<div class="vendors-page">
  <div class="page-header"><div><h2>Vendors</h2><p class="page-subtitle">Manage your supplier relationships</p></div><button class="btn btn-primary" onclick={() => showAdd = true}>+ Add Vendor</button></div>
  <input type="text" class="search-full" placeholder="Search vendors..." bind:value={search} />

  {#if loading}
    <div class="loading-state">Loading...</div>
  {:else}
    <div class="vendor-grid">
      {#each filtered as v}
        <div class="card vendor-card">
          <div class="vendor-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
          <h3>{v.name}</h3>
          <div class="vendor-row"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg><span>{v.email}</span></div>
          <div class="vendor-row"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.81.36 1.6.68 2.36a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.76.32 1.55.55 2.36.68A2 2 0 0 1 22 16.92z"/></svg><span>{v.phone}</span></div>
          <div class="vendor-row"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg><span>{v.address}</span></div>
          <div class="vendor-divider"></div>
          <p class="vendor-bills">{v.billCount || 0} bills on record</p>
        </div>
      {:else}
        <p class="empty-cell">No vendors found</p>
      {/each}
    </div>
  {/if}
</div>

{#if showAdd}
  <div class="modal-overlay" onclick={() => showAdd = false}>
    <div class="modal-card" onclick={(e) => e.stopPropagation()}>
      <h3>Add Vendor</h3>
      <label class="field-label">Name</label><input type="text" bind:value={newVendor.name} />
      <label class="field-label">Email</label><input type="email" bind:value={newVendor.email} />
      <label class="field-label">Phone</label><input type="tel" bind:value={newVendor.phone} />
      <label class="field-label">Address</label><input type="text" bind:value={newVendor.address} />
      <div class="modal-actions"><button class="btn btn-outline" onclick={() => showAdd = false}>Cancel</button><button class="btn btn-primary" onclick={addVendor}>Save</button></div>
    </div>
  </div>
{/if}

<style>
  .vendors-page { display: flex; flex-direction: column; gap: 20px; }
  .page-header { display: flex; align-items: flex-start; justify-content: space-between; }
  .page-header h2 { font-family: var(--font-display); font-size: 22px; }
  .page-subtitle { font-size: 13px; color: var(--text-secondary); }
  .search-full { width: 100%; }
  .vendor-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
  .vendor-card { padding: 20px; }
  .vendor-icon { width: 40px; height: 40px; background: rgba(30,95,116,0.08); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: var(--primary-teal); margin-bottom: 12px; }
  .vendor-card h3 { font-family: var(--font-body); font-size: 15px; font-weight: 600; margin-bottom: 8px; }
  .vendor-row { display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--text-secondary); margin: 4px 0; }
  .vendor-divider { height: 1px; background: var(--border); margin: 12px 0; }
  .vendor-bills { font-size: 12px; color: var(--text-secondary); }
  .loading-state, .empty-cell { text-align: center; padding: 40px; color: var(--text-secondary); }
  .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; }
  .modal-card { background: var(--card-surface); border-radius: 16px; padding: 32px; width: 420px; }
  .modal-card h3 { font-family: var(--font-display); font-size: 18px; margin-bottom: 16px; }
  .field-label { display: block; font-size: 13px; font-weight: 500; margin: 12px 0 4px; }
  .modal-card input { width: 100%; }
  .modal-actions { display: flex; gap: 12px; justify-content: flex-end; margin-top: 24px; }
</style>
