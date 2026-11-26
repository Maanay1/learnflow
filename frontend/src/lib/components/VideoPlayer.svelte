<script>
  import { createEventDispatcher, onMount } from 'svelte';
  import { videos } from '$lib/api';
  import { Maximize, Pause, Play, Volume2, VolumeX } from 'lucide-svelte';

  export let video;
  export let videoId;
  export let videoKey = '';
  export let videoUrl = '';
  export let chapters = [];
  export let initialProgress = 0;

  let videoEl;
  let wrap;
  let resolvedUrl = '';
  let paused = true;
  let current = 0;
  let duration = 0;
  let volume = 0.9;
  let rate = 1;
  let muted = false;
  const rates = [1, 1.25, 1.5, 2];
  function nextRate() {
    rate = rates[(rates.indexOf(rate) + 1) % rates.length];
    videoEl.playbackRate = rate;
  }
  function toggleMute() {
    muted = !muted;
    videoEl.muted = muted;
  }
  const clock = (seconds) => `${Math.floor((seconds || 0) / 60)}:${String(Math.floor((seconds || 0) % 60)).padStart(2, '0')}`;
  let progressTimer;
  const dispatch = createEventDispatcher();

  $: sourceKey = videoKey || video?.video_key || video?.view_url || videoUrl || '';
  $: pct = duration ? (current / duration) * 100 : 0;
  $: if (sourceKey?.startsWith?.('http') && resolvedUrl !== sourceKey) resolvedUrl = sourceKey;

  async function resolveUrl() {
    if (sourceKey?.startsWith?.('http')) {
      resolvedUrl = sourceKey;
      return;
    }

    if (videoUrl?.startsWith?.('http')) {
      resolvedUrl = videoUrl;
      return;
    }

    if (videoId || video?.id) {
      const data = await videos.viewUrl(videoId || video.id).catch(() => null);
      resolvedUrl = data?.view_url || sourceKey || '';
    }
  }

  async function togglePlay() {
    if (!videoEl) return;
    if (videoEl.paused) {
      await videoEl.play().catch(() => {});
    } else {
      videoEl.pause();
    }
  }

  function seek(value) {
    if (videoEl) videoEl.currentTime = Number(value) || 0;
  }

  function handleProgress() {
    current = videoEl?.currentTime || 0;
  }

  async function handleComplete() {
    if (videoId || video?.id) {
      const result = await videos.complete(videoId || video.id).catch(() => null);
      if (result) dispatch('complete', result);
    }
  }

  function fullscreen() {
    (document.fullscreenElement ? document.exitFullscreen() : wrap?.requestFullscreen())?.catch?.(() => {});
  }

  onMount(() => {
    resolveUrl();
    progressTimer = setInterval(() => {
      if ((videoId || video?.id) && current > 0) videos.progress(videoId || video.id, Math.floor(current)).catch(() => {});
    }, 10000);

    return () => clearInterval(progressTimer);
  });
</script>

<section bind:this={wrap} class="player-shell">
  <video
    bind:this={videoEl}
    src={resolvedUrl}
    class="video-el"
    preload="metadata"
    playsinline
    on:loadedmetadata={() => { duration = videoEl.duration || 0; if (initialProgress) videoEl.currentTime = initialProgress; }}
    on:timeupdate={handleProgress}
    on:ended={handleComplete}
    on:click={togglePlay}
    on:play={() => (paused = false)}
    on:pause={() => (paused = true)}
  >
    <track kind="captions" />
  </video>

  {#if paused}
    <button class="big-play" aria-label="Play video" on:click={togglePlay}><Play size={54} fill="currentColor" /></button>
  {/if}

  <div class="controls">
    <div class="seek">
      <span style={`width:${pct}%`}></span>
      <input aria-label="Seek video" type="range" min="0" max={duration || 0} value={current} on:input={(e) => seek(e.target.value)} />
      {#each chapters || [] as chapter}
        {#if duration}
          <i style={`left:${(chapter.start_seconds / duration) * 100}%`}></i>
        {/if}
      {/each}
    </div>
    <div class="control-row">
      <button aria-label="Play pause" on:click={togglePlay}>{#if paused}<Play size={18} fill="currentColor" />{:else}<Pause size={18} fill="currentColor" />{/if}</button>
      <span class="time">{clock(current)} / {clock(duration)}</span>
      <button class="rate" aria-label="Скорость" on:click={nextRate}>{rate}x</button>
      <span class="volume">
        <button aria-label={muted ? 'Включить звук' : 'Выключить звук'} on:click={toggleMute}>{#if muted}<VolumeX size={18} />{:else}<Volume2 size={18} />{/if}</button>
        <input aria-label="Громкость" type="range" min="0" max="1" step="0.05" bind:value={volume} on:input={() => (videoEl.volume = volume)} />
      </span>
      <button aria-label="Fullscreen" on:click={fullscreen}><Maximize size={18} /></button>
    </div>
  </div>
</section>

<style>
  .player-shell {
    position: relative;
    overflow: hidden;
    aspect-ratio: 16 / 9;
    border-radius: 12px;
    background: #050505;
  }

  .video-el {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    background: #000;
  }

  .big-play {
    position: absolute;
    inset: 0;
    display: grid;
    width: 86px;
    height: 86px;
    place-items: center;
    margin: auto;
    border-radius: 999px;
    background: rgba(255,255,255,0.2);
    color: #fff;
    backdrop-filter: blur(14px);
  }

  .controls {
    position: absolute;
    right: 0;
    bottom: 0;
    left: 0;
    padding: 56px 14px 12px;
    background: linear-gradient(to top, rgba(0,0,0,0.86), transparent);
  }

  .seek {
    position: relative;
    height: 4px;
    border-radius: 999px;
    background: rgba(255,255,255,0.24);
  }

  .seek span {
    display: block;
    height: 100%;
    border-radius: inherit;
    background: var(--primary);
  }

  .seek input {
    position: absolute;
    inset: -8px 0;
    width: 100%;
    opacity: 0;
    cursor: pointer;
  }

  .seek i {
    position: absolute;
    top: -3px;
    width: 10px;
    height: 10px;
    border-radius: 999px;
    background: #fff;
  }

  .control-row {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: 10px;
    color: #fff;
    font-size: 13px;
    font-weight: 700;
  }

  .control-row button,
  .control-row label {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    border-radius: 999px;
    background: rgba(17,17,17,0.72);
    padding: 7px 10px;
    color: #fff;
  }

  .time {
    white-space: nowrap;
    font-variant-numeric: tabular-nums;
  }

  .volume {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    margin-left: auto;
  }

  .volume input {
    width: 72px;
    accent-color: var(--primary);
  }

  @media (max-width: 520px) {
    .big-play { width: 64px; height: 64px; }
    .big-play :global(svg) { width: 34px; height: 34px; }
    .controls { padding: 40px 10px 8px; }
    .control-row { gap: 7px; margin-top: 8px; font-size: 12px; }
    .control-row button { padding: 6px 8px; }
    /* Phones use hardware volume buttons; keep only the mute toggle. */
    .volume input { display: none; }
  }
</style>
