<script>
  import { onDestroy, onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { Search, Send } from 'lucide-svelte';
  import { messaging, videos } from '$lib/api';
  import { connectConversation } from '$lib/socket';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';

  let conversations = [], messagesByConversation = {}, activeId = '', query = '', draft = '';
  let channel, loading = true, pendingSharedVideo, error = '';
  $: currentUser = $authStore.user;
  $: activeConversation = conversations.find((item) => item.id === activeId);
  $: activeMessages = messagesByConversation[activeId] || [];
  $: filtered = conversations.filter((item) => item.name?.toLowerCase().includes(query.toLowerCase()));
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');

  onMount(async () => {
    try {
      const sharedSlug = $page.url.searchParams.get('share_video');
      if (sharedSlug) pendingSharedVideo = (await videos.detail(sharedSlug)).video;
      conversations = (await messaging.conversations()).conversations || [];
      const requested = $page.url.searchParams.get('conversation_id') || $page.url.searchParams.get('conversation');
      if (conversations.length) await openConversation(conversations.some((item) => item.id === requested) ? requested : conversations[0].id);
    } catch (requestError) {
      if (requestError.status !== 401) error = 'Не удалось загрузить сообщения';
    } finally { loading = false; }
  });
  onDestroy(() => channel?.disconnect?.());

  async function openConversation(id) {
    activeId = id;
    channel?.disconnect?.();
    messagesByConversation = { ...messagesByConversation, [id]: (await messaging.messages(id)).messages || [] };
    await messaging.read(id).catch(() => {});
    conversations = conversations.map((item) => item.id === id ? { ...item, unread_count: 0 } : item);
    channel = connectConversation(id, {
      onMessage(message) {
        const list = messagesByConversation[id] || [];
        if (!list.some((item) => item.id === message.id)) messagesByConversation = { ...messagesByConversation, [id]: [...list, message] };
      }
    }, currentUser?.socket_token);
  }

  async function send() {
    const body = draft.trim();
    if (!activeId || (!body && !pendingSharedVideo)) return;
    draft = '';
    const optimistic = { id: `local-${Date.now()}`, sender_id: currentUser.id, sender: currentUser, body, shared_video: pendingSharedVideo, inserted_at: new Date().toISOString() };
    messagesByConversation = { ...messagesByConversation, [activeId]: [...activeMessages, optimistic] };
    try {
      const payload = pendingSharedVideo ? { body, shared_video_id: pendingSharedVideo.id } : { body };
      pendingSharedVideo = null;
      const { message } = await messaging.send(activeId, payload);
      const list = (messagesByConversation[activeId] || []).filter((item) => item.id !== message.id);
      messagesByConversation = { ...messagesByConversation, [activeId]: list.map((item) => item.id === optimistic.id ? message : item) };
      conversations = conversations.map((item) => item.id === activeId ? { ...item, last_message: message } : item);
    } catch {
      messagesByConversation = { ...messagesByConversation, [activeId]: activeMessages };
      error = 'Не удалось отправить сообщение';
    }
  }

  function conversationUser(conversation) {
    if (!conversation) return {};
    if (conversation.type === 'group') return { display_name: conversation.name, avatar_key: conversation.avatar_key };
    return conversation.members?.find((member) => member.user_id !== currentUser?.id)?.user || { display_name: conversation.name };
  }
  const time = (value) => value ? new Intl.DateTimeFormat('ru', { hour: '2-digit', minute: '2-digit' }).format(new Date(value)) : '';
</script>

<svelte:head><title>Сообщения | LearnFlow</title></svelte:head>
<section class="page">
  <aside>
    <h1>Сообщения</h1>
    <label><Search size={18}/><input bind:value={query} placeholder="Поиск чатов" /></label>
    {#if loading}<p class="empty">Загружаем...</p>{:else if filtered.length}
      {#each filtered as conversation}<button class:active={conversation.id === activeId} class="conversation" on:click={() => openConversation(conversation.id)}><Avatar user={conversationUser(conversation)} size={44}/><span><strong>{conversation.name}</strong><small>{conversation.last_message?.body || 'Нет сообщений'}</small></span>{#if conversation.unread_count}<b>{conversation.unread_count}</b>{/if}</button>{/each}
    {:else}<div class="empty"><p>Пока нет сообщений.<br/>Найди кого-нибудь и напиши им!</p><a href="/search">Найти пользователя</a></div>{/if}
  </aside>
  <main>
    {#if activeConversation}
      <header><Avatar user={conversationUser(activeConversation)} size={42}/><strong>{activeConversation.name}</strong></header>
      <div class="list">{#if activeMessages.length}{#each activeMessages as message}<article class:own={message.sender_id === currentUser?.id}>{#if message.sender_id !== currentUser?.id}<Avatar user={message.sender} size={30}/>{/if}<div>{#if message.shared_video}<a class="shared" href={`/video/${message.shared_video.slug}`}>{message.shared_video.title}</a>{/if}{#if message.body}<p>{message.body}</p>{/if}<small>{time(message.inserted_at)}</small></div></article>{/each}{:else}<p class="empty">Нет сообщений</p>{/if}</div>
      {#if pendingSharedVideo}<div class="pending">Видео: {pendingSharedVideo.title}<button on:click={() => (pendingSharedVideo = null)}>Убрать</button></div>{/if}
      {#if error}<p class="error">{error}</p>{/if}
      <form on:submit|preventDefault={send}><input bind:value={draft} placeholder="Написать сообщение..." /><button aria-label="Отправить"><Send size={20}/></button></form>
    {:else}<div class="empty center">Выбери чат, чтобы начать общение</div>{/if}
  </main>
</section>
<style>
  :global(main.main){padding-left:0}.page{display:grid;height:100vh;grid-template-columns:320px minmax(0,1fr);background:#000}aside{overflow:auto;border-right:1px solid var(--border);background:#0a0a0a;padding:16px}h1{margin-bottom:14px;font-size:26px;font-weight:900}label,form{display:flex;align-items:center;gap:9px;border:1px solid #2e2e2e;border-radius:999px;background:#111;padding:0 13px;color:#737373}label{height:44px;margin-bottom:12px}input{min-width:0;flex:1;background:transparent;color:white;outline:0}.conversation{display:grid;width:100%;grid-template-columns:auto minmax(0,1fr) auto;gap:10px;align-items:center;border-radius:12px;padding:10px;text-align:left}.conversation.active,.conversation:hover{background:rgba(99,102,241,.16)}.conversation span{display:grid;gap:3px;min-width:0}.conversation small{overflow:hidden;color:#a3a3a3;text-overflow:ellipsis;white-space:nowrap}.conversation b{display:grid;width:22px;height:22px;place-items:center;border-radius:99px;background:#6366f1;font-size:11px}main{display:grid;min-width:0;grid-template-rows:auto minmax(0,1fr) auto auto auto}header{display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--border);padding:14px 18px}.list{display:flex;overflow:auto;flex-direction:column;gap:10px;padding:18px}article{display:flex;max-width:70%;gap:8px;align-items:end}article.own{align-self:end}article>div{border-radius:16px 16px 16px 4px;background:#1c1c1c;padding:10px 12px}.own>div{border-radius:16px 16px 4px 16px;background:#6366f1}article small{display:block;margin-top:4px;color:#d4d4d4;font-size:11px;text-align:right}.shared{display:block;margin-bottom:5px;color:#ddd6fe;font-weight:800}.pending,.error{padding:8px 18px;color:#a3a3a3}.pending button{margin-left:10px;color:#a78bfa}.error{color:#f87171}form{height:48px;margin:12px 18px}form button{color:#a78bfa}.empty{padding:30px 6px;color:#a3a3a3;text-align:center}.empty a{display:inline-block;margin-top:12px;color:#a78bfa;font-weight:700}.center{place-self:center}@media(max-width:700px){.page{grid-template-columns:130px minmax(0,1fr)}aside{padding:9px}h1{font-size:18px}.conversation{grid-template-columns:auto}.conversation span,.conversation b{display:none}label svg{display:none}}
</style>
