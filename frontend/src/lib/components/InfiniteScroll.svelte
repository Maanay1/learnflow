<script>
  import { onDestroy, onMount } from 'svelte';
  export let hasMore = true;
  export let loading = false;
  export let onLoadMore = () => {};
  let sentinel;
  let observer;

  onMount(() => {
    observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting && hasMore && !loading) onLoadMore();
    }, { rootMargin: '400px' });
    observer.observe(sentinel);
  });

  onDestroy(() => observer?.disconnect());
</script>

<slot />
<div bind:this={sentinel} class="h-10"></div>
{#if loading}<div class="py-6 text-center text-[#a3a3a3]">Загрузка...</div>{/if}
