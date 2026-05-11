/**
 * Cafe De Paris — API Abstraction Layer
 * All API calls go through this module.
 */

const BASE_URL = '/api/v1';

const authHeaders = () => ({
  'Content-Type': 'application/json'
});

const handle = async (res) => {
  if (res.status === 401) {
    if (typeof window !== 'undefined') window.location.href = '/manager/login';
    throw new Error('Unauthorized');
  }
  if (!res.ok) throw new Error(`${res.status}: ${await res.text()}`);
  const text = await res.text();
  return text ? JSON.parse(text) : null;
};

const get   = (path) => fetch(`${BASE_URL}${path}`, { headers: authHeaders(), credentials: 'include' }).then(handle);
const post  = (path, body) => fetch(`${BASE_URL}${path}`, { method: 'POST',  headers: authHeaders(), body: JSON.stringify(body), credentials: 'include' }).then(handle);
const patch = (path, body) => fetch(`${BASE_URL}${path}`, { method: 'PATCH', headers: authHeaders(), body: body ? JSON.stringify(body) : undefined, credentials: 'include' }).then(handle);
const del   = (path) => fetch(`${BASE_URL}${path}`, { method: 'DELETE', headers: authHeaders(), credentials: 'include' }).then(handle);

export const api = {
  // Auth
  managerLogin:         (email, password) => post('/auth/manager/login', { email, password }),
  ownerLogin:           (email, password) => post('/auth/owner/login', { email, password }),
  logout:               () => { /* Browser handles cookies, but we could call a logout endpoint */ },

  // Tables (CRUD)
  getTables:            () => get('/tables'),
  getTable:             (id) => get(`/tables/${id}`),
  createTable:          (table) => post('/tables', table),
  updateTable:          (id, data) => patch(`/tables/${id}`, data),
  deleteTable:          (id) => del(`/tables/${id}`),
  updateTableStatus:    (id, status) => patch(`/tables/${id}/status`, { status }),

  // Menu
  getMenu:              (category) => get(`/menu${category ? '?category=' + category : ''}`),
  addDish:              (dish) => post('/menu', dish),
  updateDish:           (id, data) => patch(`/menu/${id}`, data),
  deleteDish:           (id) => del(`/menu/${id}`),

  // Orders
  getOrders:            () => get('/orders'),
  sendToKitchen:        (tableId, items) => post('/orders', { tableId, items }),
  markServed:           (id) => patch(`/orders/${encodeURIComponent(id)}/served`),

  // Inventory
  getInventory:         () => get('/inventory'),
  addInventoryItem:     (item) => post('/inventory', item),
  updateInventoryItem:  (id, data) => patch(`/inventory/${id}`, data),
  deleteInventoryItem:  (id) => del(`/inventory/${id}`),

  // Bills
  scanBill:             (imageBase64, mimeType) => post('/bills/scan', { image: imageBase64, mimeType }),
  confirmBill:          (billData) => post('/bills/confirm', billData),

  // Payables
  getPayables:          () => get('/payables'),
  markPaid:             (id) => patch(`/payables/${id}/paid`),

  // Vendors
  getVendors:           () => get('/vendors'),
  addVendor:            (vendor) => post('/vendors', vendor),
  updateVendor:         (id, data) => patch(`/vendors/${id}`, data),

  // Alerts
  getAlerts:            () => get('/alerts'),
  markAlertRead:        (id) => patch(`/alerts/${id}/read`),

  // Waiters
  getWaiters:           () => get('/waiters'),
  addWaiter:            (waiter) => post('/waiters', waiter),
  deleteWaiter:         (id) => del(`/waiters/${id}`),

  // Analytics (owner)
  getOverview:          (date) => get(`/analytics/overview${date ? '?date=' + date : ''}`),
  getRevenue:           (period) => get(`/analytics/revenue${period ? '?period=' + period : ''}`),
  getSales:             () => get('/analytics/sales'),
  getInventoryInsights: () => get('/analytics/inventory'),

  // Reports
  getReports:           () => get('/reports'),
  downloadReport:       (id) => get(`/reports/${id}/download`),

  // Kitchen
  getKitchenOrders:     () => get('/kitchen/orders'),
  startOrder:           (id) => patch(`/kitchen/orders/${encodeURIComponent(id)}/start`),
  readyOrder:           (id) => patch(`/kitchen/orders/${encodeURIComponent(id)}/ready`),

  // Settings & Actions
  updateProfile:        (data) => patch('/settings/profile', data),
  updateNotifications:  (data) => patch('/settings/notifications', data),
};
