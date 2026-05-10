<script>
  import { onMount, onDestroy } from 'svelte';
  import { api } from '$lib/api.js';

  let orders = $state([]);
  let loading = $state(true);
  let now = $state(Date.now());
  let connected = $state(true);
  let pollInterval;
  let clockInterval;

  onMount(async () => {
    await loadOrders();
    pollInterval = setInterval(loadOrders, 3000);
    clockInterval = setInterval(() => now = Date.now(), 1000);
  });

  onDestroy(() => { clearInterval(pollInterval); clearInterval(clockInterval); });

  async function loadOrders() {
    try { orders = await api.getKitchenOrders() || []; connected = true; } catch(e) { connected = false; }
    finally { loading = false; }
  }

  const newOrders = $derived(orders.filter(o => o.status === 'new'));
  const preparingOrders = $derived(orders.filter(o => o.status === 'preparing'));
  const readyOrders = $derived(orders.filter(o => o.status === 'ready'));

  function elapsedStr(createdAt) {
    const diff = Math.floor((now - createdAt) / 1000);
    const m = Math.floor(diff / 60);
    const s = diff % 60;
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  function timerColor(createdAt) {
    const mins = (now - createdAt) / 60000;
    if (mins > 12) return '#E53E3E';
    if (mins > 8) return '#D97706';
    return '#6B7280';
  }

  async function startOrder(id) {
    try { await api.startOrder(id); await loadOrders(); } catch(e) {}
  }
  async function readyOrder(id) {
    try { await api.readyOrder(id); await loadOrders(); } catch(e) {}
  }

  function clockStr() { return new Date(now).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }); }
</script>

<svelte:head><title>Kitchen Display — Cafe De Paris</title></svelte:head>

