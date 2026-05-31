<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { courses, payments } from '$lib/api';
  import { authStore, toastStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  import DifficultyBadge from '$lib/components/DifficultyBadge.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import TagPill from '$lib/components/TagPill.svelte';
  let course, loading = true, payOpen = false, paying = false, stripe, elements, card;
  const fmt = (s = 0) => `${Math.round((s || 0) / 60)} мин`;
  const money = (cents = 0) => `${Math.round(cents / 100)}₽`;
  $: bullets = (course?.description || '').split(/[.\n]/).map((x) => x.trim()).filter(Boolean).slice(0, 5);
  $: next = course?.progress?.next_video || course?.videos?.[0];
  $: hasAccess = course?.access?.has_access || !course?.is_paid;
  onMount(async () => {
    course = (await courses.detail($page.params.slug)).course;
    loading = false;
  });
  async function openPayment() {
    if (!$authStore.authenticated) return location.assign('/login');
    payOpen = true;
    await tickStripe();
  }
  async function tickStripe() {
    if (stripe || !payOpen) return;
    await new Promise((resolve) => {
      if (window.Stripe) return resolve();
      const script = document.createElement('script');
      script.src = 'https://js.stripe.com/v3/';
      script.onload = resolve;
      document.head.appendChild(script);
    });
    const key = import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY || 'pk_test_local';
    stripe = window.Stripe?.(key);
    if (stripe) {
      elements = stripe.elements();
      card = elements.create('card', { style: { base: { color: '#f5f5f5', fontSize: '16px' } } });
      setTimeout(() => card.mount('#stripe-card'), 0);
    }
  }
  async function buy() {
    paying = true;
    try {
      const { client_secret } = await payments.purchase(course.id);
      if (stripe && client_secret) {
        const result = await stripe.confirmCardPayment(client_secret, { payment_method: { card } });
        if (result.error) throw new Error(result.error.message);
      }
      course.access = { ...(course.access || {}), has_access: true };
      toastStore.addToast('Курс куплен. Доступ открыт.', 'success');
      payOpen = false;
    } catch (error) {
      toastStore.addToast(error.message || 'Не удалось оплатить курс', 'error');
    }
    paying = false;
  }
</script>

<section class="shell py-8">
  {#if loading}
    <div class="skeleton h-96 rounded-xl"></div>
  {:else if course}
    <div class="grid gap-8 lg:grid-cols-[minmax(0,1fr)_360px]">
      <div class="space-y-8">
        <section class="overflow-hidden rounded-xl border border-[var(--border)] bg-[var(--surface)]">
          <div class="grid gap-6 p-6 md:grid-cols-[300px_minmax(0,1fr)]">
            <div class="aspect-video overflow-hidden rounded-lg bg-[var(--surface-2)]">
              {#if course.thumbnail_url}<img src={course.thumbnail_url} alt={course.title} class="h-full w-full object-cover" loading="lazy" />{:else}<div class="grid h-full place-items-center text-5xl font-black text-primary">LF</div>{/if}
            </div>
            <div class="space-y-4">
              <div class="flex flex-wrap gap-2">{#if course.subject_tag}<TagPill tag={course.subject_tag} />{/if}<DifficultyBadge difficulty={course.difficulty} /></div>
              <h1 class="text-4xl font-black">{course.title}</h1>
              <div class="flex items-center gap-3 text-[var(--text-2)]"><Avatar user={course.creator} size={32} /><span>{course.creator?.display_name || course.creator?.username}</span></div>
              <div class="flex flex-wrap gap-4 text-sm text-[var(--text-2)]"><span>{course.video_count} видео</span><span>{fmt(course.duration_seconds)}</span><span>{course.students_count || 0} студентов</span></div>
              {#if course.progress}
                <div><div class="mb-2 text-sm text-[var(--text-2)]">{course.progress.percent}% завершено</div><div class="h-2 rounded-full bg-[var(--surface-2)]"><div class="progress-fill h-full rounded-full bg-primary" style={`width:${course.progress.percent}%`}></div></div></div>
              {/if}
              {#if course.is_paid && !hasAccess}
                <button class="btn inline-flex" on:click={openPayment}>Купить курс — {money(course.price_cents)}</button>
              {:else if next}
                <a class="btn inline-flex" href={`/video/${next.slug}`}>Начать курс</a>
              {/if}
            </div>
          </div>
        </section>

        <section class="card p-6">
          <h2 class="mb-3 text-xl font-black">Описание</h2>
          <p class="leading-relaxed text-[var(--text-2)]">{course.description}</p>
          {#if bullets.length}
            <h3 class="mb-3 mt-6 font-black">Чему ты научишься</h3>
            <ul class="grid gap-2 text-[var(--text-2)]">{#each bullets as bullet}<li>✓ {bullet}</li>{/each}</ul>
          {/if}
        </section>
      </div>
      <aside class="space-y-4">
        <section class="card p-5">
          <h2 class="mb-4 text-xl font-black">Видео курса</h2>
          <div class="space-y-2">
            {#each course.videos || [] as video, index}
              <a href={hasAccess || index < 2 ? `/video/${video.slug}` : '#'} class="flex items-center gap-3 rounded-lg p-3 hover:bg-[var(--surface-2)]">
                <span class="grid h-8 w-8 place-items-center rounded-full bg-[var(--primary-subtle)] text-primary">{index + 1}</span>
                <div class="min-w-0 flex-1"><p class="truncate font-bold">{video.title}</p><p class="text-xs text-[var(--text-3)]">{fmt(video.duration_seconds)}</p></div>
                <span class="text-[var(--text-3)]">{hasAccess || index < 2 ? '🔓' : '🔒'}</span>
              </a>
            {/each}
          </div>
        </section>
        {#if course.progress?.percent === 100}
          <section class="card border-primary/40 p-5"><h2 class="font-black">Сертификат готов</h2><p class="mt-2 text-sm text-[var(--text-2)]">Скачай его из dashboard.</p></section>
        {/if}
      </aside>
    </div>
  {/if}
</section>

{#if payOpen}
  <Modal open={true} title="Оплата курса" onClose={() => (payOpen = false)}>
    <div class="space-y-4">
      <p class="text-[var(--text-2)]">{course.title}</p>
      <p class="text-3xl font-black">{money(course.price_cents)}</p>
      <div id="stripe-card" class="rounded-lg border border-[var(--border)] bg-[var(--surface-2)] p-4"></div>
      <button class="btn w-full" on:click={buy} disabled={paying}>{paying ? 'Оплачиваем...' : 'Оплатить'}</button>
    </div>
  </Modal>
{/if}
