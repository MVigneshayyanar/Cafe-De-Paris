<script>
  import { onMount } from 'svelte';
  import { api } from '$lib/api.js';

  let dishes = $state([]);
  let inventory = $state([]);
  let loading = $state(true);
  let error = $state('');
  let search = $state('');
  
  let showAddModal = $state(false);
  let editingId = $state(null);
  let newItem = $state({ name: '', description: '', price: 0, category: 'mains', soldOut: false, ingredients: [] });
  
  onMount(async () => {
    await loadData();
  });

  async function loadData() {
    try {
      const [m, inv] = await Promise.all([api.getMenu(), api.getInventory()]);
      dishes = m || [];
      inventory = inv || [];
    } catch (e) { error = e.message; } finally { loading = false; }
  }

  const filtered = $derived(() => {
    let items = dishes;
    if (search) items = items.filter(i => i.name.toLowerCase().includes(search.toLowerCase()));
    return items;
  });

  function addIngredient() {
    if (inventory.length > 0) {
      newItem.ingredients = [...newItem.ingredients, { 
        inventoryId: inventory[0].id, 
        quantity: 1, 
        unit: inventory[0].unit,
        selectedUnit: inventory[0].unit
      }];
    }
  }

  function removeIngredient(index) {
    newItem.ingredients = newItem.ingredients.filter((_, i) => i !== index);
  }
  
  function handleIngredientChange(index, newId) {
    const invItem = inventory.find(i => i.id === newId);
    if (invItem) {
      newItem.ingredients[index].inventoryId = newId;
      newItem.ingredients[index].unit = invItem.unit;
      newItem.ingredients[index].selectedUnit = invItem.unit;
    }
  }

  function openAddModal() {
    editingId = null;
    newItem = { name: '', description: '', price: 0, category: 'mains', soldOut: false, ingredients: [] };
    showAddModal = true;
  }

  function editDish(dish) {
    editingId = dish.id;
    // Format ingredients for editing
    const formattedIngredients = (dish.ingredients || []).map(ing => {
      let q = ing.quantity;
      let selUnit = ing.unit;
      if (ing.inventory_item_unit === 'kg' && q < 1) { q = q * 1000; selUnit = 'g'; }
      if (ing.inventory_item_unit === 'L' && q < 1) { q = q * 1000; selUnit = 'ml'; }
      return { inventoryId: ing.inventory_item_id, quantity: q, unit: ing.inventory_item_unit, selectedUnit: selUnit };
    });
    newItem = { ...dish, ingredients: formattedIngredients };
    showAddModal = true;
  }

  async function saveDish() {
    try {
      const dishToSave = {
        ...newItem,
        ingredients: newItem.ingredients.map(ing => {
          let finalQty = ing.quantity;
          if (ing.unit === 'kg' && ing.selectedUnit === 'g') finalQty = ing.quantity / 1000;
          if (ing.unit === 'L' && ing.selectedUnit === 'ml') finalQty = ing.quantity / 1000;
          return { inventoryId: ing.inventoryId, quantity: finalQty };
        })
      };
      
      if (editingId) {
        await api.updateDish(editingId, dishToSave);
      } else {
        await api.addDish(dishToSave);
      }
      showAddModal = false;
      await loadData();
    } catch (e) { 
      error = e.message; 
      alert('Failed to save dish: ' + e.message);
    }
  }

  async function deleteDish(id) {
    if (confirm('Are you sure you want to delete this dish?')) {
      try {
        await api.deleteDish(id);
        await loadData();
      } catch (e) { 
        error = e.message;
        alert('Failed to delete dish: ' + e.message);
      }
    }
  }
</script>

<svelte:head><title>Dishes Management — Manager — Cafe De Paris</title></svelte:head>

