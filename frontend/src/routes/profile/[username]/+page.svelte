<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { messaging, social } from '$lib/api';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import VideoCard from '$lib/components/VideoCard.svelte';
  let profile, items = [], loading = true, followed = false;
  $: ownProfile = profile?.id && profile.id === $authStore.user?.id;
  onMount(async () => {
    try {
      profile = (await social.profile($page.params.username)).user;
      items = (await social.profileVideos($page.params.username)).items || [];
    } finally { loading = false; }
  });
  async function toggleFollow() { followed = !followed; await (followed ? social.follow(profile.id) : social.unfollow(profile.id)).catch(() => (followed = !followed)); }
  async function startChat() { const { conversation } = await messaging.create(profile.id); goto(`/messages?conversation_id=${conversation.id}`); }
</script>
<svelte:head><title>{profile?.display_name || profile?.username || 'Профиль'} | LearnFlow</title></svelte:head>
<section class="shell max-w-5xl py-8">
  {#if loading}<p class="empty">Загружаем профиль...</p>{:else if profile}
    <header><Avatar user={profile} size={104}/><div><h1>{profile.display_name || `@${profile.username}`}</h1><p>@{profile.username}</p><p class="bio">{profile.bio || ''}</p><div class="buttons">{#if !ownProfile}<button class="primary" on:click={toggleFollow}>{followed ? 'Подписан' : 'Подписаться'}</button><button on:click={startChat}>Написать</button>{/if}</div></div></header>
    <h2>Видео</h2>{#if items.length}<div class="grid">{#each items as video}<VideoCard {video} aspect="vertical"/>{/each}</div>{:else}<p class="empty">Ещё нет видео</p>{/if}
  {:else}<p class="empty">Профиль не найден</p>{/if}
</section>
<style>
  header{display:flex;gap:20px;align-items:start;border-bottom:1px solid var(--border);padding-bottom:24px}h1{font-size:28px;font-weight:900}header p{color:#a3a3a3}.bio{margin-top:12px}.buttons{display:flex;gap:10px;margin-top:16px}.buttons button{border:1px solid #3f3f46;border-radius:999px;padding:9px 16px;font-weight:700}.buttons .primary{border:0;background:linear-gradient(135deg,#6366f1,#a855f7)}h2{margin:24px 0 14px;font-size:21px;font-weight:800}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}@media(min-width:720px){.grid{grid-template-columns:repeat(4,minmax(0,1fr))}}.empty{padding:70px 0;color:#a3a3a3;text-align:center}
</style>
