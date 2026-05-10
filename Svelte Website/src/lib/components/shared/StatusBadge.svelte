<script>
  let { status = '', label = '' } = $props();

  const statusMap = {
    available:  { bg: 'var(--available-bg)',  color: 'var(--available-text)' },
    ordering:   { bg: 'var(--ordering-bg)',   color: 'var(--ordering-text)' },
    preparing:  { bg: 'var(--preparing-bg)',  color: 'var(--preparing-text)' },
    ready:      { bg: 'var(--ready-bg)',      color: 'var(--ready-text)' },
    billing:    { bg: 'var(--billing-bg)',     color: 'var(--billing-text)' },
    eating:     { bg: 'var(--eating-bg)',      color: 'var(--eating-text)' },
    billed:     { bg: 'var(--billed-bg)',      color: 'var(--billed-text)' },
    new:        { bg: 'var(--ordering-bg)',     color: 'var(--ordering-text)' },
    ordered:    { bg: 'var(--ordered-bg)',     color: 'var(--ordered-text)' },
    critical:   { bg: 'var(--critical-bg)',   color: 'var(--critical-text)' },
    low:        { bg: 'var(--low-bg)',        color: 'var(--low-text)' },
    ok:         { bg: 'var(--ok-bg)',         color: 'var(--ok-text)' },
    pending:    { bg: 'var(--pending-bg)',    color: 'var(--pending-text)' },
    overdue:    { bg: 'var(--overdue-bg)',    color: 'var(--overdue-text)' },
    paid:       { bg: 'var(--paid-bg)',       color: 'var(--paid-text)' },
  };

  const s = $derived(statusMap[status?.toLowerCase()] || { bg: 'var(--border)', color: 'var(--text-secondary)' });
  const displayLabel = $derived(label || status);
</script>

<span class="badge" style="background:{s.bg}; color:{s.color}">
  {displayLabel}
</span>

<style>
  .badge {
    display: inline-flex;
    align-items: center;
    padding: 3px 10px;
    border-radius: var(--badge-radius);
    font-size: 12px;
    font-weight: 500;
    line-height: 1.4;
    white-space: nowrap;
  }
</style>
