<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { authStore } from '$lib/stores';
  import { messaging } from '$lib/api';
  import { Bell, BookOpen, Home, LayoutDashboard, MessagesSquare, Plus, Search, Settings, User } from 'lucide-svelte';
  import Avatar from './Avatar.svelte';

  let unreadMessages = 0;
  let loadedUnread = false;

  $: username = $authStore.user?.username;
  $: path = $page.url.pathname;

  $: desktopItems = [
    { href: '/feed', label: 'Главная', icon: Home },
    { href: '/search', label: 'Поиск', icon: Search },
    { href: '/dashboard', label: 'Обзор', icon: LayoutDashboard },
    { divider: true },
    { href: '/messages', label: 'Чаты', icon: MessagesSquare, badge: unreadMessages },
    { href: '/notifications', label: 'Уведомления', icon: Bell },
    { divider: true },
    { href: username ? `/profile/${username}` : '/login', label: 'Профиль', icon: User, profile: true },
    { href: '/settings', label: 'Настройки', icon: Settings }
  ];

  $: mobileItems = [
    { href: '/feed', label: 'Главная', icon: Home },
    { href: '/search', label: 'Поиск', icon: Search },
    { href: '/upload', label: 'Загрузить', icon: Plus, upload: true },
    { href: '/messages', label: 'Чаты', icon: MessagesSquare, badge: unreadMessages },
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
  <a href="/feed" class="logo">JAR<span>Q</span></a>
  <nav class="desktop-nav">
    {#each desktopItems as item}
      {#if item.divider}
        <span class="divider"></span>
      {:else}
        <a class="nav-item" class:active={active(item)} href={item.href}>
          <svelte:component this={item.icon} size={20} strokeWidth={2.1} />
          <span>{item.label}</span>
          {#if item.badge}<small class="nav-badge">{item.badge}</small>{/if}
        </a>
      {/if}
    {/each}
  </nav>
  {#if $authStore.authenticated}
    <a class="user-card" href={`/profile/${username}`}>
      <Avatar user={$authStore.user} size={42} />
      <span>
        <strong>{$authStore.user?.display_name || username}</strong>
        <small>@{username}</small>
      </span>
      <BookOpen size={17} />
    </a>
  {/if}
</aside>

<nav class="mobile-nav">
  {#each mobileItems as item}
    <a class:active={active(item)} class:upload={item.upload} href={item.href} aria-label={item.label}>
      <svelte:component this={item.icon} size={item.upload ? 29 : 22} strokeWidth={item.upload ? 2.4 : 2.1} />
      {#if item.badge}<small class="mobile-badge">{item.badge}</small>{/if}
      {#if !item.upload}<span>{item.label}</span>{/if}
    </a>
  {/each}
</nav>

<style>
  .sidebar{position:fixed;inset:0 auto 0 0;z-index:50;display:none;width:248px;flex-direction:column;border-right:1px solid var(--border);background:#171719;padding:28px 16px 18px}.logo{margin:0 14px 30px;color:#f7f7f8;font-size:29px;font-weight:900;letter-spacing:-1.5px}.logo span{color:var(--primary)}.desktop-nav{display:grid;gap:4px}.divider{height:1px;margin:12px 8px;background:var(--border)}.nav-item{display:flex;align-items:center;gap:13px;border-radius:9px;padding:12px 14px;color:var(--text-2);font-size:15px;font-weight:700;transition:150ms ease}.nav-item:hover{background:rgba(255,255,255,.05);color:var(--text)}.nav-item.active{background:var(--primary-soft);color:#a9a2ff}.nav-badge,.mobile-badge{display:grid;min-width:19px;height:19px;place-items:center;border-radius:999px;background:var(--primary);color:#fff;font-size:10px;font-weight:900}.nav-badge{margin-left:auto}.user-card{display:flex;align-items:center;gap:10px;margin-top:auto;border-top:1px solid var(--border);padding:17px 5px 0;color:var(--text)}.user-card span{display:grid;min-width:0;flex:1;line-height:1.25}.user-card strong,.user-card small{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.user-card strong{font-size:14px}.user-card small{color:var(--text-3);font-size:12px}.mobile-nav{position:fixed;right:0;bottom:0;left:0;z-index:60;display:grid;grid-template-columns:repeat(5,minmax(0,1fr));border-top:1px solid var(--border);background:rgba(18,18,20,.94);padding:7px 5px max(7px,env(safe-area-inset-bottom));backdrop-filter:blur(22px)}.mobile-nav a{position:relative;display:grid;min-height:52px;place-items:center;align-content:center;gap:3px;color:var(--text-3);font-size:10px;font-weight:700;transition:150ms ease}.mobile-nav a.active{color:#a59cff}.mobile-nav a.upload{width:58px;height:58px;min-height:58px;align-self:center;justify-self:center;border-radius:19px;background:var(--primary);color:#fff;transform:translateY(-11px);box-shadow:0 8px 18px rgba(127,119,221,.28)}.mobile-nav a.upload:active{transform:translateY(-11px) scale(.94)}.mobile-badge{position:absolute;top:1px;right:18%;padding:0 4px}@media(min-width:768px){.sidebar{display:flex}.mobile-nav{display:none}}
</style>
