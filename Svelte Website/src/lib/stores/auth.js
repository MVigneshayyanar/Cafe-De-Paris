import { writable } from 'svelte/store';
import { browser } from '$app/environment';

// Since we use HTTP-only cookies, we can't check the cookie directly from JS.
// We'll use a simple "cdp_logged_in" flag in localStorage to track UI state.
export const isAuthenticated = writable(
  browser && localStorage.getItem('cdp_logged_in') === 'true'
);

export function login() {
  if (browser) localStorage.setItem('cdp_logged_in', 'true');
  isAuthenticated.set(true);
}

export function logout() {
  if (browser) localStorage.removeItem('cdp_logged_in');
  isAuthenticated.set(false);
}

// Legacy compat export
export const auth = { login, logout, restore: () => {} };
