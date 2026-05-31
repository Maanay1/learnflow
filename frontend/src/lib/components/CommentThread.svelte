<script>
  import { social } from '$lib/api';
  import { authStore, toastStore } from '$lib/stores';
  import Avatar from './Avatar.svelte';
  export let comments = [];
  export let videoId;
  let body = '';
  let replyBody = {};

  const rel = (value) => {
    const diff = Math.max(1, Math.floor((Date.now() - new Date(value).getTime()) / 1000));
    if (diff < 60) return `${diff}s ago`;
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
    return `${Math.floor(diff / 86400)}d ago`;
  };

  async function add(parent = null) {
    const text = parent ? replyBody[parent.id] : body;
    if (!text?.trim()) return;
    const { comment } = await social.comment(videoId, text, parent?.id || null);
    if (parent) {
      parent.replies = [...(parent.replies || []), comment];
      replyBody[parent.id] = '';
    } else {
      comments = [comment, ...comments];
      body = '';
    }
  }

  async function remove(comment) {
    await social.deleteComment(comment.id);
    comment.is_deleted = true;
    comment.body = '[deleted]';
    toastStore.addToast('Комментарий удалён');
  }
</script>

<section class="space-y-4">
  <h2 class="text-2xl font-black">Комментарии</h2>
  <div class="flex gap-3">
    <Avatar user={$authStore.user} size={36} />
    <textarea class="input min-h-20" bind:value={body} maxlength="2000" placeholder="Ваш комментарий"></textarea>
    <button class="btn self-start" on:click={() => add()}>Отправить</button>
  </div>
  {#each comments as comment}
    <article class="rounded-xl border border-[#2e2e2e] bg-[#1a1a1a] p-4">
      <div class="flex items-center gap-3">
        <Avatar user={comment.user} size={34} />
        <div><p class="font-bold">{comment.user?.display_name || comment.user?.username}</p><p class="text-xs text-[#737373]">{rel(comment.inserted_at)}</p></div>
      </div>
      <p class={`mt-3 ${comment.is_deleted ? 'text-[#737373]' : 'text-[#f5f5f5]'}`}>{comment.is_deleted ? '[Комментарий удалён]' : comment.body}</p>
      <div class="mt-3 flex gap-3 text-sm">
        <button class="text-primary" on:click={() => (replyBody[comment.id] = replyBody[comment.id] ?? '')}>Ответить</button>
        {#if $authStore.user?.id === comment.user?.id}<button class="text-[#ef4444]" on:click={() => remove(comment)}>Удалить</button>{/if}
      </div>
      {#if replyBody[comment.id] !== undefined}
        <div class="mt-3 flex gap-2 pl-8">
          <input class="input" bind:value={replyBody[comment.id]} placeholder="Ответ" />
          <button class="btn-secondary" on:click={() => add(comment)}>OK</button>
        </div>
      {/if}
      {#if comment.replies?.length}
        <div class="mt-4 space-y-3 border-l border-[#2e2e2e] pl-5">
          {#each comment.replies as reply}
            <div>
              <div class="flex items-center gap-2"><Avatar user={reply.user} size={26} /><span class="font-semibold">{reply.user?.username}</span><span class="text-xs text-[#737373]">{rel(reply.inserted_at)}</span></div>
              <p class={`mt-2 ${reply.is_deleted ? 'text-[#737373]' : 'text-[#d4d4d4]'}`}>{reply.is_deleted ? '[Комментарий удалён]' : reply.body}</p>
            </div>
          {/each}
          <button class="text-sm text-[#a3a3a3]">Load more replies</button>
        </div>
      {/if}
    </article>
  {/each}
</section>
