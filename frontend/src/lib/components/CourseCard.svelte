<script>
  import Avatar from './Avatar.svelte';
  import DifficultyBadge from './DifficultyBadge.svelte';
  import TagPill from './TagPill.svelte';
  export let course;
  const price = (course) => course?.is_paid ? `${Math.round((course.price_cents || 0) / 100)} ₽` : 'Бесплатно';
  const duration = (seconds = 0) => `${Math.round((seconds || 0) / 60)} мин`;
</script>

<a href={`/courses/${course.slug}`} class="group block overflow-hidden rounded-xl border bg-[var(--surface)] transition duration-200 hover:scale-[1.02]" style="border-color:var(--border)" on:mouseenter={(e) => (e.currentTarget.style.boxShadow = '0 10px 34px rgba(99,102,241,0.22)')} on:mouseleave={(e) => (e.currentTarget.style.boxShadow = 'none')}>
  <div class="relative aspect-video bg-[var(--surface-2)]">
    {#if course.thumbnail_url}
      <img src={course.thumbnail_url} alt={course.title} class="h-full w-full object-cover" loading="lazy" />
    {:else}
      <div class="grid h-full place-items-center bg-[var(--primary-subtle)] text-5xl font-black text-primary">LF</div>
    {/if}
    <span class="absolute bottom-2 right-2 rounded-lg bg-black/75 px-2 py-1 text-xs font-semibold text-white">{price(course)}</span>
  </div>
  <div class="space-y-3 p-4">
    <div class="flex items-center gap-2 text-sm text-[var(--text-2)]">
      <Avatar user={course.creator} size={24} />
      <span class="truncate">{course.creator?.display_name || course.creator?.username || 'Creator'}</span>
    </div>
    <h3 class="line-clamp-2 min-h-12 font-bold text-[var(--text)]">{course.title}</h3>
    <div class="flex flex-wrap items-center gap-2">
      {#if course.subject_tag}<TagPill tag={course.subject_tag} />{/if}
      <DifficultyBadge difficulty={course.difficulty} />
    </div>
    <div class="flex justify-between text-xs text-[var(--text-3)]">
      <span>{course.video_count || 0} видео</span>
      <span>{duration(course.duration_seconds)}</span>
    </div>
    {#if course.progress}
      <div class="h-2 rounded-full bg-[var(--surface-2)]">
        <div class="progress-fill h-full rounded-full bg-primary" style={`width:${course.progress.percent || 0}%`}></div>
      </div>
    {/if}
  </div>
</a>
