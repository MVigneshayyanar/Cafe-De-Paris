<script>
  import { goto } from '$app/navigation';
  import { login } from '$lib/stores/auth.js';
  import { api } from '$lib/api.js';

  let email = $state('');
  let password = $state('');
  let isLoading = $state(false);
  let error = $state('');

  async function handleLogin() {
    if (!email || !password) { error = 'Please enter both email and password'; return; }
    isLoading = true;
    error = '';
    try {
      await api.managerLogin(email, password);
      login();
      goto('/manager/dashboard');
    } catch (e) {
      error = 'Invalid credentials. Please try again.';
    } finally {
      isLoading = false;
    }
  }
</script>

<svelte:head><title>Manager Login — Cafe De Paris</title></svelte:head>

<div class="login-page">
  <div class="login-left">
    <div class="login-brand-card">
      <div class="brand-card-inner">
        <div class="brand-logo">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
        </div>
        <h1>Cafe De Paris</h1>
      </div>
      <h2 class="portal-title">Manager Portal</h2>
      <p class="brand-tagline">Streamline your inventory, automate bill processing, and maintain complete control over your café operations.</p>
    </div>
  </div>
  <div class="login-right">
    <div class="login-form-card">
      <h2>Welcome Back</h2>
      <p class="form-subtitle">Sign in to your manager account</p>

      {#if error}
        <div class="error-msg">{error}</div>
      {/if}

      <form onsubmit={(e) => { e.preventDefault(); handleLogin(); }}>
        <label class="field-label">Email</label>
        <input type="email" bind:value={email} placeholder="manager@cafedeparis.com" />

        <div class="password-row">
          <label class="field-label">Password</label>
          <a href="#!" class="forgot-link">Forgot password?</a>
        </div>
        <input type="password" bind:value={password} placeholder="Enter your password" />

        <button class="btn btn-primary login-btn" type="submit" disabled={isLoading}>
          {isLoading ? 'Signing In...' : 'Sign In'}
        </button>
      </form>
      <p class="secure-note">Secure enterprise-grade access for De Paris management.</p>
    </div>
  </div>
</div>

<style>
  .login-page { display: flex; min-height: 100vh; }
  .login-left {
    flex: 0 0 48%; background: var(--primary-teal);
    display: flex; align-items: center; justify-content: center; padding: 40px;
  }
  .login-brand-card { text-align: center; color: #fff; max-width: 340px; }
  .brand-card-inner {
    background: rgba(255,255,255,0.1); border-radius: 16px; padding: 32px; margin-bottom: 24px;
    display: flex; flex-direction: column; align-items: center; gap: 12px;
  }
  .brand-logo {
    width: 64px; height: 64px; background: rgba(255,255,255,0.15); border-radius: 16px;
    display: flex; align-items: center; justify-content: center; color: #fff;
  }
  .brand-card-inner h1 { font-family: var(--font-display); font-size: 24px; }
  .portal-title { font-family: var(--font-body); font-size: 20px; font-weight: 600; margin-bottom: 12px; }
  .brand-tagline { font-size: 14px; color: rgba(255,255,255,0.7); line-height: 1.7; }
  .login-right {
    flex: 1; background: var(--background);
    display: flex; align-items: center; justify-content: center; padding: 40px;
  }
  .login-form-card {
    background: var(--card-surface); border-radius: 16px; box-shadow: var(--card-shadow);
    border: 1px solid var(--border); padding: 36px; width: 100%; max-width: 380px;
  }
  .login-form-card h2 { font-family: var(--font-display); font-size: 22px; margin-bottom: 4px; }
  .form-subtitle { color: var(--text-secondary); font-size: 13px; margin-bottom: 24px; }
  .field-label { display: block; font-size: 13px; font-weight: 500; color: var(--text-primary); margin: 16px 0 6px; }
  .password-row { display: flex; justify-content: space-between; align-items: center; }
  .forgot-link { font-size: 12px; color: var(--primary-teal); }
  .login-form-card input { width: 100%; }
  .login-btn { width: 100%; margin-top: 24px; padding: 12px; font-size: 15px; border-radius: 12px; }
  .secure-note { text-align: center; font-size: 11px; color: var(--text-secondary); margin-top: 20px; }
  .error-msg { background: var(--critical-bg); color: var(--critical-text); padding: 10px 14px; border-radius: var(--button-radius); font-size: 13px; margin-bottom: 8px; }
</style>
