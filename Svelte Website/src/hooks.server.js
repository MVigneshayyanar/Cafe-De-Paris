import { redirect } from '@sveltejs/kit';

export async function handle({ event, resolve }) {
  const path = event.url.pathname;
  
  // Basic route guarding for client-side routing
  // Note: Actual auth check happens on client-side due to localStorage usage in this mock setup.
  // Real implementation would verify JWT from cookies here.
  
  if (path === '/') {
    throw redirect(302, '/manager/login');
  }

  return resolve(event);
}
