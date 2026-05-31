<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { authStore } from '$lib/stores';
  import { messaging } from '$lib/api';
  import { Home, Search, Plus, Bell, User, MessagesSquare } from 'lucide-svelte';
  import Avatar from './Avatar.svelte';

  let unreadMessages = 0;
  let loadedUnread = false;

  $: username = $authStore.user?.username;
  $: path = $page.url.pathname;

  $: items = [
    { href: '/feed', label: 'Главная', icon: Home },
    { href: '/search', label: 'Поиск', icon: Search },
    { href: '/upload', label: 'Загрузить', icon: Plus, upload: true },
    { href: '/messages', label: 'Чаты', icon: MessagesSquare, badge: unreadMessages },
    { href: '/notifications', label: 'Уведомления', icon: Bell },
    { href: username ? `/profile/${username}` : '/login', label: 'Профиль', icon: User, profile: true }
  ];

  function active(item) {
    return item.profile ? path.startsWith('/profile') : path === item.href || path.startsWith(`${item.href}/`);
  }

  async function loadUnread() {
    if (!$authStore.authenticated) return;
    loadedUnread = true;
    const data = await messaging.conversations().catch(() => null);
    unreadMessages = data?.conversations?.reduce((sum, item) => sum + (Number(item.unread_count) || 0), 0) || 0;
  }

  $: if ($authStore.authenticated && !loadedUnread) loadUnread();
  onMount(loadUnread);
</script>

<aside class="sidebar desktop-sidebar">
  <a href="/feed" class="logo">LearnFlow</a>
  <nav class="desktop-nav">
    {#each items as item}
      <a class="nav-item" class:active={active(item)} class:upload={item.upload} href={item.href}>
        <svelte:component this={item.icon} size={22} strokeWidth={2.4} />
        <span>{item.label}</span>
        {#if item.badge}
          <small class="nav-badge">{item.badge}</small>
        {/if}
      </a>
    {/each}
  </nav>
  {#if $authStore.authenticated}
  <a class="user-card" href={`/profile/${username}`}>
    <Avatar user={$authStore.user} size={36} />
    <span>
      <strong class="user-card-name">{$authStore.user?.display_name || username}</strong>
      <small class="user-card-handle">@{username}</small>
    </span>
  </a>
  {/if}
</aside>

<nav class="mobile-nav">
  {#each items as item}
    <a class:active={active(item)} class:upload={item.upload} href={item.href} aria-label={item.label}>
      <svelte:component this={item.icon} size={item.upload ? 25 : 22} strokeWidth={2.5} />
      {#if item.badge}
        <small class="mobile-badge">{item.badge}</small>
      {/if}
      {#if !item.upload}<span>{item.label}</span>{/if}
    </a>
  {/each}
</nav>

<style>
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    z-index: 50;
    display: none;
    width: 220px;
    height: 100vh;
    flex-direction: column;
    border-right: 1px solid rgba(255,255,255,0.06);
    background: #0a0a0a;
    padding: 24px 12px;
  }

  .logo {
    display: inline-flex;
    margin: 0 12px 32px;
    background: linear-gradient(135deg, #6366f1, #a855f7, #ec4899);
    -webkit-background-clip: text;
    background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 22px;
    font-weight: 800;
    letter-spacing: 0;
  }

  .desktop-nav {
    display: grid;
    gap: 4px;
  }

  .nav-item,
  .mobile-nav a {
    color: #737373;
    transition: all 150ms ease;
  }

  .nav-item {
    position: relative;
    display: flex;
    align-items: center;
    gap: 12px;
    border-left: 3px solid transparent;
    border-radius: 10px;
    padding: 12px 16px;
    font-size: 15px;
    font-weight: 500;
  }

  .nav-badge,
  .mobile-badge {
    display: inline-grid;
    min-width: 20px;
    height: 20px;
    place-items: center;
    border-radius: 999px;
    background: #6366f1;
    color: white;
    font-size: 11px;
    font-weight: 800;
  }

  .nav-badge {
    margin-left: auto;
  }

  .nav-item:hover {
    background: rgba(255,255,255,0.05);
    color: white;
  }

  .nav-item.active {
    border-radius: 10px;
    border-left-color: #6366f1;
    background: rgba(99,102,241,0.15);
    color: white;
  }

  .mobile-nav a.upload {
    color: white;
  }

  .user-card {
    margin-top: auto;
    display: flex;
    align-items: center;
    gap: 10px;
    border-top: 1px solid rgba(255,255,255,0.06);
    padding: 12px 16px 0;
  }

  .user-card span {
    min-width: 0;
    display: grid;
    line-height: 1.2;
  }

  .user-card-name,
  .user-card-handle {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .user-card-handle {
    color: #737373;
    font-size: 12px;
  }

  .user-card-name {
    color: white;
    font-size: 14px;
    font-weight: 600;
  }

  .mobile-nav {
    position: fixed;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 60;
    display: grid;
    grid-template-columns: repeat(5, minmax(0, 1fr));
    border-top: 1px solid rgba(255,255,255,0.08);
    background: rgba(0, 0, 0, 0.82);
    padding: 7px 8px max(7px, env(safe-area-inset-bottom));
    backdrop-filter: blur(22px);
  }

  .mobile-nav a {
    position: relative;
    display: grid;
    min-height: 48px;
    place-items: center;
    gap: 2px;
    border-radius: 8px;
    font-size: 10px;
    font-weight: 800;
  }

  .mobile-badge {
    position: absolute;
    top: 4px;
    right: 17px;
    min-width: 18px;
    height: 18px;
    font-size: 10px;
  }

  .mobile-nav a.active {
    color: white;
  }

  .mobile-nav a.upload {
    width: 46px;
    height: 38px;
    min-height: 38px;
    align-self: center;
    justify-self: center;
    background: var(--primary);
  }

  @media (min-width: 768px) {
    .sidebar {
      display: flex;
    }

    .mobile-nav {
      display: none;
    }
  }

  @media (max-width: 767px) {
    .mobile-nav {
      grid-template-columns: repeat(6, minmax(0, 1fr));
    }
  }
</style>