<div class="kds">
  <!-- Top Bar -->
  <header class="kds-header">
    <div class="kds-brand">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
      <span>Kitchen Display</span>
    </div>
    <div class="kds-counters">
      <span class="counter new-counter">{newOrders.length} New</span>
      <span class="counter prep-counter">{preparingOrders.length} Preparing</span>
      <span class="counter ready-counter">{readyOrders.length} Ready</span>
    </div>
    <div class="kds-right">
      <span class="connection-dot" class:connected class:disconnected={!connected}></span>
      <span class="kds-clock">{clockStr()}</span>
    </div>
  </header>

  <!-- Kanban -->
  {#if loading}
    <div class="loading-state">Loading kitchen orders...</div>
  {:else}
    <div class="kanban">
      <div class="kanban-col">
        <div class="col-header new-header"><h3>NEW ORDERS</h3><span class="col-count">{newOrders.length}</span></div>
        <div class="col-body">
          {#each newOrders as order}
            <div class="order-card new-card">
              <div class="order-top"><span class="order-id">{order.id}</span><span class="order-timer" style="color: {timerColor(order.createdAt)}">{elapsedStr(order.createdAt)}</span></div>
              <p class="order-table">{order.table}</p>
              <ul class="order-items">{#each order.items as item}<li>{item}</li>{/each}</ul>
              <button class="action-btn start-btn" onclick={() => startOrder(order.id)}>Start Preparing</button>
            </div>
          {:else}<p class="col-empty">No new orders</p>{/each}
        </div>
      </div>

      <div class="kanban-col">
        <div class="col-header prep-header"><h3>PREPARING</h3><span class="col-count">{preparingOrders.length}</span></div>
        <div class="col-body">
          {#each preparingOrders as order}
            <div class="order-card prep-card">
              <div class="order-top"><span class="order-id">{order.id}</span><span class="order-timer" style="color: {timerColor(order.createdAt)}">{elapsedStr(order.createdAt)}</span></div>
              <p class="order-table">{order.table}</p>
              <ul class="order-items">{#each order.items as item}<li>{item}</li>{/each}</ul>
              <button class="action-btn ready-btn" onclick={() => readyOrder(order.id)}>Mark Ready</button>
            </div>
          {:else}<p class="col-empty">Nothing preparing</p>{/each}
        </div>
      </div>

      <div class="kanban-col">
        <div class="col-header ready-header"><h3>READY</h3><span class="col-count">{readyOrders.length}</span></div>
        <div class="col-body">
          {#each readyOrders as order}
            <div class="order-card ready-card">
              <div class="order-top"><span class="order-id">{order.id}</span><span class="order-timer" style="color: {timerColor(order.createdAt)}">{elapsedStr(order.createdAt)}</span></div>
              <p class="order-table">{order.table}</p>
              <ul class="order-items">{#each order.items as item}<li>{item}</li>{/each}</ul>
            </div>
          {:else}<p class="col-empty">No orders ready</p>{/each}
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .kds { display: flex; flex-direction: column; height: 100vh; overflow: hidden; }
  .kds-header { display: flex; align-items: center; justify-content: space-between; padding: 12px 24px; background: #fff; border-bottom: 1px solid var(--border); flex-shrink: 0; }
  .kds-brand { display: flex; align-items: center; gap: 10px; font-weight: 600; font-size: 15px; color: var(--primary-teal); }
  .kds-counters { display: flex; gap: 10px; }
  .counter { padding: 4px 14px; border-radius: 999px; font-size: 13px; font-weight: 600; }
  .new-counter { background: #DBEAFE; color: #1E40AF; }
  .prep-counter { background: #FEF3C7; color: #92400E; }
  .ready-counter { background: #D1FAE5; color: #065F46; }
  .kds-right { display: flex; align-items: center; gap: 12px; }
  .connection-dot { width: 8px; height: 8px; border-radius: 50%; }
  .connection-dot.connected { background: #38A169; }
  .connection-dot.disconnected { background: #E53E3E; }
  .kds-clock { font-size: 14px; font-weight: 500; color: var(--text-secondary); font-variant-numeric: tabular-nums; }
  .loading-state { display: flex; align-items: center; justify-content: center; flex: 1; color: var(--text-secondary); }

  .kanban { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; flex: 1; padding: 16px; overflow: hidden; }
  .kanban-col { display: flex; flex-direction: column; overflow: hidden; }
  .col-header { display: flex; align-items: center; justify-content: space-between; padding: 10px 16px; border-radius: 10px 10px 0 0; }
  .col-header h3 { font-size: 13px; font-weight: 700; letter-spacing: 0.5px; }
  .col-count { font-size: 12px; font-weight: 600; }
  .new-header { background: #DBEAFE; color: #1E40AF; }
  .prep-header { background: #FEF3C7; color: #92400E; }
  .ready-header { background: #D1FAE5; color: #065F46; }
  .col-body { flex: 1; overflow-y: auto; padding: 8px 0; display: flex; flex-direction: column; gap: 10px; }
  .col-empty { text-align: center; padding: 32px; color: var(--text-secondary); font-size: 13px; }

  .order-card { background: #fff; border-radius: 10px; padding: 14px 16px; border: 1px solid var(--border); }
  .new-card { border-left: 3px solid #1E40AF; }
  .prep-card { border-left: 3px solid #D97706; }
  .ready-card { border-left: 3px solid #38A169; }
  .order-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
  .order-id { font-weight: 700; font-size: 15px; }
  .order-timer { font-variant-numeric: tabular-nums; font-weight: 600; font-size: 14px; }
  .order-table { font-size: 13px; color: var(--text-secondary); margin-bottom: 8px; }
  .order-items { list-style: none; padding: 0; margin: 0; }
  .order-items li { font-size: 13px; padding: 3px 0; border-bottom: 1px solid #f3f4f6; }
  .order-items li:last-child { border-bottom: none; }

  .action-btn { width: 100%; margin-top: 10px; padding: 8px; border-radius: 8px; font-size: 13px; font-weight: 600; border: none; cursor: pointer; }
  .start-btn { background: #1E40AF; color: #fff; }
  .start-btn:hover { background: #1e3a8a; }
  .ready-btn { background: #38A169; color: #fff; }
  .ready-btn:hover { background: #2f855a; }
</style>
