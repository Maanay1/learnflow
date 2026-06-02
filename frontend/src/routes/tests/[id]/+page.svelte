<script>
  import { onDestroy, onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { CheckCircle2, Clock3, Copy, Play, Square, Trophy, Users } from 'lucide-svelte';
  import { quizzes } from '$lib/api';
  import { authStore, toastStore } from '$lib/stores';

  let quiz, loading = true, error = '', answers = {}, submitting = false, results = [], timer;
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');
  $: submitted = Boolean(quiz?.participant?.submitted_at);
  $: canAnswer = quiz?.status === 'active' && !quiz?.is_owner && !submitted;

  onMount(async () => {
    await load();
    timer = setInterval(load, 2000);
  });
  onDestroy(() => clearInterval(timer));

  async function load() {
    try {
      quiz = (await quizzes.detail($page.params.id)).quiz;
      error = '';
      if (quiz.status === 'finished' || quiz.is_owner) await loadResults();
    } catch (requestError) {
      error = requestError?.data?.error || 'Не удалось загрузить тест';
    } finally {
      loading = false;
    }
  }

  async function loadResults() {
    results = (await quizzes.results($page.params.id).catch(() => ({ participants: [] }))).participants || [];
  }

  async function start() {
    quiz = (await quizzes.start(quiz.id)).quiz;
  }

  async function finish() {
    quiz = (await quizzes.finish(quiz.id)).quiz;
    await loadResults();
  }

  async function submit() {
    if (quiz.questions.some((question) => answers[question.id] === undefined)) return error = 'Ответь на каждый вопрос';
    submitting = true;
    error = '';
    try {
      const payload = quiz.questions.map((question) => ({ question_id: question.id, selected_option: answers[question.id] }));
      const { participant } = await quizzes.submit(quiz.id, payload);
      quiz = { ...quiz, participant };
      await loadResults();
    } catch (requestError) {
      error = requestError?.data?.error || 'Не удалось отправить ответы';
    } finally {
      submitting = false;
    }
  }

  async function copyCode() {
    await navigator.clipboard.writeText(quiz.join_code);
    toastStore.addToast('Код теста скопирован', 'success');
  }

  const duration = (seconds = 0) => `${Math.floor(seconds / 60)}:${String(Math.max(0, seconds % 60)).padStart(2, '0')}`;
  const status = (value) => ({ waiting: 'Лобби открыто', active: 'Тест идёт', finished: 'Тест завершён' }[value] || value);
</script>

<svelte:head><title>{quiz?.title || 'Тест'} | JARQ</title></svelte:head>
<section class="shell max-w-4xl py-8">
  {#if loading}
    <p class="state">Загружаем тест...</p>
  {:else if quiz}
    <header class="hero card">
      <div><span class:live={quiz.status === 'active'} class="status">{status(quiz.status)}</span><h1>{quiz.title}</h1>{#if quiz.description}<p>{quiz.description}</p>{/if}</div>
      <div class="metrics"><span><Users size={17}/>{quiz.participants_count} участников</span><span><Clock3 size={17}/>{duration(quiz.time_remaining_seconds)}</span></div>
      {#if quiz.is_owner}
        <div class="code"><small>Код подключения</small><strong>{quiz.join_code}</strong><button on:click={copyCode}><Copy size={17}/> Копировать</button></div>
      {/if}
    </header>

    {#if quiz.is_owner}
      <section class="owner card">
        <div><h2>Панель создателя</h2><p>{quiz.status === 'waiting' ? 'Отправь код ученикам. Только ты решаешь, когда начнётся тест.' : quiz.status === 'active' ? 'Тест запущен. Участники отвечают прямо сейчас.' : 'Тест завершён. Ниже доступен рейтинг.'}</p></div>
        {#if quiz.status === 'waiting'}<button class="primary" on:click={start}><Play size={18}/> Начать тест</button>{/if}
        {#if quiz.status === 'active'}<button class="finish" on:click={finish}><Square size={17}/> Завершить</button>{/if}
      </section>
    {:else if quiz.status === 'waiting'}
      <section class="waiting card"><Clock3 size={35}/><h2>Ты в лобби</h2><p>Тест начнётся, когда создатель нажмёт кнопку старта. Страница обновится автоматически.</p></section>
    {:else if canAnswer}
      <section class="questions">
        {#each quiz.questions as question, index}
          <article class="question card">
            <header><span>{index + 1}</span><h2>{question.body}</h2><b>{question.points} баллов</b></header>
            <div class="options">
              {#each question.options as option, optionIndex}
                <label class:selected={answers[question.id] === optionIndex}><input type="radio" bind:group={answers[question.id]} value={optionIndex}/><span>{String.fromCharCode(65 + optionIndex)}</span><strong>{option}</strong></label>
              {/each}
            </div>
          </article>
        {/each}
        {#if error}<p class="error">{error}</p>{/if}
        <button class="submit" disabled={submitting} on:click={submit}>{submitting ? 'Отправляем...' : 'Завершить и отправить ответы'}</button>
      </section>
    {:else if submitted}
      <section class="waiting card"><CheckCircle2 size={38}/><h2>Ответы приняты</h2><p>Твой результат: <strong>{quiz.participant.score} баллов</strong>. Дождись завершения теста.</p></section>
    {/if}

    {#if quiz.status === 'finished' || quiz.is_owner}
      <section class="leaderboard card">
        <h2><Trophy size={21}/> Рейтинг</h2>
        {#each results as participant, index}
          <div><b>{index + 1}</b><span><strong>{participant.user?.display_name || participant.user?.username || 'Участник'}</strong><small>{participant.submitted_at ? 'Ответ отправлен' : 'Ещё отвечает'}</small></span><em>{participant.score} баллов</em></div>
        {:else}
          <p>Участники пока не подключились.</p>
        {/each}
      </section>
    {/if}
  {:else}
    <p class="state">{error || 'Тест не найден'}</p>
  {/if}
</section>

<style>
  .hero{display:grid;gap:15px;padding:20px}.status{display:inline-flex;border-radius:999px;background:#27272c;padding:5px 9px;color:var(--text-2);font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.7px}.status.live{background:#3f1d2e;color:#fb7185}h1{margin-top:9px;font-size:32px;font-weight:950}.hero p,.owner p,.waiting p{margin-top:5px;color:var(--text-2)}.metrics{display:flex;flex-wrap:wrap;gap:14px}.metrics span{display:flex;align-items:center;gap:6px;color:#d4d4d8;font-size:14px}.code{display:flex;align-items:center;gap:12px;border-top:1px solid var(--border);padding-top:14px}.code small{color:var(--text-2)}.code strong{color:#b6afff;font-size:22px;letter-spacing:3px}.code button,.primary,.finish{display:flex;align-items:center;gap:5px;border-radius:999px;padding:9px 13px;font-weight:800}.code button{margin-left:auto;background:#28282d}.owner{display:flex;align-items:center;justify-content:space-between;gap:14px;margin-top:14px;padding:17px}.owner h2,.waiting h2,.leaderboard h2{font-size:20px}.primary{background:var(--primary)}.finish{background:#44232a;color:#fda4af}.waiting{display:grid;justify-items:center;gap:8px;margin-top:14px;padding:35px;text-align:center;color:#a89fff}.waiting p{max-width:520px}.questions{display:grid;gap:12px;margin-top:15px}.question{padding:16px}.question header{display:grid;grid-template-columns:auto 1fr auto;gap:9px;align-items:start}.question header span{display:grid;width:28px;height:28px;place-items:center;border-radius:9px;background:var(--primary-soft);color:#b6afff;font-weight:900}.question header h2{font-size:18px}.question header b{color:var(--text-2);font-size:12px}.options{display:grid;grid-template-columns:1fr 1fr;gap:9px;margin-top:14px}.options label{display:flex;align-items:center;gap:9px;border:1px solid var(--border);border-radius:12px;padding:11px;cursor:pointer}.options label.selected{border-color:#8d84ef;background:var(--primary-soft)}.options input{display:none}.options span{display:grid;width:27px;height:27px;flex:none;place-items:center;border-radius:8px;background:#28282d;color:#d8d5ff}.submit{border-radius:13px;background:var(--primary);padding:14px;font-weight:900}.error{color:#f87171}.leaderboard{margin-top:15px;padding:17px}.leaderboard h2{display:flex;align-items:center;gap:7px;margin-bottom:10px}.leaderboard>div{display:flex;align-items:center;gap:10px;border-top:1px solid var(--border);padding:11px 0}.leaderboard>div>b{display:grid;width:27px;height:27px;place-items:center;border-radius:50%;background:#28282d}.leaderboard span{display:grid;flex:1}.leaderboard small,.leaderboard p{color:var(--text-2)}.leaderboard em{color:#b6afff;font-size:14px;font-style:normal;font-weight:900}.state{padding:80px 0;color:var(--text-2);text-align:center}@media(max-width:600px){h1{font-size:27px}.code{flex-wrap:wrap}.code button{margin-left:0}.owner{display:grid}.options{grid-template-columns:1fr}.question{padding:14px}.question header{grid-template-columns:auto 1fr}.question header b{grid-column:2}}
</style>
