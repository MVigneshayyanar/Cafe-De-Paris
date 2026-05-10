<script>
  import { onMount } from 'svelte';
  import { fade, fly } from 'svelte/transition';

  let mounted = $state(false);
  onMount(() => { mounted = true; });

  const portals = [
    {
      title: 'Manager Portal',
      desc: 'Inventory, vendors, and daily operations.',
      link: '/manager/login',
      icon: '💼',
      color: 'var(--primary-teal)'
    },
    {
      title: 'Owner Portal',
      desc: 'Business analytics and performance insights.',
      link: '/owner/login',
      icon: '📊',
      color: '#B45309'
    },
    {
      title: 'KDS System',
      desc: 'Real-time kitchen display and order tracking.',
      link: '/kds',
      icon: '🍳',
      color: '#059669'
    }
  ];
</script>

<svelte:head>
  <title>Cafe De Paris — Restaurant Management System</title>
</svelte:head>

<div class="landing-container">
  <div class="background-overlay"></div>
  
  <main class="content">
    {#if mounted}
      <header in:fly={{ y: -20, duration: 800 }}>
        <div class="logo-area">
          <div class="logo-icon">☕</div>
          <h1>Cafe De Paris</h1>
        </div>
        <p class="tagline">Premium Restaurant Management Suite</p>
      </header>

      <div class="portal-grid">
        {#each portals as portal, i}
          <a 
            href={portal.link} 
            class="portal-card"
            in:fly={{ y: 20, duration: 800, delay: 200 + (i * 150) }}
          >
            <div class="card-icon" style="background: {portal.color}15; color: {portal.color}">
              {portal.icon}
            </div>
            <h3>{portal.title}</h3>
            <p>{portal.desc}</p>
            <div class="card-action">
              Enter Portal <span class="arrow">→</span>
            </div>
          </a>
        {/each}
      </div>

      <footer in:fade={{ duration: 1000, delay: 800 }}>
        <p>&copy; 2026 Cafe De Paris. All rights reserved.</p>
      </footer>
    {/if}
  </main>
</div>

<style>
  .landing-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    background-color: #000;
    background-image: url('/cafe_interior_premium_1778165668105.png'); /* Note: You might need to move this image to the static folder */
    background-size: cover;
    background-position: center;
    overflow: hidden;
  }

  .background-overlay {
    position: absolute;
    inset: 0;
    background: radial-gradient(circle at center, rgba(30, 95, 116, 0.4) 0%, rgba(10, 10, 10, 0.85) 100%);
    backdrop-filter: blur(4px);
  }

  .content {
    position: relative;
    z-index: 10;
    width: 100%;
    max-width: 1100px;
    padding: 40px 20px;
    text-align: center;
  }

  header {
    margin-bottom: 60px;
  }

  .logo-area {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 16px;
    margin-bottom: 12px;
  }

  .logo-icon {
    font-size: 32px;
    background: var(--gold-accent);
    width: 56px;
    height: 56px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 16px;
    box-shadow: 0 8px 16px rgba(0,0,0,0.3);
  }

  h1 {
    font-size: 48px;
    color: #fff;
    letter-spacing: -0.02em;
    margin: 0;
  }

  .tagline {
    font-size: 18px;
    color: rgba(255,255,255,0.7);
    font-weight: 500;
  }

  .portal-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 24px;
    margin-bottom: 60px;
  }

  .portal-card {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 24px;
    padding: 40px 32px;
    text-decoration: none;
    transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
    display: flex;
    flex-direction: column;
    align-items: center;
    backdrop-filter: blur(12px);
  }

  .portal-card:hover {
    background: rgba(255, 255, 255, 0.1);
    transform: translateY(-8px);
    border-color: rgba(255, 255, 255, 0.2);
    box-shadow: 0 20px 40px rgba(0,0,0,0.4);
    text-decoration: none;
  }

  .card-icon {
    width: 64px;
    height: 64px;
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    margin-bottom: 24px;
    transition: transform 0.4s;
  }

  .portal-card:hover .card-icon {
    transform: scale(1.1) rotate(5deg);
  }

  h3 {
    color: #fff;
    font-size: 24px;
    margin-bottom: 12px;
  }

  p {
    color: rgba(255,255,255,0.6);
    font-size: 15px;
    line-height: 1.6;
    margin-bottom: 24px;
  }

  .card-action {
    margin-top: auto;
    font-weight: 600;
    color: #fff;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 8px;
    opacity: 0.8;
    transition: gap 0.3s;
  }

  .portal-card:hover .card-action {
    gap: 12px;
    opacity: 1;
  }

  footer {
    color: rgba(255,255,255,0.4);
    font-size: 13px;
  }

  @media (max-width: 640px) {
    h1 { font-size: 36px; }
    .portal-grid { grid-template-columns: 1fr; }
  }
</style>
