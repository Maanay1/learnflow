<script>
  import { Eye, Heart, Play } from 'lucide-svelte';
  import Avatar from './Avatar.svelte';

  export let video;
  export let aspect = 'video';

  const duration = (seconds = 0) => `${Math.floor((Number(seconds) || 0) / 60)}:${String((Number(seconds) || 0) % 60).padStart(2, '0')}`;
  const compact = (value = 0) => new Intl.NumberFormat('ru-RU', { notation: 'compact' }).format(Number(value) || 0);
  const themes = {
    design: { color: '#35c99a', bg: '#0c2a24', label: 'Дизайн' },
    math: { color: '#f18b66', bg: '#301b16', label: 'Математика' },
    code: { color: '#9187f5', bg: '#211e3b', label: 'Программирование' },
    growth: { color: '#e8b24d', bg: '#302511', label: 'Саморазвитие' },
    default: { color: '#7f77dd', bg: '#211e3a', label: 'Обучение' }
  };

  function videoTheme(item) {
    const value = `${item?.tags?.map((tag) => tag.name).join(' ')} ${item?.title || ''}`.toLowerCase();
    if (/design|дизайн|ui|ux|figma/.test(value)) return themes.design;
    if (/math|математ|алгебр|геометр|интеграл/.test(value)) return themes.math;
    if (/code|код|программ|git|javascript|python/.test(value)) return themes.code;
    if (/самораз|эффектив|мотивац/.test(value)) return themes.growth;
    return themes.default;
  }

  $: theme = videoTheme(video);
  $: tag = video?.tags?.[0]?.name || theme.label;
</script>

<a href={`/video/${video?.slug || ''}`} class={`video-card ${aspect}`} style={`--topic:${theme.color};--preview:${theme.bg}`}>
  <div class="preview">
    {#if video?.thumbnail_url}
      <img src={video.thumbnail_url} alt={video.title} loading="lazy" />
    {:else}
      <div class="placeholder"><span><Play size={21} fill="currentColor" /></span></div>
    {/if}
    <span class="duration">{duration(video?.duration_seconds)}</span>
  </div>
  <div class="content">
    <span class="tag">{tag}</span>
    <h3>{video?.title || ''}</h3>
    <footer>
      <span class="author"><Avatar user={video?.creator} size={28} /><b>{video?.creator?.display_name || video?.creator?.username || 'Автор'}</b></span>
      <span class="stats"><i><Heart size={15} />{compact(video?.like_count)}</i><i><Eye size={15} />{compact(video?.view_count)}</i></span>
    </footer>
  </div>
</a>

<style>
  .video-card{display:block;overflow:hidden;border:1px solid var(--border);border-radius:18px;background:var(--surface);transition:transform 180ms ease,border-color 180ms ease,box-shadow 180ms ease}.video-card:hover{transform:translateY(-3px);border-color:rgba(255,255,255,.2);box-shadow:0 16px 28px rgba(0,0,0,.2)}.preview{position:relative;overflow:hidden;aspect-ratio:16/8.7;background:var(--preview)}img,.placeholder{width:100%;height:100%;object-fit:cover}.placeholder{display:grid;place-items:center;background:linear-gradient(135deg,var(--preview),rgba(255,255,255,.025))}.placeholder span{display:grid;width:58px;height:58px;place-items:center;border:1px solid color-mix(in srgb,var(--topic) 60%,white 20%);border-radius:999px;background:rgba(255,255,255,.08);color:var(--topic)}.duration{position:absolute;right:12px;bottom:11px;border-radius:6px;background:rgba(7,7,8,.82);padding:3px 7px;color:#fff;font-size:12px;font-weight:800}.content{padding:14px}.tag{display:inline-flex;border-radius:999px;background:color-mix(in srgb,var(--topic) 16%,transparent);padding:3px 9px;color:var(--topic);font-size:12px;font-weight:800}.content h3{display:-webkit-box;min-height:46px;margin-top:10px;overflow:hidden;-webkit-box-orient:vertical;-webkit-line-clamp:2;font-size:17px;line-height:1.35}.content footer,.author,.stats,.stats i{display:flex;align-items:center}.content footer{justify-content:space-between;gap:8px;margin-top:14px}.author{min-width:0;gap:8px;color:var(--text-2)}.author b{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:13px}.stats{gap:9px;color:var(--text-3)}.stats i{gap:4px;font-size:12px;font-style:normal}@media(max-width:560px){.video-card{border-radius:16px}.content{padding:13px 14px 14px}.content h3{font-size:18px}.preview{aspect-ratio:16/9}}
</style>
