<script>
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { certificates, dashboard, payments } from '$lib/api';
  import { authStore } from '$lib/stores';
  import VideoCard from '$lib/components/VideoCard.svelte';
  import CourseCard from '$lib/components/CourseCard.svelte';
  let stats = {}, history = [], saved = [], myCourses = [], earnings = null, activeTab = 'overview', loading = true;
  $: maxRevenue = Math.max(1, ...(earnings?.chart || []).map((point) => point.revenue_cents || 0));
  const money = (cents = 0) => `${Math.round(cents / 100)}₽`;
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');
  onMount(async () => {
    const params = new URLSearchParams(location.search);
    if (params.get('tab')) activeTab = params.get('tab');
    stats = await dashboard.stats();
    history = (await dashboard.history()).items || [];
    saved = (await dashboard.saved()).items || [];
    myCourses = (await dashboard.courses()).courses || [];
    if ($authStore.user?.is_creator) earnings = await payments.stats().catch(() => null);
    loading = false;
  });
  async function remove(videoId) { await dashboard.deleteHistory(videoId); history = history.filter((h) => h.video?.id !== videoId); }
  async function downloadCertificate(course) {
    const certificate = course.certificate || course.certificates?.[0];
    if (!certificate?.id) return;
    const { download_url } = await certificates.download(certificate.id);
    window.open(download_url, '_blank');
  }
  async function onboard() {
    const { url } = await payments.onboarding();
    location.href = url;
  }
</script>

<section class="shell space-y-8 py-8">
  <h1 class="text-3xl font-black">Dashboard</h1>
  <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
    {#each [['Просмотрено', stats.total_watched], ['Завершено', stats.total_completed], ['Streak 🔥', stats.current_streak], ['Подписчики', stats.followers_count]] as card}
      <div class="card p-5"><p class="text-[#a3a3a3]">{card[0]}</p><p class="mt-2 text-3xl font-black">{card[1] || 0}</p></div>
    {/each}
  </div>
  <div class="flex flex-wrap gap-2">
    {#each [['overview', 'Обзор'], ['courses', 'Мои курсы'], ['saved', 'Сохранённые'], ...($authStore.user?.is_creator ? [['earnings', 'Доходы']] : [])] as tab}
      <button class={activeTab === tab[0] ? 'btn' : 'btn-secondary'} on:click={() => (activeTab = tab[0])}>{tab[1]}</button>
    {/each}
  </div>
  {#if activeTab === 'overview'}
    <section><h2 class="mb-4 text-xl font-black">Продолжить просмотр</h2>{#if history.length}<div class="space-y-3">{#each history as row}<div class="card flex items-center gap-4 p-3"><div class="flex-1"><p class="font-bold">{row.video?.title}</p><div class="mt-2 h-2 rounded-full bg-[#242424]"><div class="progress-fill h-full rounded-full bg-primary" style={`width:${Math.min(100, ((row.seconds_watched || 0) / (row.video?.duration_seconds || 1)) * 100)}%`}></div></div></div><button class="btn-secondary" on:click={() => remove(row.video?.id)}>Удалить</button></div>{/each}</div>{:else}<div class="card p-8 text-center text-[var(--text-2)]">Здесь будет история просмотров</div>{/if}</section>
  {:else if activeTab === 'courses'}
    <section><h2 class="mb-4 text-xl font-black">Мои курсы</h2>{#if myCourses.length}<div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{#each myCourses as course}<div class="space-y-3"><CourseCard {course} />{#if course.progress?.percent === 100}<button class="btn w-full" on:click={() => downloadCertificate(course)}>Скачать сертификат</button>{/if}</div>{/each}</div>{:else}<div class="card p-8 text-center text-[var(--text-2)]">Начни курс, и он появится здесь</div>{/if}</section>
  {:else if activeTab === 'saved'}
    <section><h2 class="mb-4 text-xl font-black">Saved videos</h2>{#if saved.length}<div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{#each saved as row}<VideoCard video={row.video} />{/each}</div>{:else}<div class="card p-8 text-center text-[var(--text-2)]">Сохраняй видео чтобы смотреть позже</div>{/if}</section>
  {:else if activeTab === 'earnings'}
    <section class="space-y-5">
      <h2 class="text-xl font-black">Доходы</h2>
      {#if earnings && !earnings.onboarding_complete}
        <div class="card flex flex-col gap-3 border-primary/40 p-5 md:flex-row md:items-center md:justify-between">
          <div><h3 class="font-black">Подключи Stripe</h3><p class="text-sm text-[var(--text-2)]">Нужно завершить onboarding, чтобы принимать выплаты.</p></div>
          <button class="btn" on:click={onboard}>Продолжить onboarding</button>
        </div>
      {/if}
      <div class="grid gap-4 sm:grid-cols-3">
        <div class="card p-5"><p class="text-[var(--text-2)]">Всего заработано</p><p class="mt-2 text-3xl font-black">{money(earnings?.total_revenue_cents)}</p></div>
        <div class="card p-5"><p class="text-[var(--text-2)]">За 30 дней</p><p class="mt-2 text-3xl font-black">{money(earnings?.this_month_cents)}</p></div>
        <div class="card p-5"><p class="text-[var(--text-2)]">Студенты</p><p class="mt-2 text-3xl font-black">{earnings?.students_count || 0}</p></div>
      </div>
      <div class="card p-5">
        <div class="mb-4 flex items-center justify-between"><h3 class="font-black">Последние 30 дней</h3><button class="btn-secondary">Вывести средства</button></div>
        <svg viewBox="0 0 600 180" class="h-48 w-full overflow-visible">
          <polyline fill="none" stroke="var(--primary)" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" points={(earnings?.chart || []).map((point, i, arr) => `${arr.length <= 1 ? 0 : (i / (arr.length - 1)) * 600},${170 - ((point.revenue_cents || 0) / maxRevenue) * 150}`).join(' ')} />
        </svg>
      </div>
      <div class="card overflow-hidden">
        <table class="w-full text-left text-sm">
          <thead class="bg-[var(--surface-2)] text-[var(--text-2)]"><tr><th class="p-3">Курс</th><th class="p-3">Студенты</th><th class="p-3">Доход</th></tr></thead>
          <tbody>{#each earnings?.per_course || [] as row}<tr class="border-t border-[var(--border)]"><td class="p-3">{row.title}</td><td class="p-3">{row.students}</td><td class="p-3">{money(row.revenue_cents)}</td></tr>{/each}</tbody>
        </table>
      </div>
    </section>
  {/if}
</section>
