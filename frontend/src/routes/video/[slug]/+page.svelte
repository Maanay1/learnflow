<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { Bookmark, Heart, MessagesSquare } from 'lucide-svelte';
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
</script>
<svelte:head><title>{video?.title || 'Видео'} | JARQ</title></svelte:head>
<section class="shell max-w-5xl py-6">
  {#if loading}<p class="empty">Загружаем видео...</p>{:else if video}
    <VideoPlayer video={video} videoId={video.id} videoKey={video.view_url || video.video_key} chapters={video.chapters || []} initialProgress={0}/>
    <h1>{video.title}</h1><div class="creator"><Avatar user={video.creator} size={44}/><span><strong>{video.creator?.display_name || video.creator?.username}</strong><small>@{video.creator?.username}</small></span></div>
    {#if video.description}<p class="description">{video.description}</p>{/if}
    <div class="actions"><button class:active={liked} on:click={like}><Heart size={19}/> {video.like_count || 0}</button><button class:active={saved} on:click={save}><Bookmark size={19}/> Сохранить</button><button on:click={() => goto(`/messages?share_video=${video.slug}`)}><MessagesSquare size={19}/> В чат</button></div>
    <section class="comments"><h2>Комментарии ({comments.length})</h2>{#if $authStore.authenticated}<form on:submit|preventDefault={comment}><Avatar user={$authStore.user} size={36}/><input bind:value={commentText} placeholder="Добавить комментарий..." /><button>Отправить</button></form>{/if}
      {#if comments.length}{#each comments as item}<article><Avatar user={item.user} size={34}/><div><strong>{item.user?.display_name || item.user?.username}</strong><p>{item.body}</p></div></article>{/each}{:else}<p class="empty">Нет комментариев</p>{/if}
    </section>
  {:else}<p class="empty">Видео не найдено</p>{/if}
</section>
<style>
  h1{margin-top:20px;font-size:30px;font-weight:900}.creator,.creator span{display:flex}.creator{align-items:center;gap:10px;margin-top:14px}.creator span{flex-direction:column}.creator small,.empty{color:#a3a3a3}.description{margin-top:16px;color:#d4d4d4}.actions{display:flex;flex-wrap:wrap;gap:9px;margin-top:18px}.actions button{display:flex;gap:7px;align-items:center;border-radius:999px;background:#171717;padding:10px 14px}.actions .active{color:#a78bfa}.comments{margin-top:28px;border-top:1px solid var(--border);padding-top:18px}.comments h2{font-size:22px;font-weight:800}form,article{display:flex;gap:10px;margin-top:14px}form input{min-width:0;flex:1;border:1px solid var(--border);border-radius:999px;background:#171717;padding:0 14px;color:white}form button{border-radius:999px;background:#6366f1;padding:0 14px;font-weight:700}article p{margin-top:3px;color:#d4d4d4}.empty{padding:40px 0;text-align:center}
</style>