<div class="dishes-page">
  <div class="page-header">
    <div>
      <h2>Dishes Management</h2>
      <p class="page-subtitle">Manage menu items and their recipe ingredients</p>
    </div>
    <button class="btn btn-primary" onclick={openAddModal}>+ Add Dish</button>
  </div>

  <div class="action-row">
    <input type="text" class="search-input" placeholder="Search dishes..." bind:value={search} />
  </div>

  {#if loading}
    <div class="loading-state">Loading dishes...</div>
  {:else if error}
    <div class="error-state">{error} <button class="btn btn-outline" onclick={loadData}>Retry</button></div>
  {:else}
    <div class="card">
      <table>
        <thead><tr><th>DISH NAME</th><th>CATEGORY</th><th>PRICE</th><th>INGREDIENTS</th><th>ACTIONS</th></tr></thead>
        <tbody>
          {#each filtered() as dish}
            <tr>
              <td class="fw500">
                {dish.name}
                {#if dish.soldOut}<span class="sold-out-badge">Sold Out</span>{/if}
              </td>
              <td class="muted">{dish.category || '—'}</td>
              <td class="fw500">€{dish.price.toFixed(2)}</td>
              <td class="muted">
                {#if dish.ingredients && dish.ingredients.length > 0}
                  <ul class="ing-list">
                    {#each dish.ingredients as ing}
                      <li>{ing.inventory_item_name} ({ing.quantity} {ing.inventory_item_unit})</li>
                    {/each}
                  </ul>
                {:else}
                  No ingredients mapped
                {/if}
              </td>
              <td>
                <div class="action-buttons">
                  <button class="icon-btn edit-btn" onclick={() => editDish(dish)}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                  </button>
                  <button class="icon-btn del-btn" onclick={() => deleteDish(dish.id)}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                  </button>
                </div>
              </td>
            </tr>
          {:else}
            <tr><td colspan="5" class="empty-cell">No dishes found</td></tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

{#if showAddModal}
  <div class="modal-overlay" onclick={() => showAddModal = false}>
    <div class="modal-card" onclick={(e) => e.stopPropagation()}>
      <h3>{editingId ? 'Edit' : 'Add'} Dish</h3>
      
      <label class="field-label">Dish Name</label>
      <input type="text" bind:value={newItem.name} placeholder="e.g. Chicken Biryani" />
      
      <label class="field-label">Description</label>
      <input type="text" bind:value={newItem.description} placeholder="Short description..." />
      
      <div class="form-row">
        <div><label class="field-label">Category</label><select bind:value={newItem.category}><option>starters</option><option>mains</option><option>sides</option><option>desserts</option><option>drinks</option></select></div>
        <div><label class="field-label">Price (€)</label><input type="number" step="0.5" bind:value={newItem.price} /></div>
      </div>
      
      <div class="ingredients-section">
        <div class="ing-header">
          <h4>Recipe Ingredients</h4>
          <button class="btn btn-outline small-btn" onclick={addIngredient}>+ Add</button>
        </div>
        
        {#if newItem.ingredients.length === 0}
          <p class="muted small-txt">No ingredients added yet.</p>
        {:else}
          <div class="ing-rows">
            {#each newItem.ingredients as ing, idx}
              <div class="ing-row">
                <select value={ing.inventoryId} onchange={(e) => handleIngredientChange(idx, parseInt(e.target.value))}>
                  {#each inventory as invItem}
                    <option value={invItem.id}>{invItem.name}</option>
                  {/each}
                </select>
                <input type="number" step="0.01" bind:value={newItem.ingredients[idx].quantity} placeholder="Qty" class="qty-input" />
                
                <select class="unit-select" bind:value={newItem.ingredients[idx].selectedUnit}>
                  {#if ing.unit === 'kg'}
                    <option value="kg">kg</option>
                    <option value="g">g</option>
                  {:else if ing.unit === 'L'}
                    <option value="L">L</option>
                    <option value="ml">ml</option>
                  {:else}
                    <option value={ing.unit}>{ing.unit}</option>
                  {/if}
                </select>

                <button class="icon-btn del-btn" onclick={() => removeIngredient(idx)}>×</button>
              </div>
            {/each}
          </div>
        {/if}
      </div>

      <div class="modal-actions">
        <button class="btn btn-outline" onclick={() => showAddModal = false}>Cancel</button>
        <button class="btn btn-primary" onclick={saveDish}>{editingId ? 'Update' : 'Save'} Dish</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .dishes-page { display: flex; flex-direction: column; gap: 20px; }
  .page-header { display: flex; align-items: flex-start; justify-content: space-between; }
  .page-header h2 { font-family: var(--font-display); font-size: 22px; }
  .page-subtitle { font-size: 13px; color: var(--text-secondary); margin-top: 2px; }
  .action-row { display: flex; align-items: center; justify-content: space-between; gap: 16px; }
  .search-input { width: 300px; }
  .fw500 { font-weight: 500; }
  .muted { color: var(--text-secondary); }
  .small-txt { font-size: 13px; }
  
  .sold-out-badge { background: var(--critical-bg); color: var(--error-red); font-size: 11px; padding: 2px 6px; border-radius: 4px; margin-left: 8px; font-weight: 600; }
  .ing-list { margin: 0; padding-left: 16px; font-size: 13px; }
  .ing-list li { margin-bottom: 4px; }
  
  .action-buttons { display: flex; gap: 4px; }
  .icon-btn { background: none; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; width: 28px; height: 28px; border-radius: 4px; transition: 0.2s; color: var(--text-secondary); }
  .edit-btn:hover { background: var(--hover-bg); color: var(--primary-teal); }
  .del-btn:hover { background: var(--critical-bg); color: var(--error-red); }
  
  .loading-state, .error-state, .empty-cell { text-align: center; padding: 40px; color: var(--text-secondary); }
  
  .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; }
  .modal-card { background: var(--card-surface); border-radius: 16px; padding: 32px; width: 500px; max-height: 90vh; overflow-y: auto; }
  .modal-card h3 { font-family: var(--font-display); font-size: 18px; margin-bottom: 16px; }
  .field-label { display: block; font-size: 13px; font-weight: 500; margin: 12px 0 4px; }
  .modal-card input, .modal-card select { width: 100%; }
  .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  
  .ingredients-section { margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border); }
  .ing-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
  .ing-header h4 { font-size: 14px; font-weight: 600; }
  .small-btn { padding: 4px 12px; font-size: 12px; }
  
  .ing-rows { display: flex; flex-direction: column; gap: 10px; }
  .ing-row { display: flex; align-items: center; gap: 8px; }
  .ing-row select { flex: 1; }
  .qty-input { width: 80px !important; }
  .unit-select { width: 70px !important; font-size: 13px; padding: 4px; }
  
  .modal-actions { display: flex; gap: 12px; justify-content: flex-end; margin-top: 24px; }
</style>
