<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { Bookmark, Clapperboard, Heart, MessageCircle, Plus, Send, Share2, Volume2, VolumeX, X } from 'lucide-svelte';
  import { feed, social, videos } from '$lib/api';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import JarqLogo from '$lib/components/JarqLogo.svelte';

  let reels = [], loading = true, muted = true, commentsOpen = false, commentVideo, comments = [], commentText = '';

  onMount(async () => {
    try {
      const items = (await feed.list({ limit: 20, format: 'jq' })).items || [];
      reels = await Promise.all(items.map(async (item) => {
        try { return (await videos.detail(item.slug)).video; }
        catch { return item; }
      }));
    } finally {
      loading = false;
    }
  });

  function observeVideo(node) {
    const observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting && entry.intersectionRatio > .7) node.play().catch(() => {});
      else node.pause();
    }, { threshold: [.7] });
    observer.observe(node);
    return { destroy: () => observer.disconnect() };
  }

  function requireLogin() {
    if ($authStore.authenticated) return true;
    goto('/login');
    return false;
  }

  async function like(video) {
    if (!requireLogin()) return;
    video.is_liked = !video.is_liked;
    video.like_count = Math.max(0, Number(video.like_count || 0) + (video.is_liked ? 1 : -1));
    reels = reels;
    try {
      const result = await (video.is_liked ? social.like(video.id) : social.unlike(video.id));
      video.like_count = result.like_count;
    } catch {
      video.is_liked = !video.is_liked;
      video.like_count = Math.max(0, Number(video.like_count || 0) + (video.is_liked ? 1 : -1));
    }
    reels = reels;
  }

  async function save(video) {
    if (!requireLogin()) return;
    video.is_saved = !video.is_saved;
    reels = reels;
    try { await (video.is_saved ? social.save(video.id) : social.unsave(video.id)); }
    catch { video.is_saved = !video.is_saved; reels = reels; }
  }

  async function openComments(video) {
    commentVideo = video;
    commentsOpen = true;
    comments = (await social.comments(video.id).catch(() => ({ comments: [] }))).comments || [];
  }

  async function sendComment() {
    if (!requireLogin()) return;
    const body = commentText.trim();
    if (!body) return;
    const result = await social.comment(commentVideo.id, body).catch(() => null);
    if (!result?.comment) return;
    comments = [result.comment, ...comments];
    commentVideo.comment_count = Number(commentVideo.comment_count || 0) + 1;
    reels = reels;
    commentText = '';
  }
</script>

