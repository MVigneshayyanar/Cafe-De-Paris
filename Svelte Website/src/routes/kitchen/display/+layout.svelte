<script>
  let { children } = $props();
</script>

<div class="kds-layout">{@render children()}</div>

<style>
  .kds-layout { width: 100vw; height: 100vh; overflow: hidden; background: var(--background); }
</style>
