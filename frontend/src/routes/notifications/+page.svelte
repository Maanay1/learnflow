<script>
  import { onMount } from 'svelte';
  import { notifications } from '$lib/api';
  import Avatar from '$lib/components/Avatar.svelte';
  let items = [], loading = true;
  onMount(async () => {
    try { items = (await notifications.list()).notifications || []; }
    catch { items = []; }
    finally { loading = false; }
  });
  const time = (value) => value ? new Intl.DateTimeFormat('ru', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(value)) : '';
</script>
<svelte:head><title>Уведомления | LearnFlow</title></svelte:head>
<section class="shell max-w-3xl py-8"><h1>Уведомления</h1>
  {#if loading}<p class="empty">Загружаем...</p>{:else if items.length}<div>{#each items as item}<article class:unread={!item.read_at}><Avatar user={item.actor} size={42}/><span><strong>{item.text}</strong><small>{time(item.inserted_at)}</small></span></article>{/each}</div>{:else}<p class="empty">Нет уведомлений</p>{/if}
</section>
<style>
  h1{font-size:34px;font-weight:900}article{display:flex;gap:12px;border-bottom:1px solid var(--border);padding:15px 4px}article.unread{border-left:3px solid #6366f1;padding-left:10px}span{display:grid;gap:4px}small,.empty{color:#a3a3a3}.empty{padding:90px 0;text-align:center}
</style>
