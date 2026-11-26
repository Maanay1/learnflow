<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { ArrowLeft, Bookmark, Heart, MessagesSquare, Send, Trash2 } from 'lucide-svelte';
  import { social, videos } from '$lib/api';
  import { authStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import VideoPlayer from '$lib/components/VideoPlayer.svelte';
  let video, comments = [], loading = true, commentText = '', liked = false, saved = false;
  onMount(async () => {
    try {
      video = (await videos.detail($page.params.slug)).video;
      liked = video.is_liked; saved = video.is_saved;
      comments = (await social.comments(video.id)).comments || [];
    } catch {} finally { loading = false; }
  });
  async function like() { liked = !liked; const result = await (liked ? social.like(video.id) : social.unlike(video.id)).catch(() => null); if (result) video = { ...video, like_count: result.like_count }; }
  async function save() { saved = !saved; await (saved ? social.save(video.id) : social.unsave(video.id)).catch(() => (saved = !saved)); }
  async function comment() { const body = commentText.trim(); if (!body) return; commentText = ''; const result = await social.comment(video.id, body).catch(() => null); if (result?.comment) comments = [result.comment, ...comments]; }
  // The apps have no browser back button, so the page offers its own.
  function back() {
    if (history.length > 1) history.back();
    else goto('/feed');
  }
  async function removeVideo() {
    if (!confirm('Удалить это видео? Его нельзя будет восстановить.')) return;
    await videos.remove(video.id);
    goto(`/profile/${$authStore.user.username}`);
  }
</script>
<svelte:head><title>{video?.title || 'Видео'} | JARQ</title></svelte:head>
<section class="shell max-w-5xl py-6">
  <button class="back" on:click={back}><ArrowLeft size={20}/> Назад</button>
  {#if loading}<p class="empty">Загружаем видео...</p>{:else if video}
    <VideoPlayer video={video} videoId={video.id} videoKey={video.view_url || video.video_key} chapters={video.chapters || []} initialProgress={0}/>
    <h1>{video.title}</h1><a class="creator" href={`/profile/${video.creator?.username || ''}`}><Avatar user={video.creator} size={44}/><span><strong>{video.creator?.display_name || video.creator?.username}</strong><small>@{video.creator?.username}</small></span></a>
    {#if video.description}<p class="description">{video.description}</p>{/if}
    <div class="actions"><button class:active={liked} on:click={like}><Heart size={19} fill={liked ? 'currentColor' : 'none'}/> {video.like_count || 0}</button><button class:active={saved} on:click={save}><Bookmark size={19} fill={saved ? 'currentColor' : 'none'}/> {saved ? 'Сохранено' : 'Сохранить'}</button><button on:click={() => goto(`/messages?share_video=${video.slug}`)}><MessagesSquare size={19}/> В чат</button>{#if $authStore.user?.id && $authStore.user.id === video.creator?.id}<button class="danger" on:click={removeVideo}><Trash2 size={19}/> Удалить</button>{/if}</div>
    <section class="comments"><h2>Комментарии ({comments.length})</h2>{#if $authStore.authenticated}<form on:submit|preventDefault={comment}><Avatar user={$authStore.user} size={36}/><input bind:value={commentText} placeholder="Комментарий..." /><button aria-label="Отправить комментарий" disabled={!commentText.trim()}><Send size={18}/></button></form>{/if}
      {#if comments.length}{#each comments as item}<article><Avatar user={item.user} size={34}/><div><strong>{item.user?.display_name || item.user?.username}</strong><p>{item.body}</p></div></article>{/each}{:else}<p class="empty">Нет комментариев</p>{/if}
    </section>
  {:else}<p class="empty">Видео не найдено</p>{/if}
</section>
<style>
  .back{display:flex;align-items:center;gap:6px;margin-bottom:14px;color:var(--text-2);font-weight:700}h1{margin-top:20px;font-size:30px;font-weight:900}.creator,.creator span{display:flex}.creator{align-items:center;gap:10px;margin-top:14px}.creator span{flex-direction:column}.creator small,.empty{color:#a3a3a3}.description{margin-top:16px;color:#d4d4d4}.actions{display:flex;flex-wrap:wrap;gap:9px;margin-top:18px}.actions button{display:flex;gap:7px;align-items:center;border-radius:999px;background:#171717;padding:10px 14px}.actions .active{color:var(--primary-text)}.actions .danger{color:var(--danger)}.comments{margin-top:28px;border-top:1px solid var(--border);padding-top:18px}.comments h2{font-size:22px;font-weight:800}form,article{display:flex;gap:10px;margin-top:14px}form{align-items:center}form input{min-width:0;height:42px;flex:1;border:1px solid var(--border);border-radius:999px;background:#171717;padding:0 14px;color:white}form button{display:grid;width:42px;height:42px;flex:none;place-items:center;border-radius:50%;background:var(--primary);color:var(--on-primary)}form button:disabled{opacity:.45}article p{margin-top:3px;color:#d4d4d4}.empty{padding:40px 0;text-align:center}@media(max-width:600px){h1{margin-top:16px;font-size:22px}}
</style>
