<script>
  import '../app.css';
  import { onMount } from 'svelte';
  import { fade } from 'svelte/transition';
  import { auth } from '$lib/api';
  import { authStore } from '$lib/stores';
  import Navbar from '$lib/components/Navbar.svelte';
  import Toast from '$lib/components/Toast.svelte';
  import UsernameSetupModal from '$lib/components/UsernameSetupModal.svelte';

  onMount(async () => {
    authStore.setLoading(true);
    try {
      const { user } = await auth.me();
      authStore.setUser(user);
    } catch {
      authStore.setUser(null);
    }
  });
</script>

<Navbar />
<Toast />
<UsernameSetupModal />
<main class="main page-fade" in:fade={{ duration: 200 }} out:fade={{ duration: 200 }}>
  <slot />
</main>
