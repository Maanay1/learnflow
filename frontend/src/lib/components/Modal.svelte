<script>
  export let open = false;
  export let title = '';
  export let onClose = () => {};
</script>

{#if open}
  <div class="fixed inset-0 z-50 grid place-items-center bg-black/70 p-4" role="button" tabindex="0" on:click={onClose} on:keydown={(e) => e.key === 'Escape' && onClose()}>
    <section class="w-full max-w-lg rounded-xl border border-[#2e2e2e] bg-[#1a1a1a] p-5" role="dialog" aria-modal="true" tabindex="-1" on:click|stopPropagation on:keydown|stopPropagation>
      <div class="mb-4 flex items-center justify-between">
        <h2 class="text-xl font-bold">{title}</h2>
        <button class="btn-secondary px-3" on:click={onClose}>×</button>
      </div>
      <slot />
    </section>
  </div>
{/if}
