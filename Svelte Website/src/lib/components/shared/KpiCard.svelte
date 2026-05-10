<script>
  let { icon = '', label = '', value = '', trend = '', trendUp = true, color = 'var(--text-primary)', subtitle = '' } = $props();
</script>

<div class="kpi-card card">
  {#if icon}
    <div class="kpi-icon">{@html icon}</div>
  {/if}
  <p class="kpi-label">{label}</p>
  <p class="kpi-value" style="color: {color}">{value}</p>
  {#if trend}
    <span class="kpi-trend" class:up={trendUp} class:down={!trendUp}>
      {trendUp ? '↑' : '↓'} {trend}
    </span>
  {/if}
  {#if subtitle}
    <p class="kpi-subtitle">{subtitle}</p>
  {/if}
</div>

<style>
  .kpi-card {
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  .kpi-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: rgba(30,95,116,0.08);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--primary-teal);
    margin-bottom: 8px;
  }
  .kpi-icon :global(svg) { width: 20px; height: 20px; }
  .kpi-label {
    font-size: 13px;
    color: var(--text-secondary);
    font-weight: 400;
  }
  .kpi-value {
    font-family: var(--font-display);
    font-size: 28px;
    font-weight: 600;
    line-height: 1.2;
  }
  .kpi-trend {
    font-size: 12px;
    font-weight: 500;
    padding: 2px 8px;
    border-radius: var(--badge-radius);
    width: fit-content;
  }
  .kpi-trend.up { background: var(--ready-bg); color: var(--ready-text); }
  .kpi-trend.down { background: var(--critical-bg); color: var(--critical-text); }
  .kpi-subtitle { font-size: 12px; color: var(--text-secondary); }
</style>
