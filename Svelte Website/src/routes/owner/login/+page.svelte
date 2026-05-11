<script>
  import { goto } from "$app/navigation";
  import { login } from "$lib/stores/auth.js";
  import { api } from "$lib/api.js";

  let email = $state("");
  let password = $state("");
  let showPassword = $state(false);
  let isLoading = $state(false);
  let error = $state("");

  async function handleLogin() {
    if (!email || !password) {
      error = "Please fill in all fields";
      return;
    }
    isLoading = true;
    error = "";
    try {
      await api.ownerLogin(email, password);
      login();
      goto("/owner/overview");
    } catch (e) {
      error = "Invalid credentials.";
    } finally {
      isLoading = false;
    }
  }
</script>

<svelte:head><title>Owner Login — Cafe De Paris</title></svelte:head>

<div class="login-page">
  <div class="login-left">
    <div class="login-brand-card">
      <div class="brand-logo">
        <svg
          width="32"
          height="32"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"><path d="M3 11l19-9-9 19-2-8-8-2z" /></svg
        >
      </div>
      <h1>Welcome to De Paris</h1>
      <p class="brand-tagline">
        Your executive dashboard for complete business visibility. Monitor
        performance, track revenue, and make informed decisions.
      </p>
    </div>
  </div>
  <div class="login-right">
    <div class="login-form-card">
      <div class="form-logo">
        <svg
          width="28"
          height="28"
          viewBox="0 0 24 24"
          fill="none"
          stroke="var(--primary-teal)"
          stroke-width="2"><path d="M3 11l19-9-9 19-2-8-8-2z" /></svg
        >
      </div>
      <h2>Owner Dashboard</h2>
      <p class="form-subtitle">Sign in to access your business insights</p>
      {#if error}<div class="error-msg">{error}</div>{/if}
      <form
        onsubmit={(e) => {
          e.preventDefault();
          handleLogin();
        }}
      >
        <label class="field-label">Email</label>
        <input
          type="email"
          bind:value={email}
          placeholder="owner@cafedeparis.com"
        />
        <div class="password-row">
          <label class="field-label">Password</label><a
            href="#!"
            class="forgot-link">Forgot password?</a
          >
        </div>
        <div class="password-input-wrap">
          <input
            type={showPassword ? "text" : "password"}
            bind:value={password}
            placeholder="Enter your password"
          />
          <button
            type="button"
            class="eye-btn"
            onclick={() => (showPassword = !showPassword)}
            >{showPassword ? "🙈" : "👁"}</button
          >
        </div>
        <button
          class="btn btn-primary login-btn"
          type="submit"
          disabled={isLoading}>{isLoading ? "Signing In..." : "Sign In"}</button
        >
      </form>
      <p class="secure-note">Secure access for authorized personnel only</p>
    </div>
  </div>
</div>

<style>
  .login-page {
    display: flex;
    min-height: 100vh;
  }
  .login-left {
    flex: 0 0 48%;
    background: var(--primary-teal);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px;
  }
  .login-brand-card {
    text-align: center;
    color: #fff;
    max-width: 360px;
  }
  .brand-logo {
    width: 64px;
    height: 64px;
    background: rgba(255, 255, 255, 0.15);
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 24px;
    color: #fff;
  }
  .login-brand-card h1 {
    font-family: var(--font-display);
    font-size: 26px;
    margin-bottom: 16px;
  }
  .brand-tagline {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.7);
    line-height: 1.7;
  }
  .login-right {
    flex: 1;
    background: var(--background);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px;
  }
  .login-form-card {
    background: var(--card-surface);
    border-radius: 16px;
    box-shadow: var(--card-shadow);
    border: 1px solid var(--border);
    padding: 36px;
    width: 100%;
    max-width: 380px;
  }
  .form-logo {
    width: 48px;
    height: 48px;
    background: rgba(30, 95, 116, 0.08);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 16px;
  }
  .login-form-card h2 {
    font-family: var(--font-display);
    font-size: 22px;
    text-align: center;
    margin-bottom: 4px;
  }
  .form-subtitle {
    text-align: center;
    color: var(--text-secondary);
    font-size: 13px;
    margin-bottom: 24px;
  }
  .field-label {
    display: block;
    font-size: 13px;
    font-weight: 500;
    margin: 16px 0 6px;
  }
  .password-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .forgot-link {
    font-size: 12px;
    color: var(--primary-teal);
  }
  .password-input-wrap {
    position: relative;
  }
  .password-input-wrap input {
    width: 100%;
    padding-right: 40px;
  }
  .eye-btn {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    font-size: 16px;
    cursor: pointer;
  }
  .login-form-card input {
    width: 100%;
  }
  .login-btn {
    width: 100%;
    margin-top: 24px;
    padding: 12px;
    font-size: 15px;
    border-radius: 12px;
  }
  .secure-note {
    text-align: center;
    font-size: 11px;
    color: var(--text-secondary);
    margin-top: 20px;
  }
  .error-msg {
    background: var(--critical-bg);
    color: var(--critical-text);
    padding: 10px;
    border-radius: 8px;
    font-size: 13px;
    margin-bottom: 8px;
  }
</style>
