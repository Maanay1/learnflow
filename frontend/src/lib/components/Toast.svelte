<script>
  import { toastStore } from '$lib/stores';
</script>

<div class="fixed right-4 top-4 z-50 space-y-3">
  {#each $toastStore as toast}
    <button
      class={`block min-w-72 rounded-xl border px-4 py-3 text-left shadow-2xl ${
        toast.type === 'error'
          ? 'border-[#ef4444]/30 bg-[#ef4444]/15 text-[#f5f5f5]'
          : toast.type === 'warning'
            ? 'border-[#f59e0b]/30 bg-[#f59e0b]/15 text-[#f5f5f5]'
            : 'border-[#2e2e2e] bg-[#242424] text-[#f5f5f5]'
      }`}
      on:click={() => toastStore.removeToast(toast.id)}
    >
      {toast.message}
    </button>
  {/each}
</div>
