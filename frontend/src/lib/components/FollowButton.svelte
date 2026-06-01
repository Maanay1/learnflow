<script>
  import { goto } from '$app/navigation';
  import { social } from '$lib/api';
  import { authStore, toastStore } from '$lib/stores';
  export let userId;
  export let following = false;
  let loading = false;

  async function toggle() {
    if (loading) return;
    if (!$authStore.authenticated) {
      goto('/login');
      return;
    }

    loading = true;
    const next = !following;
    following = next;
    try {
      next ? await social.follow(userId) : await social.unfollow(userId);
    } catch (error) {
      following = !next;
      toastStore.addToast('Не удалось обновить подписку', 'error');
    } finally {
      loading = false;
    }
  }
</script>

<button class={`${following ? 'btn-secondary' : 'btn'} min-w-32 transition-all duration-150 ease-in-out`} disabled={loading} on:click={toggle} aria-label={following ? 'Unfollow user' : 'Follow user'}>
  {following ? 'Вы подписаны' : 'Подписаться'}
</button>
