<script>
  import { goto } from '$app/navigation';
  import { onDestroy, onMount } from 'svelte';
  import { Bell } from 'lucide-svelte';
  import { notifications } from '$lib/api';
  import { ensureNotificationPermission, showBrowserNotification } from '$lib/browserNotifications';
  import { connectNotifications } from '$lib/socket';
  import { toastStore } from '$lib/stores';
  import Avatar from './Avatar.svelte';

  export let user;
  let open = false;
  let items = [];
  let cursor = null;
  let unread = 0;
  let cleanup = () => {};

  const important = new Set(['new_follower', 'new_video_from_followed']);

  onMount(async () => {
    await load();
    cleanup = connectNotifications(user?.id, user?.socket_token, (notification) => {
      items = [notification, ...items].slice(0, 20);
      unread += 1;
      if (important.has(notification.type)) toastStore.addToast(notification.text, 'info');
      showBrowserNotification('JARQ', { body: notification.text, data: { url: notification.video?.slug ? `/video/${notification.video.slug}` : notification.actor?.username ? `/profile/${notification.actor.username}` : '/notifications' } });
    });
  });

  onDestroy(() => cleanup?.());

  async function load() {
    const data = await notifications.list(cursor).catch(() => ({ notifications: [], unread_count: 0 }));
    items = cursor ? [...items, ...(data.notifications || [])] : data.notifications || [];
    cursor = data.next_cursor;
    unread = data.unread_count || 0;
  }

  async function markAll() {
    await notifications.markAllRead();
    unread = 0;
    items = items.map((item) => ({ ...item, read_at: item.read_at || new Date().toISOString() }));
  }
  async function toggleOpen() {
    open = !open;
    if (open) await ensureNotificationPermission();
  }

  async function openNotification(item) {
    if (!item.read_at) {
      await notifications.markRead(item.id).catch(() => {});
      unread = Math.max(0, unread - 1);
      items = items.map((n) => (n.id === item.id ? { ...n, read_at: new Date().toISOString() } : n));
    }

    open = false;
    if (item.video?.slug) goto(`/video/${item.video.slug}`);
    else if (item.course?.slug) goto(`/courses/${item.course.slug}`);
    else if (item.actor?.username) goto(`/profile/${item.actor.username}`);
    else goto('/dashboard');
  }

  function relative(value) {
    const seconds = Math.max(1, Math.round((Date.now() - new Date(value).getTime()) / 1000));
    if (seconds < 60) return `${seconds}s`;
    if (seconds < 3600) return `${Math.round(seconds / 60)}m`;
    if (seconds < 86400) return `${Math.round(seconds / 3600)}h`;
    return `${Math.round(seconds / 86400)}d`;
  }
</script>

<div class="relative">
  <button class="relative rounded-xl p-2 text-[#a3a3a3] hover:bg-[#1a1a1a]" aria-label="Notifications" on:click={toggleOpen}>
    <Bell size={20} />
    {#if unread > 0}
      <span class="absolute -right-1 -top-1 grid min-h-5 min-w-5 place-items-center rounded-full bg-[#ef4444] px-1 text-[10px] font-black text-white">{unread > 9 ? '9+' : unread}</span>
    {/if}
  </button>
  {#if open}
    <div class="absolute right-0 z-50 mt-2 w-[min(360px,calc(100vw-28px))] overflow-hidden rounded-xl border border-[var(--border)] bg-[var(--surface)] shadow-2xl">
      <div class="flex items-center justify-between border-b border-[var(--border)] p-3">
        <h2 class="font-black">Уведомления</h2>
        <button class="text-sm text-primary" on:click={markAll}>Отметить все прочитанными</button>
      </div>
      <div class="max-h-[420px] overflow-y-auto">
        {#if items.length}
          {#each items as item}
            <button class="flex w-full gap-3 border-b border-[var(--border)] p-3 text-left hover:bg-[var(--surface-2)]" on:click={() => openNotification(item)}>
              <Avatar user={item.actor} size={34} />
              <span class="min-w-0 flex-1">
                <span class="block text-sm text-[var(--text)]">{item.text}</span>
                <span class="mt-1 block text-xs text-[var(--text-3)]">{relative(item.inserted_at)}</span>
              </span>
              {#if !item.read_at}<span class="mt-2 h-2 w-2 rounded-full bg-primary"></span>{/if}
            </button>
          {/each}
          {#if cursor}<button class="w-full p-3 text-sm text-primary" on:click={load}>Загрузить ещё</button>{/if}
        {:else}
          <div class="p-6 text-center text-sm text-[var(--text-2)]">Пока нет уведомлений</div>
        {/if}
      </div>
    </div>
  {/if}
</div>
