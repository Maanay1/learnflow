<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { ArrowRight, ClipboardCheck, Plus, Users } from 'lucide-svelte';
  import { quizzes } from '$lib/api';
  import { authStore } from '$lib/stores';

  let items = [], code = '', loading = true, joining = false, error = '';
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');

  onMount(async () => {
    try { items = (await quizzes.list()).quizzes || []; }
    finally { loading = false; }
  });

  async function join() {
    if (!code.trim()) return;
    joining = true;
    error = '';
    try {
      const { quiz } = await quizzes.join(code);
      goto(`/tests/${quiz.id}`);
    } catch (requestError) {
      error = requestError?.data?.error === 'invalid_join_code' ? 'Тест с таким кодом не найден' : requestError?.data?.error || 'Не удалось подключиться';
    } finally {
      joining = false;
    }
  }

  const status = (value) => ({ waiting: 'Ожидает старта', active: 'Идёт сейчас', finished: 'Завершён' }[value] || value);
</script>

<svelte:head><title>Тесты | JARQ</title></svelte:head>
<section class="shell max-w-4xl py-8">
  <header><div><span class="eyebrow">JARQ CLASSROOM</span><h1>Live-тесты</h1><p>Подключайся по коду или запускай свой тест для класса.</p></div><a class="create" href="/tests/create"><Plus size={18}/> Создать тест</a></header>
  <section class="join card">
    <div class="join-icon"><ClipboardCheck size={27}/></div>
    <div><h2>Войти по коду</h2><p>Код выдаёт создатель теста.</p></div>
    <form on:submit|preventDefault={join}><input bind:value={code} maxlength="6" placeholder="ABC123" on:input={() => (code = code.toUpperCase())}/><button disabled={joining}>{joining ? 'Входим...' : 'Войти'} <ArrowRight size={17}/></button></form>
    {#if error}<small class="error">{error}</small>{/if}
  </section>
  <section class="mine">
    <h2>Мои тесты</h2>
    {#if loading}
      <p class="empty">Загружаем...</p>
    {:else if items.length}
      <div class="grid">
        {#each items as quiz}
          <a class="quiz card" href={`/tests/${quiz.id}`}>
            <div><b class:live={quiz.status === 'active'}>{status(quiz.status)}</b><strong>{quiz.title}</strong></div>
            <span><Users size={16}/>{quiz.participants_count || 0} участников</span>
            <small>Код: {quiz.join_code}</small>
          </a>
        {/each}
      </div>
    {:else}
      <div class="empty card">Создай первый тест с четырьмя вариантами ответа и отправь код ученикам.</div>
    {/if}
  </section>
</section>

<style>
  header{display:flex;align-items:end;justify-content:space-between;gap:16px;margin-bottom:22px}h1{margin-top:4px;font-size:34px;font-weight:950}.eyebrow{color:#a89fff;font-size:11px;font-weight:900;letter-spacing:1.6px}header p,.join p{margin-top:5px;color:var(--text-2)}.create,.join button{display:flex;align-items:center;justify-content:center;gap:5px;border-radius:999px;background:var(--primary);padding:10px 15px;font-weight:800;white-space:nowrap}.join{display:grid;grid-template-columns:auto 1fr auto;gap:14px;align-items:center;padding:18px}.join-icon{display:grid;width:54px;height:54px;place-items:center;border-radius:17px;background:var(--primary-soft);color:#a89fff}.join h2,.mine h2{font-size:21px}.join form{display:flex;gap:8px}.join input{width:120px;border:1px solid var(--border);border-radius:999px;background:#0f0f11;padding:10px 13px;color:white;font-size:17px;font-weight:900;letter-spacing:2px;text-transform:uppercase}.error{grid-column:2/-1;color:#f87171}.mine{margin-top:26px}.mine h2{margin-bottom:13px}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.quiz{display:grid;gap:14px;padding:16px}.quiz div{display:grid;gap:7px}.quiz b{justify-self:start;border-radius:999px;background:#27272a;padding:4px 8px;color:var(--text-2);font-size:11px}.quiz b.live{background:#3f1d2e;color:#fb7185}.quiz strong{font-size:18px}.quiz span{display:flex;align-items:center;gap:6px;color:var(--text-2);font-size:13px}.quiz small{color:#a89fff;font-weight:900;letter-spacing:1px}.empty{padding:25px;color:var(--text-2);text-align:center}@media(max-width:640px){header{display:grid}h1{font-size:29px}.create{justify-self:start}.join{grid-template-columns:auto 1fr;padding:15px}.join form{grid-column:1/-1}.join input{min-width:0;flex:1}.error{grid-column:1/-1}.grid{grid-template-columns:1fr}}
</style>
