<script>
  import { api } from '$lib/api.js';

  let step = $state(1);
  let file = $state(null);
  let processing = $state(false);
  let extractedItems = $state([]);
  let error = $state('');

  function handleDrop(e) { e.preventDefault(); const f = e.dataTransfer?.files?.[0]; if (f) handleFile(f); }
  function handleFileInput(e) { const f = e.target.files?.[0]; if (f) handleFile(f); }

  async function handleFile(f) {
    if (f.size > 10 * 1024 * 1024) { error = 'File too large (max 10MB)'; return; }
    if (!['image/jpeg','image/png','application/pdf'].includes(f.type)) { error = 'Invalid file type'; return; }
    file = f; step = 2; processing = true; error = '';
    try {
      const reader = new FileReader();
      const base64 = await new Promise((resolve) => { reader.onload = () => resolve(reader.result.split(',')[1]); reader.readAsDataURL(f); });
      const result = await api.scanBill(base64, f.type);
      extractedItems = result.items || [];
      step = 3;
    } catch (e) { error = e.message; step = 1; } finally { processing = false; }
  }

  async function confirmBill() {
    try {
      await api.confirmBill({ items: extractedItems });
      step = 1; file = null; extractedItems = [];
      alert('Inventory updated successfully!');
    } catch (e) { error = e.message; }
  }
</script>

<svelte:head><title>Scan Bills — Cafe De Paris</title></svelte:head>

<div class="scan-page">
  <h2>Scan Bills</h2>
  <p class="page-subtitle">Upload vendor bills to automatically update inventory</p>

  {#if error}<div class="error-msg">{error}</div>{/if}

  {#if step === 1}
    <div class="drop-zone" ondrop={handleDrop} ondragover={(e) => e.preventDefault()}>
      <div class="drop-icon"><svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></div>
      <p class="drop-title">Drop your bill here</p>
      <p class="drop-sub">Supports PDF, JPG, PNG files up to 10MB</p>
      <div class="drop-actions">
        <label class="btn btn-primary"><input type="file" accept=".pdf,.jpg,.jpeg,.png" hidden onchange={handleFileInput} />Upload File</label>
      </div>
    </div>
    <div class="steps-row">
      <div class="step-card"><div class="step-num">1</div><h4>Upload Bill</h4><p>Drop or select your vendor bill</p></div>
      <div class="step-card"><div class="step-num">2</div><h4>AI Processing</h4><p>We extract items and prices</p></div>
      <div class="step-card"><div class="step-num">3</div><h4>Review & Confirm</h4><p>Verify and update inventory</p></div>
    </div>
  {:else if step === 2}
    <div class="processing-state">
      <div class="spinner"></div>
      <p>Processing your bill...</p>
    </div>
  {:else if step === 3}
    <div class="card review-card">
      <h3>Review Extracted Data</h3>
      <table>
        <thead><tr><th>Item Name</th><th>Quantity</th><th>Unit</th><th>Price</th><th>Vendor</th></tr></thead>
        <tbody>
          {#each extractedItems as item, i}
            <tr>
              <td><input type="text" bind:value={extractedItems[i].name} /></td>
              <td><input type="number" bind:value={extractedItems[i].quantity} style="width:80px" /></td>
              <td>{item.unit}</td>
              <td>€{item.price?.toFixed(2)}</td>
              <td>{item.vendor}</td>
            </tr>
          {/each}
        </tbody>
      </table>
      <button class="btn btn-primary confirm-btn" onclick={confirmBill}>Confirm & Update Inventory</button>
      <button class="scan-again" onclick={() => { step = 1; file = null; }}>Scan Another</button>
    </div>
  {/if}
</div>

<style>
  .scan-page { max-width: 680px; margin: 0 auto; }
  .scan-page h2 { font-family: var(--font-display); font-size: 22px; text-align: center; }
  .page-subtitle { text-align: center; color: var(--text-secondary); font-size: 13px; margin-bottom: 32px; }
  .error-msg { background: var(--critical-bg); color: var(--critical-text); padding: 10px; border-radius: 8px; font-size: 13px; margin-bottom: 16px; }
  .drop-zone { border: 2px dashed var(--border); border-radius: 12px; padding: 48px; text-align: center; }
  .drop-icon { width: 56px; height: 56px; background: var(--background); border-radius: 12px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; color: var(--text-secondary); }
  .drop-title { font-weight: 600; font-size: 16px; }
  .drop-sub { font-size: 12px; color: var(--text-secondary); margin: 4px 0 20px; }
  .drop-actions { display: flex; gap: 12px; justify-content: center; }
  .steps-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 32px; }
  .step-card { text-align: center; padding: 20px; background: var(--card-surface); border-radius: 12px; border: 1px solid var(--border); }
  .step-num { width: 28px; height: 28px; background: var(--primary-teal); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; margin: 0 auto 8px; }
  .step-card h4 { font-size: 14px; margin-bottom: 4px; }
  .step-card p { font-size: 12px; color: var(--text-secondary); }
  .processing-state { text-align: center; padding: 60px; }
  .spinner { width: 40px; height: 40px; border: 3px solid var(--border); border-top-color: var(--primary-teal); border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 16px; }
  @keyframes spin { to { transform: rotate(360deg); } }
  .review-card { padding: 24px; margin-top: 20px; }
  .review-card h3 { font-family: var(--font-display); font-size: 18px; margin-bottom: 16px; }
  .review-card input { border: 1px solid var(--border); padding: 6px 8px; border-radius: 4px; font-size: 13px; }
  .confirm-btn { width: 100%; margin-top: 20px; }
  .scan-again { display: block; text-align: center; margin-top: 12px; color: var(--primary-teal); font-size: 13px; background: none; border: none; cursor: pointer; }
</style>
