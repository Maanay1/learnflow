<script>
  import { BarChart3, Bell, Clapperboard, LayoutDashboard, PlaySquare, Search, Settings, User } from 'lucide-svelte';
  import { authStore } from '$lib/stores';

  $: username = $authStore.user?.username;
  $: isAdmin = $authStore.user?.is_admin;
  $: items = [
    { href: '/feed', label: 'Медиа', text: 'Все обычные видео и авторы', icon: Clapperboard },
    { href: '/jq', label: 'JQ', text: 'Короткие учебные ролики', icon: PlaySquare },
    { href: username ? `/profile/${username}` : '/login', label: 'Профиль', text: 'Публикации и данные аккаунта', icon: User },
    { href: '/settings', label: 'Настройки профиля', text: 'Фото, имя, пароль и выход', icon: Settings },
    { href: '/dashboard', label: 'Обзор обучения', text: 'История, сохранённое и курсы', icon: LayoutDashboard },
    { href: '/notifications', label: 'Уведомления', text: 'Новые события и ответы', icon: Bell },
    { href: '/search', label: 'Поиск', text: 'Видео, JQ и авторы', icon: Search },
    ...(isAdmin ? [{ href: '/admin/analytics', label: 'Аналитика', text: 'Пользователи, входы и просмотры', icon: BarChart3 }] : [])
  ];
</script>

<svelte:head><title>Ещё | JARQ</title></svelte:head>
<section class="shell max-w-xl py-7">
  <h1>Ещё</h1>
  <div class="menu">
    {#each items as item}
      <a href={item.href}>
        <span class="icon"><svelte:component this={item.icon} size={21} /></span>
        <span><strong>{item.label}</strong><small>{item.text}</small></span>
      </a>
    {/each}
  </div>
</section>

<style>
  h1{margin-bottom:18px;font-size:30px;font-weight:900}.menu{display:grid;gap:10px}.menu a{display:flex;align-items:center;gap:13px;border:1px solid var(--border);border-radius:15px;background:var(--surface);padding:14px}.icon{display:grid;width:42px;height:42px;flex:none;place-items:center;border-radius:13px;background:var(--primary-soft);color:#a9a2ff}.menu span:last-child{display:grid;gap:2px}.menu small{color:var(--text-2);font-size:12px}
</style>
