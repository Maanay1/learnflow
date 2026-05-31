<script>
  import { onDestroy, onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { Search, Send, UserPlus, UsersRound } from 'lucide-svelte';
  import { messaging, search, videos } from '$lib/api';
  import { connectConversation } from '$lib/socket';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import Modal from '$lib/components/Modal.svelte';

  let conversations = [], messagesByConversation = {}, activeId = '', query = '', draft = '', channel;
  let loading = true, pendingSharedVideo, error = '', typingName = '', typingTimer, sendTypingTimer;
  let onlineIds = new Set(), findOpen = false, groupOpen = false, userQuery = '', userResults = [], groupName = '', selected = [], searchTimer;
  $: currentUser = $authStore.user;
  $: activeConversation = conversations.find((item) => item.id === activeId);
  $: activeMessages = messagesByConversation[activeId] || [];
  $: filtered = conversations.filter((item) => item.name?.toLowerCase().includes(query.toLowerCase()));
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');
  $: { userQuery; clearTimeout(searchTimer); searchTimer = setTimeout(findUsers, 350); }

  onMount(async () => {
    try {
      const sharedSlug = $page.url.searchParams.get('share_video');
      if (sharedSlug) pendingSharedVideo = (await videos.detail(sharedSlug)).video;
      conversations = (await messaging.conversations()).conversations || [];
      const requested = $page.url.searchParams.get('conversation_id') || $page.url.searchParams.get('conversation');
      if (conversations.length) await openConversation(conversations.some((item) => item.id === requested) ? requested : conversations[0].id);
    } catch (requestError) { if (requestError.status !== 401) error = 'Не удалось загрузить сообщения'; }
    finally { loading = false; }
  });
  onDestroy(() => channel?.disconnect?.());

  async function findUsers() {
    if (!userQuery.trim()) return userResults = [];
    try { userResults = (await search.users(userQuery)).users?.filter((user) => user.id !== currentUser?.id) || []; }
    catch { userResults = []; }
  }
  async function openConversation(id) {
    activeId = id;
    typingName = '';
    channel?.disconnect?.();
    messagesByConversation = { ...messagesByConversation, [id]: (await messaging.messages(id)).messages || [] };
    await messaging.read(id).catch(() => {});
    conversations = conversations.map((item) => item.id === id ? { ...item, unread_count: 0 } : item);
    channel = connectConversation(id, {
      onJoin(payload) { onlineIds = new Set(payload.online_user_ids || []); },
      onPresence(payload) {
        const next = new Set(onlineIds);
        payload.online ? next.add(payload.user_id) : next.delete(payload.user_id);
        onlineIds = next;
      },
      onTyping(payload) {
        if (payload.user?.id === currentUser?.id) return;
        typingName = payload.is_typing ? (payload.user.display_name || payload.user.username) : '';
        clearTimeout(typingTimer);
        if (typingName) typingTimer = setTimeout(() => (typingName = ''), 1800);
      },
      onRead(payload) {
        conversations = conversations.map((item) => item.id === id ? { ...item, members: item.members.map((member) => member.user_id === payload.user_id ? { ...member, last_read_at: payload.last_read_at } : member) } : item);
      },
      onMessage(message) {
        const list = messagesByConversation[id] || [];
        if (!list.some((item) => item.id === message.id)) messagesByConversation = { ...messagesByConversation, [id]: [...list, message] };
        if (message.sender_id !== currentUser?.id) channel?.read?.();
      }
    }, currentUser?.socket_token);
  }
  async function send() {
    const body = draft.trim();
    if (!activeId || (!body && !pendingSharedVideo)) return;
    draft = '';
    channel?.typing(false);
    const optimistic = { id: `local-${Date.now()}`, sender_id: currentUser.id, sender: currentUser, body, shared_video: pendingSharedVideo, inserted_at: new Date().toISOString() };
    messagesByConversation = { ...messagesByConversation, [activeId]: [...activeMessages, optimistic] };
    try {
      const payload = pendingSharedVideo ? { body, shared_video_id: pendingSharedVideo.id } : { body };
      pendingSharedVideo = null;
      const { message } = await messaging.send(activeId, payload);
      messagesByConversation = { ...messagesByConversation, [activeId]: (messagesByConversation[activeId] || []).map((item) => item.id === optimistic.id ? message : item) };
      conversations = conversations.map((item) => item.id === activeId ? { ...item, last_message: message } : item);
    } catch { messagesByConversation = { ...messagesByConversation, [activeId]: activeMessages }; error = 'Не удалось отправить сообщение'; }
  }
  function typing() {
    channel?.typing(true);
    clearTimeout(sendTypingTimer);
    sendTypingTimer = setTimeout(() => channel?.typing(false), 900);
  }
  async function startDirect(user) {
    const { conversation } = await messaging.create(user.id);
    if (!conversations.some((item) => item.id === conversation.id)) conversations = [conversation, ...conversations];
    findOpen = false; userQuery = ''; userResults = [];
    await openConversation(conversation.id);
  }
  function toggleSelected(user) { selected = selected.some((item) => item.id === user.id) ? selected.filter((item) => item.id !== user.id) : [...selected, user]; }
  async function createGroup() {
    if (!groupName.trim() || !selected.length) return;
    const { conversation } = await messaging.createGroup({ name: groupName.trim(), member_ids: selected.map((user) => user.id) });
    conversations = [conversation, ...conversations];
    groupOpen = false; groupName = ''; selected = []; userQuery = ''; userResults = [];
    await openConversation(conversation.id);
  }
  function conversationUser(conversation) {
    if (!conversation) return {};
    if (conversation.type === 'group') return { display_name: conversation.name, avatar_key: conversation.avatar_key };
    return conversation.members?.find((member) => member.user_id !== currentUser?.id)?.user || { display_name: conversation.name };
  }
  function isOnline(conversation) { return conversation?.members?.some((member) => member.user_id !== currentUser?.id && onlineIds.has(member.user_id)); }
  function wasRead(message) { return activeConversation?.members?.some((member) => member.user_id !== currentUser?.id && member.last_read_at && new Date(member.last_read_at) >= new Date(message.inserted_at)); }
  const time = (value) => value ? new Intl.DateTimeFormat('ru', { hour: '2-digit', minute: '2-digit' }).format(new Date(value)) : '';
</script>

<svelte:head><title>Сообщения | JARQ</title></svelte:head>
<section class="page">
  <aside>
    <div class="aside-head"><h1>Сообщения</h1><button title="Найти пользователя" on:click={() => (findOpen = true)}><UserPlus size={19}/></button><button title="Создать группу" on:click={() => (groupOpen = true)}><UsersRound size={19}/></button></div>
    <label class="search"><Search size={18}/><input bind:value={query} placeholder="Поиск чатов" /></label>
    {#if loading}<p class="empty">Загружаем...</p>{:else if filtered.length}
      {#each filtered as conversation}<button class:active={conversation.id === activeId} class="conversation" on:click={() => openConversation(conversation.id)}><span class="avatar-wrap"><Avatar user={conversationUser(conversation)} size={44}/>{#if conversation.id === activeId && isOnline(conversation)}<i></i>{/if}</span><span><strong>{conversation.name}</strong><small>{conversation.last_message?.body || 'Нет сообщений'}</small></span>{#if conversation.unread_count}<b>{conversation.unread_count}</b>{/if}</button>{/each}
    {:else}<div class="empty"><p>Пока нет сообщений.<br/>Найди кого-нибудь и напиши им!</p><button class="link" on:click={() => (findOpen = true)}>Найти пользователя</button></div>{/if}
  </aside>
  <main>
    {#if activeConversation}
      <header><span class="avatar-wrap"><Avatar user={conversationUser(activeConversation)} size={42}/>{#if isOnline(activeConversation)}<i></i>{/if}</span><span><strong>{activeConversation.name}</strong>{#if typingName}<small>{typingName} печатает...</small>{:else if isOnline(activeConversation)}<small>онлайн</small>{/if}</span></header>
      <div class="list">{#if activeMessages.length}{#each activeMessages as message}<article class:own={message.sender_id === currentUser?.id}>{#if message.sender_id !== currentUser?.id}<Avatar user={message.sender} size={30}/>{/if}<div>{#if message.shared_video}<a class="shared" href={`/video/${message.shared_video.slug}`}>{message.shared_video.title}</a>{/if}{#if message.body}<p>{message.body}</p>{/if}<small>{time(message.inserted_at)} {#if message.sender_id === currentUser?.id}<b>{wasRead(message) ? '✓✓' : '✓'}</b>{/if}</small></div></article>{/each}{:else}<p class="empty">Нет сообщений</p>{/if}</div>
      {#if pendingSharedVideo}<div class="pending">Видео: {pendingSharedVideo.title}<button on:click={() => (pendingSharedVideo = null)}>Убрать</button></div>{/if}
      {#if error}<p class="error">{error}</p>{/if}
      <form on:submit|preventDefault={send}><input bind:value={draft} on:input={typing} placeholder="Написать сообщение..." /><button aria-label="Отправить"><Send size={20}/></button></form>
    {:else}<div class="empty center">Выбери чат, чтобы начать общение</div>{/if}
  </main>
</section>
<Modal open={findOpen} title="Найти пользователя" onClose={() => (findOpen = false)}>
  <label class="search"><Search size={18}/><input bind:value={userQuery} placeholder="Username или имя" /></label>
  <div class="users">{#each userResults as user}<button on:click={() => startDirect(user)}><Avatar {user} size={42}/><span><strong>{user.display_name || user.username}</strong><small>@{user.username}</small></span></button>{/each}</div>
</Modal>
<Modal open={groupOpen} title="Создать группу" onClose={() => (groupOpen = false)}>
  <input class="group-name" bind:value={groupName} maxlength="100" placeholder="Название группы" />
  <label class="search"><Search size={18}/><input bind:value={userQuery} placeholder="Добавить участников" /></label>
  <div class="selected">{#each selected as user}<button on:click={() => toggleSelected(user)}>@{user.username} ×</button>{/each}</div>
  <div class="users">{#each userResults as user}<button class:selected-user={selected.some((item) => item.id === user.id)} on:click={() => toggleSelected(user)}><Avatar {user} size={38}/><span><strong>{user.display_name || user.username}</strong><small>@{user.username}</small></span></button>{/each}</div>
  <button class="create" disabled={!groupName.trim() || !selected.length} on:click={createGroup}>Создать группу</button>
</Modal>
<style>
  :global(main.main){padding-left:0}.page{display:grid;height:100vh;grid-template-columns:320px minmax(0,1fr);background:#000}aside{overflow:auto;border-right:1px solid var(--border);background:#0a0a0a;padding:16px}.aside-head{display:flex;align-items:center;gap:8px;margin-bottom:14px}.aside-head h1{margin-right:auto;font-size:26px;font-weight:900}.aside-head button{color:#a78bfa}.search,form{display:flex;align-items:center;gap:9px;border:1px solid #2e2e2e;border-radius:999px;background:#111;padding:0 13px;color:#737373}.search{height:44px;margin-bottom:12px}.search input,form input{min-width:0;flex:1;background:transparent;color:white;outline:0}.conversation{display:grid;width:100%;grid-template-columns:auto minmax(0,1fr) auto;gap:10px;align-items:center;border-radius:12px;padding:10px;text-align:left}.conversation.active,.conversation:hover{background:rgba(99,102,241,.16)}.conversation>span:not(.avatar-wrap),header>span{display:grid;gap:3px;min-width:0}.conversation small,header small{overflow:hidden;color:#a3a3a3;text-overflow:ellipsis;white-space:nowrap}.conversation>b{display:grid;width:22px;height:22px;place-items:center;border-radius:99px;background:#6366f1;font-size:11px}.avatar-wrap{position:relative;display:inline-flex}.avatar-wrap i{position:absolute;right:0;bottom:1px;width:11px;height:11px;border:2px solid #111;border-radius:50%;background:#22c55e}main{display:grid;min-width:0;grid-template-rows:auto minmax(0,1fr) auto auto auto}header{display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--border);padding:14px 18px}.list{display:flex;overflow:auto;flex-direction:column;gap:10px;padding:18px}article{display:flex;max-width:70%;gap:8px;align-items:end}article.own{align-self:end}article>div{border-radius:16px 16px 16px 4px;background:#1c1c1c;padding:10px 12px}.own>div{border-radius:16px 16px 4px 16px;background:#6366f1}article small{display:block;margin-top:4px;color:#d4d4d4;font-size:11px;text-align:right}article small b{color:#bfdbfe}.shared{display:block;margin-bottom:5px;color:#ddd6fe;font-weight:800}.pending,.error{padding:8px 18px;color:#a3a3a3}.pending button,.link{margin-left:10px;color:#a78bfa}.error{color:#f87171}form{height:48px;margin:12px 18px}form button{color:#a78bfa}.empty{padding:30px 6px;color:#a3a3a3;text-align:center}.center{place-self:center}.users{display:grid;max-height:300px;gap:5px;overflow:auto}.users button{display:flex;align-items:center;gap:10px;border-radius:10px;padding:8px;text-align:left}.users button:hover,.selected-user{background:#27272a}.users span{display:grid}.users small{color:#a3a3a3}.group-name{width:100%;margin-bottom:10px;border:1px solid #333;border-radius:10px;background:#111;padding:11px;color:white}.selected{display:flex;flex-wrap:wrap;gap:5px;margin-bottom:8px}.selected button{border-radius:99px;background:#312e81;padding:5px 9px;font-size:12px}.create{width:100%;margin-top:12px;border-radius:10px;background:var(--accent);padding:11px;font-weight:800}.create:disabled{opacity:.4}@media(max-width:700px){.page{grid-template-columns:130px minmax(0,1fr)}aside{padding:9px}.aside-head h1{font-size:17px}.conversation{grid-template-columns:auto}.conversation>span:not(.avatar-wrap),.conversation>b{display:none}}
</style>