<svelte:head><title>JQ | JARQ</title></svelte:head>
<section class="jq-page">
  <header class="mobile-head"><a href="/feed"><JarqLogo /></a><span><a class="media-link" href="/feed"><Clapperboard size={18} /> Медиа</a><a class="add" href="/upload"><Plus size={19} /> Создать JQ</a></span></header>
  {#if loading}
    <div class="state">Загружаем JQ...</div>
  {:else if reels.length}
    <div class="reels">
      {#each reels as video}
        <article class="reel">
          <video use:observeVideo src={video.view_url || video.video_key} poster={video.thumbnail_url || ''} playsinline loop {muted}></video>
          <div class="shade"></div>
          <button class="sound" on:click={() => (muted = !muted)} aria-label={muted ? 'Включить звук' : 'Выключить звук'}>
            {#if muted}<VolumeX size={19} />{:else}<Volume2 size={19} />{/if}
          </button>
          <div class="caption">
            <a class="creator" href={`/profile/${video.creator?.username || ''}`}><Avatar user={video.creator} size={38}/><strong>@{video.creator?.username || 'author'}</strong></a>
            <h1>{video.title}</h1>
            {#if video.description}<p>{video.description}</p>{/if}
            <small>JQ · учись за {Math.max(1, Math.ceil((video.duration_seconds || 0) / 60))} мин</small>
          </div>
          <aside class="rail">
            <button class:active={video.is_liked} on:click={() => like(video)}><Heart size={25} fill={video.is_liked ? 'currentColor' : 'none'} /><b>{video.like_count || 0}</b></button>
            <button on:click={() => openComments(video)}><MessageCircle size={25} /><b>{video.comment_count || 0}</b></button>
            <button class:active={video.is_saved} on:click={() => save(video)}><Bookmark size={25} fill={video.is_saved ? 'currentColor' : 'none'} /><b>Сохранить</b></button>
            <button on:click={() => requireLogin() && goto(`/messages?share_video=${video.slug}`)}><Share2 size={25} /><b>В чат</b></button>
          </aside>
        </article>
      {/each}
    </div>
  {:else}
    <div class="state"><h1>Здесь появятся лучшие учебные JQ</h1><p>Сними короткий разбор, формулу или полезный приём.</p><a href="/upload">Создать первый JQ</a></div>
  {/if}
</section>

{#if commentsOpen}
  <section class="comments-panel">
    <header><strong>Комментарии</strong><button on:click={() => (commentsOpen = false)} aria-label="Закрыть"><X size={22}/></button></header>
    <div class="comment-list">
      {#each comments as comment}
        <article><Avatar user={comment.user} size={34}/><div><strong>{comment.user?.display_name || comment.user?.username}</strong><p>{comment.body}</p></div></article>
      {:else}
        <p class="empty-comments">Комментариев пока нет</p>
      {/each}
    </div>
    <form on:submit|preventDefault={sendComment}><input bind:value={commentText} placeholder="Добавить комментарий" /><button aria-label="Отправить"><Send size={19}/></button></form>
  </section>
{/if}

<style>
  :global(main.main){padding-bottom:0}.jq-page{position:relative;height:calc(100dvh - 73px);overflow:hidden;background:#050506}.mobile-head{position:absolute;top:0;right:0;left:0;z-index:5;display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:linear-gradient(#050506cc,transparent)}.mobile-head span,.add,.media-link{display:flex;align-items:center}.mobile-head span{gap:6px}.add,.media-link{gap:4px;border:1px solid #ffffff30;border-radius:999px;background:#141418aa;padding:7px 10px;font-size:12px;font-weight:800}.media-link{color:#ddd6fe}.reels{height:100%;overflow-y:auto;scroll-snap-type:y mandatory}.reel{position:relative;height:100%;overflow:hidden;scroll-snap-align:start;background:#08080a}.reel video{width:100%;height:100%;object-fit:cover}.shade{position:absolute;inset:0;background:linear-gradient(transparent 52%,#000000d9)}.sound{position:absolute;top:74px;right:14px;display:grid;width:38px;height:38px;place-items:center;border-radius:50%;background:#0008}.caption{position:absolute;right:75px;bottom:24px;left:16px;display:grid;gap:7px;text-shadow:0 1px 4px #000}.creator{display:flex;align-items:center;gap:8px}.caption h1{font-size:21px}.caption p{display:-webkit-box;overflow:hidden;color:#eee;-webkit-box-orient:vertical;-webkit-line-clamp:2;font-size:14px}.caption small{color:#d4d4d8;font-weight:800}.rail{position:absolute;right:10px;bottom:22px;display:grid;gap:16px}.rail button{display:grid;justify-items:center;gap:4px;color:white;text-shadow:0 1px 4px #000}.rail button.active{color:#a89fff}.rail b{max-width:62px;font-size:10px}.state{display:grid;height:100%;place-items:center;align-content:center;gap:12px;padding:28px;text-align:center}.state h1{font-size:25px}.state p{max-width:430px;color:var(--text-2)}.state a{border-radius:999px;background:var(--primary);padding:10px 15px;font-weight:800}.comments-panel{position:fixed;right:0;bottom:0;left:0;z-index:80;display:grid;max-height:min(70dvh,620px);grid-template-rows:auto minmax(0,1fr) auto;border-top:1px solid var(--border);border-radius:18px 18px 0 0;background:#161619;box-shadow:0 -14px 36px #0008}.comments-panel header{display:flex;justify-content:space-between;padding:16px;border-bottom:1px solid var(--border)}.comment-list{display:grid;gap:14px;overflow:auto;padding:15px}.comment-list article{display:flex;gap:9px}.comment-list p{color:#d4d4d8;font-size:14px}.empty-comments{padding:30px;color:var(--text-2);text-align:center}.comments-panel form{display:flex;gap:8px;padding:11px 13px max(11px,env(safe-area-inset-bottom));border-top:1px solid var(--border)}.comments-panel input{min-width:0;flex:1;border:1px solid var(--border);border-radius:999px;background:#202024;padding:10px 13px;color:white}.comments-panel form button{display:grid;width:42px;place-items:center;border-radius:50%;background:var(--primary)}@media(min-width:768px){.jq-page{height:100vh}.mobile-head{display:flex;left:248px}.reel{width:min(100%,500px);margin:auto;border-right:1px solid #ffffff14;border-left:1px solid #ffffff14}.comments-panel{left:auto;width:390px;border-left:1px solid var(--border);border-radius:18px 0 0}}
</style>
