<script>
  let { columns = [], rows = [], emptyMessage = 'No data available' } = $props();
</script>

<div class="table-wrapper card">
  <table>
    <thead>
      <tr>
        {#each columns as col}
          <th style={col.width ? `width:${col.width}` : ''}>{col.label}</th>
        {/each}
      </tr>
    </thead>
    <tbody>
      {#if rows.length === 0}
        <tr>
          <td colspan={columns.length} class="empty">{emptyMessage}</td>
        </tr>
      {:else}
        {#each rows as row}
          <tr>
            {#each columns as col}
              <td>
                {#if col.render}
                  {@html col.render(row)}
                {:else}
                  {row[col.key] ?? '—'}
                {/if}
              </td>
            {/each}
          </tr>
        {/each}
      {/if}
    </tbody>
  </table>
</div>

<style>
  .table-wrapper { overflow-x: auto; }
  table { width: 100%; border-collapse: collapse; }
  .empty { text-align: center; padding: 40px 16px; color: var(--text-secondary); }
</style>
