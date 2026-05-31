<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { Search } from 'lucide-svelte';
  import { feed, search } from '$lib/api';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import FollowButton from '$lib/components/FollowButton.svelte';
  import VideoCard from '$lib/components/VideoCard.svelte';
  let q = '', videos = [], users = [], loading = true, timer, tab = 'videos';
  onMount(() => { q = $page.url.searchParams.get('q') || ''; load(); });
  $: { q; clearTimeout(timer); timer = setTimeout(load, 300); }
  async function load() {
    loading = true;
    try {
      const [videoData, userData] = await Promise.all([
        q.trim() ? search.videos({ q }) : feed.list({ limit: 20 }),
        q.trim() ? search.users(q) : Promise.resolve({ users: [] })
      ]);
      videos = videoData.items || [];
      users = userData.users || [];
    } catch { videos = []; users = []; }
    finally { loading = false; }
  }
</script>
<svelte:head><title>Поиск | JARQ</title></svelte:head>
<section class="shell py-8">
  <label class="search"><Search size={20}/><input bind:value={q} placeholder="Найди видео или пользователя..." /></label>
  <nav><button class:active={tab === 'videos'} on:click={() => (tab = 'videos')}>Видео <span>{videos.length}</span></button><button class:active={tab === 'people'} on:click={() => (tab = 'people')}>Люди <span>{users.length}</span></button></nav>
  {#if loading}<p class="empty">Поиск...</p>
  {:else if tab === 'videos'}
    {#if videos.length}<div class="grid">{#each videos as video}<VideoCard {video} aspect="square" />{/each}</div>{:else}<p class="empty">Ничего не найдено</p>{/if}
  {:else}
    {#if users.length}<div class="people">{#each users as user}<article><a href={`/profile/${user.username}`}><Avatar {user} size={52}/><span><strong>{user.display_name || user.username}</strong><small>@{user.username}</small><small>{user.videos_count} видео · {user.followers_count} подписчиков</small></span></a>{#if user.id !== $authStore.user?.id}<FollowButton userId={user.id} following={user.is_following}/>{/if}</article>{/each}</div>{:else}<p class="empty">Ничего не найдено</p>{/if}
  {/if}
</section>
<style>
  .search{display:flex;height:52px;align-items:center;gap:10px;border:1px solid #2e2e2e;border-radius:999px;background:#1c1c1c;padding:0 16px;color:#737373}.search input{min-width:0;flex:1;background:transparent;color:white;outline:none}nav{display:flex;gap:8px;margin:18px 0}nav button{border-radius:999px;padding:9px 16px;color:#a3a3a3;font-weight:800}nav button.active{background:#27272a;color:white}nav span{color:#a78bfa}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}@media(min-width:720px){.grid{grid-template-columns:repeat(4,minmax(0,1fr))}}.people{display:grid;gap:8px}.people article,.people a{display:flex;align-items:center;gap:12px}.people article{justify-content:space-between;border:1px solid var(--border);border-radius:14px;background:#111;padding:12px}.people span{display:grid}.people small{color:#a3a3a3}.empty{padding:90px 0;color:#a3a3a3;text-align:center}
</style>
