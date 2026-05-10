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
    try {
      orders = await api.getKitchenOrders() || [];
      connected = true;
    } catch(e) {
      console.error('KDS fetch error:', e);
      connected = false;
    } finally {
      loading = false;
    }
  }

  const orderedOrders = $derived(orders.filter(o => o.status === 'new' || o.status === 'ordered'));
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

  function parseItem(itemStr) {
    // Handle "6x meeeeem" (prefix)
    const prefixMatch = itemStr.match(/^(\d+x)\s*(.+)$/);
    if (prefixMatch) return { name: prefixMatch[2], qty: prefixMatch[1] };
    
    // Handle "Bruschetta ×2" (suffix)
    const suffixMatch = itemStr.match(/^(.+?)\s*(×\d+)$/);
    if (suffixMatch) return { name: suffixMatch[1], qty: suffixMatch[2] };
    
    return { name: itemStr, qty: '' };
  }

  async function startOrder(id) {
    try { await api.startOrder(id); await loadOrders(); } catch(e) { console.error(e); }
  }
  async function readyOrder(id) {
    try { await api.readyOrder(id); await loadOrders(); } catch(e) { console.error(e); }
  }

  function clockStr() {
    return new Date(now).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
  }
</script>

<svelte:head><title>Kitchen Display — Cafe De Paris</title></svelte:head>

