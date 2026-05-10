<script>
  let { items = [], activeItem = '', role = 'manager', onNavigate = () => {} } = $props();
</script>

<aside class="sidebar">
  <div class="sidebar-brand">
    <div class="logo-icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
    </div>
    <div class="brand-text">
      <span class="brand-name">Cafe De Paris</span>
      <span class="brand-role">{role === 'owner' ? 'Owner Portal' : 'Manager Portal'}</span>
    </div>
  </div>

  <nav class="sidebar-nav">
    {#each items as item}
      {#if item.divider}
        <div class="nav-divider"></div>
      {:else}
        <button
          class="nav-item"
          class:active={activeItem === item.id}
          onclick={() => onNavigate(item.id, item.path)}
        >
          <span class="nav-icon">{@html item.icon}</span>
          <span class="nav-label">{item.label}</span>
        </button>
      {/if}
    {/each}
  </nav>
</aside>

<style>
  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    width: var(--sidebar-width, 220px);
    height: 100vh;
    background: var(--primary-teal);
    display: flex;
    flex-direction: column;
    z-index: 100;
    overflow-y: auto;
  }
  .sidebar-brand {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 24px 20px 20px;
    border-bottom: 1px solid rgba(255,255,255,0.1);
  }
  .logo-icon {
    width: 40px;
    height: 40px;
    background: rgba(255,255,255,0.15);
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    flex-shrink: 0;
  }
  .brand-name {
    font-family: var(--font-display);
    font-size: 15px;
    font-weight: 600;
    color: #fff;
    display: block;
  }
  .brand-role {
    font-size: 11px;
    color: rgba(255,255,255,0.6);
    display: block;
  }
  .sidebar-nav {
    padding: 12px 8px;
    flex: 1;
  }
  .nav-divider {
    height: 1px;
    background: rgba(255,255,255,0.1);
    margin: 8px 12px;
  }
  .nav-item {
    display: flex;
    align-items: center;
    gap: 12px;
    width: 100%;
    padding: 10px 16px;
    border-radius: 8px;
    background: none;
    border: none;
    color: rgba(255,255,255,0.7);
    font-size: 14px;
    font-weight: 400;
    cursor: pointer;
    transition: all 0.15s;
    text-align: left;
    position: relative;
  }
  .nav-item:hover {
    background: rgba(255,255,255,0.1);
    color: #fff;
  }
  .nav-item.active {
    background: rgba(255,255,255,0.12);
    color: #fff;
    font-weight: 500;
    border-left: 3px solid var(--gold-accent, #C9A84C);
    padding-left: 13px;
  }
  .nav-icon {
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  .nav-icon :global(svg) {
    width: 20px;
    height: 20px;
  }
</style>
