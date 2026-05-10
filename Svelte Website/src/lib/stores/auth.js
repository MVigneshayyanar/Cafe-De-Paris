import { writable } from 'svelte/store';
import { browser } from '$app/environment';

export const isAuthenticated = writable(
  browser && !!localStorage.getItem('cdp_token')
);

export function login(token) {
  if (browser) localStorage.setItem('cdp_token', token);
  isAuthenticated.set(true);
}

export function logout() {
  if (browser) localStorage.removeItem('cdp_token');
  isAuthenticated.set(false);
}

// Legacy compat export
export const auth = { login: (user) => {}, logout, restore: () => {} };