<div class="kds">
  <!-- Top Bar -->
  <header class="kds-header">
    <div class="kds-brand">
      <div class="logo-box">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
      </div>
      <span class="brand-text">KITCHEN DISPLAY</span>
    </div>
    <div class="kds-counters">
      <span class="counter new-counter">{orderedOrders.length} Ordered</span>
      <span class="counter prep-counter">{preparingOrders.length} Preparing</span>
      <span class="counter ready-counter">{readyOrders.length} Ready</span>
    </div>
    <div class="kds-right">
      <span class="connection-dot" class:connected class:disconnected={!connected}></span>
      <span class="conn-label">{connected ? 'Connected' : 'Disconnected'}</span>
      <span class="kds-clock">{clockStr()}</span>
    </div>
  </header>

  <!-- Kanban -->
  {#if loading}
    <div class="loading-state">Loading kitchen orders...</div>
  {:else}
    <div class="kanban">
      <!-- NEW ORDERS -->
      <div class="kanban-col">
        <div class="col-header new-header"><h3>ORDERED</h3><span class="col-count">{orderedOrders.length}</span></div>
        <div class="col-body">
          {#each orderedOrders as order (order.id)}
            <div class="order-card new-card">
              <div class="order-top">
                <span class="order-id">{order.id}</span>
                <span class="order-timer" style="color: {timerColor(order.createdAt)}">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:-2px"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                  {elapsedStr(order.createdAt)}
                </span>
              </div>
              <p class="order-table">{order.table}</p>
              <div class="order-items">
                {#each order.items as item}
                  {@const parsed = parseItem(item)}
                  <div class="item-row">
                    <span class="item-name">{parsed.name}</span>
                    <span class="item-qty">{parsed.qty}</span>
                  </div>
                {/each}
              </div>
              <button class="action-btn start-btn" onclick={() => startOrder(order.id)}>Start</button>
            </div>
          {:else}<p class="col-empty">No new orders</p>{/each}
        </div>
      </div>

      <!-- PREPARING -->
      <div class="kanban-col">
        <div class="col-header prep-header"><h3>PREPARING</h3><span class="col-count">{preparingOrders.length}</span></div>
        <div class="col-body">
          {#each preparingOrders as order (order.id)}
            <div class="order-card prep-card">
              <div class="order-top">
                <span class="order-id">{order.id}</span>
                <span class="order-timer" style="color: {timerColor(order.createdAt)}">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:-2px"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                  {elapsedStr(order.createdAt)}
                </span>
              </div>
              <p class="order-table">{order.table}</p>
              <div class="order-items">
                {#each order.items as item}
                  {@const parsed = parseItem(item)}
                  <div class="item-row">
                    <span class="item-name">{parsed.name}</span>
                    <span class="item-qty">{parsed.qty}</span>
                  </div>
                {/each}
              </div>
              <button class="action-btn ready-btn" onclick={() => readyOrder(order.id)}>Ready</button>
            </div>
          {:else}<p class="col-empty">Nothing preparing</p>{/each}
        </div>
      </div>

      <!-- READY -->
      <div class="kanban-col">
        <div class="col-header ready-header"><h3>READY</h3><span class="col-count">{readyOrders.length}</span></div>
        <div class="col-body">
          {#each readyOrders as order (order.id)}
            <div class="order-card ready-card">
              <div class="order-top">
                <span class="order-id">{order.id}</span>
                <span class="order-timer" style="color: {timerColor(order.createdAt)}">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:inline;vertical-align:-2px"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                  {elapsedStr(order.createdAt)}
                </span>
              </div>
              <p class="order-table">{order.table}</p>
              <div class="order-items">
                {#each order.items as item}
                  {@const parsed = parseItem(item)}
                  <div class="item-row">
                    <span class="item-name">{parsed.name}</span>
                    <span class="item-qty">{parsed.qty}</span>
                  </div>
                {/each}
              </div>
            </div>
          {:else}<p class="col-empty">No orders ready</p>{/each}
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .kds { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background: var(--bg, #FAF8F5); font-family: 'DM Sans', sans-serif; }

  .kds-header { display: flex; align-items: center; justify-content: space-between; padding: 14px 24px; background: #fff; border-bottom: 1px solid #E5E7EB; flex-shrink: 0; }
  .kds-brand { display: flex; align-items: center; gap: 12px; }
  .logo-box { width: 36px; height: 36px; background: #1E5F74; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #fff; }
  .brand-text { font-weight: 700; font-size: 15px; color: #1E5F74; letter-spacing: 0.5px; }
  .kds-counters { display: flex; gap: 10px; }
  .counter { padding: 5px 16px; border-radius: 999px; font-size: 13px; font-weight: 600; }
  .new-counter { background: #DBEAFE; color: #1E40AF; }
  .prep-counter { background: #FEF3C7; color: #92400E; }
  .ready-counter { background: #D1FAE5; color: #065F46; }
  .kds-right { display: flex; align-items: center; gap: 10px; }
  .connection-dot { width: 8px; height: 8px; border-radius: 50%; }
  .connection-dot.connected { background: #38A169; }
  .connection-dot.disconnected { background: #E53E3E; }
  .conn-label { font-size: 13px; color: #6B7280; }
  .kds-clock { font-size: 16px; font-weight: 700; color: #1A1A1A; font-variant-numeric: tabular-nums; margin-left: 8px; }
  .loading-state { display: flex; align-items: center; justify-content: center; flex: 1; color: #6B7280; font-size: 16px; }

  .kanban { display: grid; grid-template-columns: repeat(3, 1fr); gap: 0; flex: 1; overflow: hidden; }
  .kanban-col { display: flex; flex-direction: column; overflow: hidden; border-right: 1px solid #E5E7EB; }
  .kanban-col:last-child { border-right: none; }
  .col-header { display: flex; align-items: center; justify-content: space-between; padding: 14px 20px; }
  .col-header h3 { font-size: 14px; font-weight: 800; letter-spacing: 0.5px; margin: 0; }
  .col-count { font-size: 18px; font-weight: 800; }
  .new-header { color: #1E40AF; }
  .prep-header { color: #92400E; }
  .ready-header { color: #E53E3E; }
  .col-body { flex: 1; overflow-y: auto; padding: 12px 16px; display: flex; flex-direction: column; gap: 12px; }
  .col-empty { text-align: center; padding: 32px; color: #6B7280; font-size: 13px; }

  .order-card { background: #fff; border-radius: 12px; padding: 18px 20px; border: 1px solid #E5E7EB; }
  .new-card { border-left: 4px solid #1E40AF; }
  .prep-card { border-left: 4px solid #D97706; }
  .ready-card { border-left: 4px solid #38A169; background: #F0FFF4; }
  .order-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
  .order-id { font-weight: 800; font-size: 18px; color: #1A1A1A; }
  .order-timer { font-variant-numeric: tabular-nums; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 4px; }
  .order-table { font-size: 14px; color: #6B7280; margin: 0 0 14px 0; font-weight: 500; }

  .order-items { display: flex; flex-direction: column; gap: 6px; margin-bottom: 16px; }
  .item-row { display: flex; justify-content: space-between; align-items: center; font-size: 14px; padding: 4px 0; border-bottom: 1px solid #f3f4f6; }
  .item-row:last-child { border-bottom: none; }
  .item-name { color: #1A1A1A; font-weight: 500; }
  .item-qty { color: #6B7280; font-weight: 600; }

  .action-btn { width: 100%; padding: 12px; border-radius: 10px; font-size: 14px; font-weight: 700; border: none; cursor: pointer; transition: all 0.15s ease; }
  .start-btn { background: #1E5F74; color: #fff; }
  .start-btn:hover { background: #174d5e; }
  .ready-btn { background: #38A169; color: #fff; }
  .ready-btn:hover { background: #2f855a; }
</style>
