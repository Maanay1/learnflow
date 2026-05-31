<script>
  import { onMount } from 'svelte';
  import { feed } from '$lib/api';
  import VideoCard from '$lib/components/VideoCard.svelte';
  import LoadingSkeleton from '$lib/components/LoadingSkeleton.svelte';
  let items = [], loading = true;
  onMount(async () => {
    try { items = (await feed.list({ limit: 20 })).items || []; }
    finally { loading = false; }
  });
</script>

<svelte:head><title>Лента | JARQ</title></svelte:head>
<section class="shell py-8">
  <header><div><p>JARQ</p><h1>Лента видео</h1></div><a href="/search">Поиск</a></header>
  {#if loading}
    <div class="grid">{#each Array(8) as _}<div class="skeleton-card"><LoadingSkeleton className="h-64 w-full"/><LoadingSkeleton className="mt-3 h-4 w-3/4"/><LoadingSkeleton className="mt-2 h-3 w-1/2"/></div>{/each}</div>
  {:else if items.length}
    <div class="grid">{#each items as video}<VideoCard {video} aspect="vertical" />{/each}</div>
  {:else}
    <div class="state"><h2>Пока нет видео. Стань первым автором!</h2><a class="upload" href="/upload">Загрузить видео</a></div>
  {/if}
</section>
<style>
  header{display:flex;align-items:end;justify-content:space-between;margin-bottom:22px}header p,header a{color:#a78bfa;font-weight:700}h1{font-size:34px;font-weight:900}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.skeleton-card{border-radius:14px;background:#111;padding:8px}@media(min-width:720px){.grid{grid-template-columns:repeat(4,minmax(0,1fr))}}.state{display:grid;min-height:360px;place-items:center;align-content:center;gap:18px;border:1px solid var(--border);border-radius:18px;background:#111;color:#a3a3a3;text-align:center}.state h2{color:white;font-size:22px;font-weight:800}.upload{border-radius:11px;background:linear-gradient(135deg,#6366f1,#a855f7);padding:12px 18px;color:white;font-weight:800}
</style>
