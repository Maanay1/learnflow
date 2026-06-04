<script>
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { admin } from '$lib/api';
  import { authStore } from '$lib/stores';
  import { Activity, Eye, LogIn, UserPlus, Users, Video } from 'lucide-svelte';

  let data = null;
  let loading = true;
  let error = '';

  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');
  $: if (!$authStore.loading && $authStore.authenticated && !$authStore.user?.is_admin) goto('/feed');

  onMount(load);

  async function load() {
    loading = true;
    error = '';
    try {
      data = await admin.analytics();
    } catch (err) {
      error = err?.status === 403 ? 'Доступ только для админа' : 'Не удалось загрузить аналитику';
    } finally {
      loading = false;
    }
  }

  const label = {
    profile_view: 'Просмотр профиля',
    login: 'Вход',
    google_login: 'Google вход',
    register: 'Регистрация',
    google_register: 'Google регистрация'
  };

  $: cards = data
    ? [
        { title: 'Пользователи', value: data.totals.users, sub: `+${data.last_24h.new_users} за 24ч`, icon: Users },
        { title: 'Входы', value: data.totals.logins, sub: `${data.last_24h.logins} за 24ч`, icon: LogIn },
        { title: 'Сессии', value: data.totals.active_sessions, sub: `${data.totals.sessions} всего`, icon: Activity },
        { title: 'Просмотры профилей', value: data.totals.profile_views, sub: `${data.last_24h.profile_views} за 24ч`, icon: Eye },
        { title: 'Видео', value: data.totals.active_videos, sub: `${data.totals.video_views} просмотров`, icon: Video },
        { title: 'Регистрации', value: data.totals.registrations, sub: `${data.last_7d.new_users} за 7 дней`, icon: UserPlus }
      ]
    : [];
</script>

<svelte:head><title>Аналитика | JARQ</title></svelte:head>

<section class="analytics-shell">
  <header>
    <div>
      <p class="eyebrow">ADMIN</p>
      <h1>Аналитика JARQ</h1>
      <span>Пользователи, входы, просмотры профилей и активность платформы.</span>
    </div>
    <button on:click={load}>Обновить</button>
  </header>

  {#if loading}
    <p class="state">Загружаю аналитику...</p>
  {:else if error}
    <p class="state error">{error}</p>
  {:else if data}
    <div class="cards">
      {#each cards as card}
        <article>
          <svelte:component this={card.icon} size={23} />
          <small>{card.title}</small>
          <strong>{card.value || 0}</strong>
          <span>{card.sub}</span>
        </article>
      {/each}
    </div>

    <div class="columns">
      <section class="panel">
        <h2>Популярные профили</h2>
        {#if data.top_profiles.length}
          {#each data.top_profiles as item}
            <a class="row" href={`/profile/${item.username}`}>
              <span><strong>{item.display_name || item.username}</strong><small>@{item.username}</small></span>
              <b>{item.views} просмотров</b>
            </a>
          {/each}
        {:else}
          <p class="empty">Пока нет просмотров профилей</p>
        {/if}
      </section>

      <section class="panel">
        <h2>Топ видео</h2>
        {#each data.top_videos as item}
          <a class="row" href={`/video/${item.slug}`}>
            <span><strong>{item.title}</strong><small>@{item.creator_username || 'author'} · {item.format?.toUpperCase()}</small></span>
            <b>{item.views || 0}</b>
          </a>
        {/each}
      </section>
    </div>

    <section class="panel events">
      <h2>Последние события</h2>
      {#each data.recent_events as event}
        <div class="event">
          <span><strong>{label[event.event_type] || event.event_type}</strong><small>{new Date(event.inserted_at).toLocaleString('ru-RU')}</small></span>
          <p>
            {event.actor?.username ? `@${event.actor.username}` : 'Гость'}
            {#if event.target_user?.username} → @{event.target_user.username}{/if}
          </p>
        </div>
      {/each}
    </section>
  {/if}
</section>

<style>
  .analytics-shell{width:min(100%,1180px);margin:auto;padding:30px 18px 40px}header{display:flex;align-items:flex-start;justify-content:space-between;gap:16px;margin-bottom:22px}.eyebrow{color:#9c93ff;font-size:12px;font-weight:900;letter-spacing:2px}h1{font-size:34px}header span,.empty,.state{color:var(--text-2)}header button{border:1px solid var(--border);border-radius:999px;background:var(--surface);padding:10px 15px;font-weight:900}.cards{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}.cards article,.panel{border:1px solid var(--border);border-radius:18px;background:var(--surface);box-shadow:0 12px 30px rgba(0,0,0,.18)}.cards article{display:grid;gap:6px;padding:17px}:global(.cards svg){color:#a49bff}.cards small{color:var(--text-2);font-weight:800}.cards strong{font-size:32px}.cards span{color:var(--text-3);font-size:13px}.columns{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-top:14px}.panel{padding:18px}h2{margin-bottom:12px;font-size:20px}.row,.event{display:flex;align-items:center;justify-content:space-between;gap:12px;border-top:1px solid var(--border);padding:12px 0}.row:first-of-type,.event:first-of-type{border-top:0}.row span,.event span{display:grid;min-width:0}.row strong,.row small{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.row small,.event small{color:var(--text-3)}.row b{flex:none;color:#a49bff}.events{margin-top:14px}.event p{color:var(--text-2);font-weight:800}.state{display:grid;min-height:260px;place-items:center;border:1px solid var(--border);border-radius:18px;background:var(--surface)}.error{color:#ff8585}@media(max-width:760px){.analytics-shell{padding:20px 14px 92px}header{display:grid}h1{font-size:29px}.cards,.columns{grid-template-columns:1fr}.cards strong{font-size:28px}.row,.event{align-items:flex-start}.event{display:grid}}
</style>
