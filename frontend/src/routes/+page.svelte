<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  onMount(() => goto('/jq'));
</script>

<section class="grid min-h-screen place-items-center bg-black">
  <div class="skeleton h-48 w-80 rounded-lg"></div>
</section>
