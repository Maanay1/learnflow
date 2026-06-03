<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { Bell, Bookmark, ClipboardCheck, MoreHorizontal, Settings } from 'lucide-svelte';
  import { messaging, social } from '$lib/api';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import FollowButton from '$lib/components/FollowButton.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import VideoCard from '$lib/components/VideoCard.svelte';
  let profile, items = [], loading = true, listOpen = false, listTitle = '', listUsers = [], profileMenuOpen = false;
  $: ownProfile = profile?.id && profile.id === $authStore.user?.id;
  $: profileItems = [
    { href: '/settings', label: 'Редактировать профиль', text: 'Фото, имя, пароль и выход', icon: Settings },
    { href: '/tests', label: 'Тесты', text: 'Созданные квизы и вход по коду', icon: ClipboardCheck },
    { href: '/dashboard', label: 'Сохранённые', text: 'История, сохранённое и курсы', icon: Bookmark },
    { href: '/notifications', label: 'Уведомления', text: 'Новые события и ответы', icon: Bell }
  ];
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
    <header>
      <Avatar user={profile} size={104}/>
      <div>
        <div class="title-row">
          <span><h1>{profile.display_name || `@${profile.username}`}</h1><p>@{profile.username}</p></span>
          {#if ownProfile}<button class="more-btn" aria-label="Ещё" on:click={() => (profileMenuOpen = true)}><MoreHorizontal size={21}/></button>{/if}
        </div>
        <p class="joined">Участник с {joined(profile.inserted_at)}</p>
        <p class="bio">{profile.bio || ''}</p>
        <div class="stats"><button on:click={() => openList('followers')}><b>{profile.followers_count || 0}</b> Подписчики</button><button on:click={() => openList('following')}><b>{profile.following_count || 0}</b> Подписки</button><span><b>{profile.videos_count || items.length}</b> Видео</span></div>
        <div class="buttons">{#if ownProfile}<a href="/settings">Редактировать профиль</a><a href="/tests">Тесты</a>{:else}<FollowButton userId={profile.id} following={profile.is_following}/><button on:click={startChat}>Написать</button>{/if}</div>
      </div>
    </header>
    {#if ownProfile}
      <section class="profile-menu" aria-label="Меню профиля">
        {#each profileItems.slice(0, 3) as item}
          <a href={item.href}><span><svelte:component this={item.icon} size={19}/></span><strong>{item.label}</strong><small>{item.text}</small></a>
        {/each}
      </section>
    {/if}
    <h2>Видео</h2>{#if items.length}<div class="grid">{#each items as video}<VideoCard {video} aspect="vertical"/>{/each}</div>{:else}<p class="empty">Ещё нет видео</p>{/if}
  {:else}<p class="empty">Профиль не найден</p>{/if}
</section>
<Modal open={profileMenuOpen} title="Ещё" onClose={() => (profileMenuOpen = false)}>
  <div class="more-menu">
    {#each profileItems as item}
      <a href={item.href} on:click={() => (profileMenuOpen = false)}>
        <span><svelte:component this={item.icon} size={20}/></span>
        <strong>{item.label}</strong>
        <small>{item.text}</small>
      </a>
    {/each}
  </div>
</Modal>
<Modal open={listOpen} title={listTitle} onClose={() => (listOpen = false)}>
  {#if listUsers.length}<div class="people">{#each listUsers as user}<article><a href={`/profile/${user.username}`}><Avatar {user} size={42}/><span><strong>{user.display_name || user.username}</strong><small>@{user.username}</small></span></a>{#if user.id !== $authStore.user?.id}<FollowButton userId={user.id} following={user.is_following}/>{/if}</article>{/each}</div>{:else}<p class="empty compact">Список пока пуст</p>{/if}
</Modal>
<style>
  header{display:flex;gap:20px;align-items:start;border-bottom:1px solid var(--border);padding-bottom:24px}.title-row{display:flex;align-items:start;gap:12px;justify-content:space-between}.title-row span{display:grid;min-width:0}h1{font-size:28px;font-weight:900}.more-btn{display:grid;width:40px;height:40px;place-items:center;border:1px solid var(--border);border-radius:50%;background:var(--surface);color:#a89fff}header p{color:var(--text-2)}.joined{font-size:13px}.bio{margin-top:12px}.stats,.buttons{display:flex;flex-wrap:wrap;gap:12px;margin-top:15px}.stats button,.stats span{color:var(--text-2);font-size:13px}.stats b{color:white}.buttons>a,.buttons>button{border:1px solid var(--border);border-radius:999px;padding:9px 16px;font-weight:700}.profile-menu{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-top:18px}.profile-menu a,.more-menu a{display:grid;gap:4px;border:1px solid var(--border);border-radius:12px;background:var(--surface);padding:14px}.profile-menu span,.more-menu span{display:grid;width:38px;height:38px;place-items:center;border-radius:12px;background:var(--primary-soft);color:#a89fff}.profile-menu strong,.more-menu strong{font-size:14px}.profile-menu small,.more-menu small{color:var(--text-2);font-size:12px}.more-menu{display:grid;gap:9px}.more-menu a{grid-template-columns:auto 1fr;align-items:center}.more-menu small{grid-column:2}h2{margin:24px 0 14px;font-size:21px;font-weight:800}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.empty{padding:70px 0;color:var(--text-2);text-align:center}.compact{padding:20px}.people{display:grid;gap:8px}.people article,.people a{display:flex;align-items:center;gap:10px}.people article{justify-content:space-between}.people span{display:grid}.people small{color:var(--text-2)}@media(min-width:720px){.grid{grid-template-columns:repeat(4,minmax(0,1fr))}}@media(max-width:560px){.shell{padding-top:24px}header{display:grid;justify-items:center;gap:12px;text-align:center}header>div{display:grid;width:100%;justify-items:center}.title-row{width:100%;align-items:center}.title-row span{flex:1}h1{font-size:27px}.bio{max-width:320px}.stats{display:grid;width:100%;grid-template-columns:repeat(3,minmax(0,1fr));gap:0;border-top:1px solid var(--border);border-bottom:1px solid var(--border);padding:12px 0}.stats button,.stats span{display:grid;gap:2px;padding:0 5px}.stats button+button,.stats span{border-left:1px solid var(--border)}.stats b{font-size:19px}.buttons{display:grid;width:100%;grid-template-columns:repeat(2,minmax(0,1fr));gap:9px}.buttons>a:only-child{grid-column:1/-1}.buttons>a,.buttons>button{display:flex;min-height:44px;align-items:center;justify-content:center;padding:9px 12px}.profile-menu{grid-template-columns:1fr}.grid{grid-template-columns:1fr;gap:14px}h2{font-size:24px}}
</style>
