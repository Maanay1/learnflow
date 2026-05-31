<script>
  import Avatar from './Avatar.svelte';
  export let video;
  export let aspect = 'video';

  const duration = (seconds = 0) => `${Math.floor((Number(seconds) || 0) / 60)}:${String((Number(seconds) || 0) % 60).padStart(2, '0')}`;
  const compact = (value = 0) => new Intl.NumberFormat('ru-RU', { notation: 'compact' }).format(Number(value) || 0);
  const difficultyRu = { beginner: 'Начальный', intermediate: 'Средний', advanced: 'Сложный' };
  $: difficulty = (video?.difficulty || 'beginner').toLowerCase();
</script>

<a href={`/video/${video?.slug || ''}`} class={`video-card ${aspect}`}>
  <div class="thumb-wrap">
    {#if video?.thumbnail_url}
      <img src={video.thumbnail_url} alt={video.title} loading="lazy" />
    {:else}
      <div class="placeholder">LF</div>
    {/if}
    <div class="overlay"></div>
    <span class={`difficulty ${difficulty}`}>{difficultyRu[difficulty] || difficulty}</span>
    <span class="duration">{duration(video?.duration_seconds)}</span>
    <div class="info">
      <div class="author"><Avatar user={video?.creator} size={24} /><span>@{video?.creator?.username || ''}</span></div>
      <h3>{video?.title || ''}</h3>
      <p>{compact(video?.view_count)} просмотров · {compact(video?.like_count)} лайков</p>
    </div>
  </div>
</a>

<style>
  .video-card,.thumb-wrap{display:block;overflow:hidden;border-radius:12px;background:#111}.thumb-wrap{position:relative;aspect-ratio:16/9}.square .thumb-wrap{aspect-ratio:1}.vertical .thumb-wrap{aspect-ratio:9/16}img,.placeholder{width:100%;height:100%;object-fit:cover}.placeholder{display:grid;place-items:center;background:linear-gradient(135deg,#171717,#26204a);color:#818cf8;font-size:38px;font-weight:900}.overlay{position:absolute;inset:0;background:linear-gradient(transparent,rgba(0,0,0,.88))}.difficulty,.duration{position:absolute;top:10px;border-radius:999px;padding:4px 9px;color:white;font-size:11px;font-weight:700}.difficulty{left:10px}.duration{right:10px;background:rgba(0,0,0,.7)}.beginner{background:#16a34a}.intermediate{background:#d97706}.advanced{background:#dc2626}.info{position:absolute;right:0;bottom:0;left:0;padding:12px}.author{display:flex;align-items:center;gap:7px;color:#d4d4d4;font-size:12px}.info h3{margin-top:7px;color:white;font-weight:800}.info p{margin-top:4px;color:#a3a3a3;font-size:12px}
</style>
