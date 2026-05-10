<script>
  let { title = '', subtitle = '', showSearch = false, searchPlaceholder = 'Search...', onSearch = () => {}, showScanBtn = false, onScan = () => {}, notificationCount = 0, userName = 'User', avatarInitials = 'U' } = $props();
</script>

<header class="topbar">
  <div class="topbar-left">
    <div>
      <h1 class="topbar-title">{title}</h1>
      {#if subtitle}
        <p class="topbar-subtitle">{subtitle}</p>
      {/if}
    </div>
  </div>
  <div class="topbar-right">
    {#if showSearch}
      <div class="search-box">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
        <input type="text" placeholder={searchPlaceholder} oninput={(e) => onSearch(e.target.value)} />
      </div>
    {/if}
    {#if showScanBtn}
      <button class="btn btn-primary" onclick={onScan}>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/></svg>
        Scan Bill
      </button>
    {/if}
    <button class="notification-btn">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
      {#if notificationCount > 0}
        <span class="notif-badge">{notificationCount}</span>
      {/if}
    </button>
    <div class="avatar-group">
      <div class="avatar">{avatarInitials}</div>
      <span class="avatar-name">{userName}</span>
    </div>
  </div>
</header>

<style>
  .topbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 32px;
    background: var(--card-surface);
    border-bottom: 1px solid var(--border);
    gap: 16px;
  }
  .topbar-title {
    font-family: var(--font-display);
    font-size: 22px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0;
  }
  .topbar-subtitle {
    font-size: 13px;
    color: var(--text-secondary);
    margin-top: 2px;
  }
  .topbar-right {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .search-box {
    display: flex;
    align-items: center;
    gap: 8px;
    background: var(--background);
    border: 1px solid var(--border);
    border-radius: var(--button-radius);
    padding: 8px 14px;
    min-width: 220px;
  }
  .search-box svg { color: var(--text-secondary); flex-shrink: 0; }
  .search-box input {
    border: none;
    background: none;
    outline: none;
    font-size: 13px;
    width: 100%;
    padding: 0;
  }
  .search-box input:focus { box-shadow: none; }
  .notification-btn {
    position: relative;
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: var(--background);
    border: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--text-secondary);
    cursor: pointer;
    transition: all 0.15s;
  }
  .notification-btn:hover { border-color: var(--primary-teal); color: var(--primary-teal); }
  .notif-badge {
    position: absolute;
    top: -4px;
    right: -4px;
    width: 18px;
    height: 18px;
    background: var(--error-red);
    color: #fff;
    font-size: 10px;
    font-weight: 600;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .avatar-group {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: var(--primary-teal);
    color: #fff;
    font-size: 13px;
    font-weight: 500;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .avatar-name {
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
  }
</style>
