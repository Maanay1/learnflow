<script>
  import { onMount } from 'svelte';
  import { Plus, Search } from 'lucide-svelte';
  import { feed } from '$lib/api';
  import { authStore } from '$lib/stores';
  import LoadingSkeleton from '$lib/components/LoadingSkeleton.svelte';
  import JarqLogo from '$lib/components/JarqLogo.svelte';
  import NotificationBell from '$lib/components/NotificationBell.svelte';
  import VideoCard from '$lib/components/VideoCard.svelte';

  const tabs = [
    { id: 'all', label: 'Для вас' },
    { id: 'following', label: 'Подписки' },
    { id: 'code', label: 'Программирование', match: /code|код|программ|git|javascript|python/i },
    { id: 'design', label: 'Дизайн', match: /design|дизайн|ui|ux|figma/i },
    { id: 'math', label: 'Математика', match: /math|математ|алгебр|геометр|интеграл/i }
  ];

  let items = [];
  let loading = true;
  let activeTab = 'all';

  $: active = tabs.find((tab) => tab.id === activeTab);
  $: visibleItems = active?.match
    ? items.filter((video) => active.match.test(`${video.title} ${video.tags?.map((tag) => tag.name).join(' ')}`))
    : items;

  onMount(async () => {
    try {
      items = (await feed.list({ limit: 20, format: 'media' })).items || [];
    } finally {
      loading = false;
    }
  });
</script>

<svelte:head><title>Медиа | JARQ</title></svelte:head>
<section class="feed-shell">
  <header class="topbar">
    <div class="brand">
      <p><JarqLogo /></p>
      <h1>Медиа</h1>
    </div>
    <div class="actions">
      <a class="search" href="/search"><Search size={19} /><span>Поиск видео, авторов</span></a>
      <a class="upload" href="/upload"><Plus size={19} /><span>Загрузить</span></a>
      {#if $authStore.authenticated}<NotificationBell user={$authStore.user} />{/if}
    </div>
  </header>

  <nav class="tabs" aria-label="Категории видео">
    {#each tabs as tab}
      <button class:active={activeTab === tab.id} on:click={() => (activeTab = tab.id)}>{tab.label}</button>
    {/each}
  </nav>

  {#if loading}
    <div class="grid">{#each Array(6) as _}<div class="skeleton-card"><LoadingSkeleton className="h-48 w-full"/><LoadingSkeleton className="mt-3 h-4 w-3/4"/><LoadingSkeleton className="mt-2 h-3 w-1/2"/></div>{/each}</div>
  {:else if visibleItems.length}
    <div class="grid">{#each visibleItems as video}<VideoCard {video} />{/each}</div>
  {:else}
    <div class="state"><h2>В этой категории пока нет медиа</h2><a href="/upload">Загрузить первое видео</a></div>
  {/if}
</section>

<style>
  .feed-shell{width:min(100%,1060px);margin:auto;padding:28px 20px 38px}.topbar,.actions,.search,.upload{display:flex;align-items:center}.topbar{justify-content:space-between;gap:20px}.brand p{display:none}h1{font-size:30px}.actions{gap:10px}.search{width:290px;gap:9px;border:1px solid var(--border);border-radius:12px;background:var(--surface);padding:11px 14px;color:var(--text-3);font-size:14px}.upload{gap:7px;border:1px solid var(--border);border-radius:12px;padding:11px 15px;color:var(--text);font-size:14px;font-weight:800}.tabs{display:flex;gap:4px;margin:25px 0 24px;overflow-x:auto;border-bottom:1px solid var(--border)}.tabs button{flex:none;border-bottom:2px solid transparent;padding:0 16px 13px;color:var(--text-2);font-size:14px;font-weight:800;white-space:nowrap}.tabs button.active{border-bottom-color:var(--primary);color:#9c93ff}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}.skeleton-card{border:1px solid var(--border);border-radius:18px;background:var(--surface);padding:8px}.state{display:grid;min-height:330px;place-items:center;align-content:center;gap:16px;border:1px solid var(--border);border-radius:18px;background:var(--surface);text-align:center}.state h2{font-size:20px}.state a{border-radius:999px;background:var(--primary);padding:10px 16px;color:#fff;font-weight:800}@media(max-width:767px){.feed-shell{padding:20px 14px 20px}.brand p{display:block}.brand h1{display:none}.actions{gap:4px}.search{display:grid;width:42px;height:42px;place-items:center;border-radius:999px;padding:0}.search span,.upload{display:none}.tabs{margin:17px -14px 20px;padding:0 14px}.tabs button{padding:0 14px 11px;font-size:13px}.grid{grid-template-columns:1fr;gap:15px}}@media(min-width:1200px){.grid{grid-template-columns:repeat(3,minmax(0,1fr))}}
</style>
