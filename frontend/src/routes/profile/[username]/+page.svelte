<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { messaging, social } from '$lib/api';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import FollowButton from '$lib/components/FollowButton.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import VideoCard from '$lib/components/VideoCard.svelte';
  let profile, items = [], loading = true, listOpen = false, listTitle = '', listUsers = [];
  $: ownProfile = profile?.id && profile.id === $authStore.user?.id;
  onMount(load);
  async function load() {
    try {
      profile = (await social.profile($page.params.username)).user;
      items = (await social.profileVideos($page.params.username)).items || [];
    } finally { loading = false; }
  }
  async function startChat() { const { conversation } = await messaging.create(profile.id); goto(`/messages?conversation_id=${conversation.id}`); }
  async function openList(kind) {
    listTitle = kind === 'followers' ? 'Подписчики' : 'Подписки';
    listUsers = (await social[kind](profile.username)).users || [];
    listOpen = true;
  }
  const joined = (value) => value ? new Intl.DateTimeFormat('ru', { month: 'long', year: 'numeric' }).format(new Date(value)) : '';
</script>
<svelte:head><title>{profile?.display_name || profile?.username || 'Профиль'} | JARQ</title></svelte:head>
<section class="shell max-w-5xl py-8">
  {#if loading}<p class="empty">Загружаем профиль...</p>{:else if profile}
    <header><Avatar user={profile} size={104}/><div><h1>{profile.display_name || `@${profile.username}`}</h1><p>@{profile.username}</p><p class="joined">Участник с {joined(profile.inserted_at)}</p><p class="bio">{profile.bio || ''}</p><div class="stats"><button on:click={() => openList('followers')}><b>{profile.followers_count || 0}</b> Подписчики</button><button on:click={() => openList('following')}><b>{profile.following_count || 0}</b> Подписки</button><span><b>{profile.videos_count || items.length}</b> Видео</span></div><div class="buttons">{#if ownProfile}<a href="/settings">Редактировать профиль</a>{:else}<FollowButton userId={profile.id} following={profile.is_following}/><button on:click={startChat}>Написать</button>{/if}</div></div></header>
    <h2>Видео</h2>{#if items.length}<div class="grid">{#each items as video}<VideoCard {video} aspect="vertical"/>{/each}</div>{:else}<p class="empty">Ещё нет видео</p>{/if}
  {:else}<p class="empty">Профиль не найден</p>{/if}
</section>
<Modal open={listOpen} title={listTitle} onClose={() => (listOpen = false)}>
  {#if listUsers.length}<div class="people">{#each listUsers as user}<article><a href={`/profile/${user.username}`}><Avatar {user} size={42}/><span><strong>{user.display_name || user.username}</strong><small>@{user.username}</small></span></a>{#if user.id !== $authStore.user?.id}<FollowButton userId={user.id} following={user.is_following}/>{/if}</article>{/each}</div>{:else}<p class="empty compact">Список пока пуст</p>{/if}
</Modal>
<style>
  header{display:flex;gap:20px;align-items:start;border-bottom:1px solid var(--border);padding-bottom:24px}h1{font-size:28px;font-weight:900}header p{color:#a3a3a3}.joined{font-size:13px}.bio{margin-top:12px}.stats,.buttons{display:flex;flex-wrap:wrap;gap:12px;margin-top:15px}.stats button,.stats span{color:#a3a3a3;font-size:13px}.stats b{color:white}.buttons>a,.buttons>button{border:1px solid #3f3f46;border-radius:999px;padding:9px 16px;font-weight:700}h2{margin:24px 0 14px;font-size:21px;font-weight:800}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}@media(min-width:720px){.grid{grid-template-columns:repeat(4,minmax(0,1fr))}}.empty{padding:70px 0;color:#a3a3a3;text-align:center}.compact{padding:20px}.people{display:grid;gap:8px}.people article,.people a{display:flex;align-items:center;gap:10px}.people article{justify-content:space-between}.people span{display:grid}.people small{color:#a3a3a3}
</style>
