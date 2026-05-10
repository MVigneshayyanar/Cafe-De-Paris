<script>
  import { onMount } from 'svelte';
  import StatusBadge from '$lib/components/shared/StatusBadge.svelte';
  import { api } from '$lib/api.js';
  import { page } from '$app/state';

  let inventory = $state([]);
  let activeFilter = $state('all');
  let loading = $state(true);
  let error = $state('');
  let search = $state('');
  let showAddModal = $state(false);
  let editingId = $state(null);
  let newItem = $state({ name: '', category: 'Pantry', quantity: 0, unit: 'kg', minStock: 10, vendor: '' });

  onMount(async () => {
    const urlFilter = page.url?.searchParams?.get('filter');
    if (urlFilter) activeFilter = urlFilter;
    await loadData();
  });

  async function loadData() {
    try { inventory = await api.getInventory() || []; } catch (e) { error = e.message; } finally { loading = false; }
  }

  const counts = $derived({
    all: inventory.length,
    critical: inventory.filter(i => i.status === 'critical').length,
    low: inventory.filter(i => i.status === 'low').length,
    ok: inventory.filter(i => i.status === 'ok').length,
  });

  const filtered = $derived(() => {
    let items = activeFilter === 'all' ? inventory : inventory.filter(i => i.status === activeFilter);
    if (search) items = items.filter(i => i.name.toLowerCase().includes(search.toLowerCase()));
    return items;
  });

  function qtyColor(item) {
    if (item.status === 'critical') return 'var(--error-red)';
    if (item.status === 'low') return 'var(--warning-orange)';
    return 'var(--text-primary)';
  }

  function openAddModal() {
    editingId = null;
    newItem = { name: '', category: 'Pantry', quantity: 0, unit: 'kg', minStock: 10, vendor: '' };
    showAddModal = true;
  }

  function editItem(item) {
    editingId = item.id;
    newItem = { ...item };
    showAddModal = true;
  }

  async function deleteItem(id) {
    if (confirm('Are you sure you want to delete this inventory item?')) {
      try {
        await api.deleteInventoryItem(id);
        await loadData();
      } catch (e) { alert('Failed to delete item: ' + e.message); }
    }
  }

  async function saveItem() {
    try {
      if (editingId) {
        await api.updateInventoryItem(editingId, newItem);
      } else {
        await api.addInventoryItem(newItem);
      }
      showAddModal = false;
      await loadData();
    } catch (e) { alert('Failed to save item: ' + e.message); }
  }
</script>

<svelte:head><title>Inventory — Manager — Cafe De Paris</title></svelte:head>

