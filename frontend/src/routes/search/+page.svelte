<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { Search } from 'lucide-svelte';
  import { feed, search } from '$lib/api';
  import VideoCard from '$lib/components/VideoCard.svelte';
  let q = '', results = [], loading = true, timer;
  onMount(() => { q = $page.url.searchParams.get('q') || ''; load(); });
  $: { q; clearTimeout(timer); timer = setTimeout(load, 250); }
  async function load() {
    loading = true;
    try { results = q.trim() ? (await search.videos({ q })).items || [] : (await feed.list({ limit: 20 })).items || []; }
    catch { results = []; }
    finally { loading = false; }
  }
</script>
<svelte:head><title>Поиск | LearnFlow</title></svelte:head>
<section class="shell py-8">
  <label><Search size={20}/><input bind:value={q} placeholder="Найди свой следующий урок..." /></label>
  {#if loading}<p class="empty">Поиск...</p>{:else if results.length}<div class="grid">{#each results as video}<VideoCard {video} aspect="square" />{/each}</div>{:else}<p class="empty">Ничего не найдено</p>{/if}
</section>
<style>
  label{display:flex;height:52px;align-items:center;gap:10px;border:1px solid #2e2e2e;border-radius:999px;background:#1c1c1c;padding:0 16px;color:#737373}input{min-width:0;flex:1;background:transparent;color:white;outline:none}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;margin-top:20px}@media(min-width:720px){.grid{grid-template-columns:repeat(4,minmax(0,1fr))}}.empty{padding:90px 0;color:#a3a3a3;text-align:center}
</style>