<div class="inventory-page">
  <div class="page-header">
    <div>
      <h2>Inventory</h2>
      <p class="page-subtitle">Manage your stock levels and reorder items</p>
    </div>
    <button class="btn btn-primary" onclick={openAddModal}>+ Add Item</button>
  </div>

  <div class="action-row">
    <div class="filter-row">
      {#each [['all','All'],['critical','Critical'],['low','Low'],['ok','Ok']] as [key, label]}
        <button class="filter-pill" class:active={activeFilter === key} onclick={() => activeFilter = key}>{label} ({counts[key]})</button>
      {/each}
    </div>
    <input type="text" class="search-input" placeholder="Search items..." bind:value={search} />
  </div>

  {#if loading}
    <div class="loading-state">Loading inventory...</div>
  {:else if error}
    <div class="error-state">{error} <button class="btn btn-outline" onclick={loadData}>Retry</button></div>
  {:else}
    <div class="card">
      <table>
        <thead><tr><th>ITEM NAME</th><th>CATEGORY</th><th>QUANTITY</th><th>MIN. STOCK</th><th>STATUS</th><th>LAST UPDATED</th><th>VENDOR</th><th>ACTIONS</th></tr></thead>
        <tbody>
          {#each filtered() as item}
            <tr>
              <td class="fw500">{item.name}</td>
              <td class="muted">{item.category || '—'}</td>
              <td style="color:{qtyColor(item)};font-weight:600">{item.quantity} {item.unit}</td>
              <td class="muted">{item.minStock} {item.unit}</td>
              <td><StatusBadge status={item.status} /></td>
              <td class="muted">{item.lastUpdated || '—'}</td>
              <td class="muted">{item.vendor || '—'}</td>
              <td>
                <div class="action-buttons">
                  <button class="icon-btn edit-btn" onclick={() => editItem(item)}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                  </button>
                  <button class="icon-btn del-btn" onclick={() => deleteItem(item.id)}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                  </button>
                </div>
              </td>
            </tr>
          {:else}
            <tr><td colspan="8" class="empty-cell">No items found</td></tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

{#if showAddModal}
  <div class="modal-overlay" onclick={() => showAddModal = false}>
    <div class="modal-card" onclick={(e) => e.stopPropagation()}>
      <h3>{editingId ? 'Edit' : 'Add'} Inventory Item</h3>
      <label class="field-label">Item Name</label>
      <input type="text" bind:value={newItem.name} placeholder="e.g. Olive Oil" />
      <label class="field-label">Category</label>
      <select bind:value={newItem.category}><option>Pantry</option><option>Dairy</option><option>Meat</option><option>Seafood</option><option>Bakery</option><option>Beverages</option></select>
      <div class="form-row">
        <div><label class="field-label">Quantity</label><input type="number" step="any" bind:value={newItem.quantity} /></div>
        <div><label class="field-label">Unit</label><select bind:value={newItem.unit}><option>kg</option><option>L</option><option>units</option></select></div>
      </div>
      <div class="form-row">
        <div><label class="field-label">Min. Stock</label><input type="number" step="any" bind:value={newItem.minStock} /></div>
        <div><label class="field-label">Vendor</label><input type="text" bind:value={newItem.vendor} placeholder="Vendor name" /></div>
      </div>
      <div class="modal-actions">
        <button class="btn btn-outline" onclick={() => showAddModal = false}>Cancel</button>
        <button class="btn btn-primary" onclick={saveItem}>{editingId ? 'Update' : 'Save'} Item</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .inventory-page { display: flex; flex-direction: column; gap: 20px; }
  .page-header { display: flex; align-items: flex-start; justify-content: space-between; }
  .page-header h2 { font-family: var(--font-display); font-size: 22px; }
  .page-subtitle { font-size: 13px; color: var(--text-secondary); margin-top: 2px; }
  .action-row { display: flex; align-items: center; justify-content: space-between; gap: 16px; }
  .filter-row { display: flex; gap: 8px; }
  .filter-pill { padding: 6px 16px; border-radius: var(--badge-radius); background: var(--card-surface); border: 1px solid var(--border); font-size: 13px; font-weight: 500; color: var(--text-secondary); cursor: pointer; transition: all 0.15s; }
  .filter-pill.active { background: var(--primary-teal); color: #fff; border-color: var(--primary-teal); }
  .search-input { width: 220px; }
  .fw500 { font-weight: 500; }
  .muted { color: var(--text-secondary); }
  .loading-state, .error-state, .empty-cell { text-align: center; padding: 40px; color: var(--text-secondary); }
  
  .action-buttons { display: flex; gap: 4px; }
  .icon-btn { background: none; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; width: 28px; height: 28px; border-radius: 4px; transition: 0.2s; color: var(--text-secondary); }
  .edit-btn:hover { background: var(--hover-bg); color: var(--primary-teal); }
  .del-btn:hover { background: var(--critical-bg); color: var(--error-red); }

  .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; }
  .modal-card { background: var(--card-surface); border-radius: 16px; padding: 32px; width: 480px; max-height: 90vh; overflow-y: auto; }
  .modal-card h3 { font-family: var(--font-display); font-size: 18px; margin-bottom: 16px; }
  .field-label { display: block; font-size: 13px; font-weight: 500; margin: 12px 0 4px; }
  .modal-card input, .modal-card select { width: 100%; }
  .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  .modal-actions { display: flex; gap: 12px; justify-content: flex-end; margin-top: 24px; }
</style>
