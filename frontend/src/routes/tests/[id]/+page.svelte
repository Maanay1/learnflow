<script>
  import { onDestroy, onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { CheckCircle2, Clock3, Copy, Play, Square, Trophy, Users } from 'lucide-svelte';
  import { quizzes } from '$lib/api';
  import { authStore, toastStore } from '$lib/stores';

  let quiz, loading = true, error = '', answers = {}, submitting = false, results = [], timer, questionTimer, currentIndex = 0, questionLeft = 0, timerQuestionId = '';
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');
  $: submitted = Boolean(quiz?.participant?.submitted_at);
  $: canAnswer = quiz?.status === 'active' && !quiz?.is_owner && !submitted;
  $: currentQuestion = quiz?.questions?.[currentIndex];
  $: questionSeconds = Number(quiz?.question_time_seconds || 30);
  $: progress = quiz?.questions?.length ? Math.round(((currentIndex + 1) / quiz.questions.length) * 100) : 0;
  $: reviewAnswers = quiz?.participant?.answers || results.find((item) => item.user?.id === $authStore.user?.id)?.answers || [];
  $: if (canAnswer && currentQuestion?.id && timerQuestionId !== currentQuestion.id) resetQuestionTimer();

  onMount(async () => {
    await load();
    timer = setInterval(load, 2000);
    questionTimer = setInterval(tickQuestion, 1000);
  });
  onDestroy(() => { clearInterval(timer); clearInterval(questionTimer); });

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
    submitting = true;
    error = '';
    try {
      const payload = quiz.questions.map((question) => ({ question_id: question.id, selected_option: answers[question.id] ?? -1 }));
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
  function resetQuestionTimer() {
    timerQuestionId = currentQuestion?.id || '';
    questionLeft = questionSeconds;
  }
  function tickQuestion() {
    if (!canAnswer || !currentQuestion) return;
    questionLeft = Math.max(0, questionLeft - 1);
    if (questionLeft === 0) {
      if (answers[currentQuestion.id] === undefined) answers = { ...answers, [currentQuestion.id]: -1 };
      nextQuestion();
    }
  }
  function selectAnswer(optionIndex) {
    if (!canAnswer || !currentQuestion) return;
    answers = { ...answers, [currentQuestion.id]: optionIndex };
  }
  function nextQuestion() {
    if (!quiz?.questions?.length || submitting) return;
    if (currentIndex < quiz.questions.length - 1) currentIndex += 1;
    else submit();
  }
  function answerClass(answer, optionIndex) {
    if (answer.question?.correct_option === optionIndex) return 'correct';
    if (answer.selected_option === optionIndex && !answer.correct) return 'wrong';
    return '';
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
      <div class="metrics"><span><Users size={17}/>{quiz.participants_count} участников</span><span><Clock3 size={17}/>{duration(quiz.time_remaining_seconds)}</span><span>{quiz.question_time_seconds || 30} сек. на вопрос</span></div>
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
        <article class="question quiz-step card">
          <div class="step-head">
            <span>Вопрос {currentIndex + 1} из {quiz.questions.length}</span>
            <b class:urgent={questionLeft <= 8}>{questionLeft}s</b>
          </div>
          <div class="progress"><i style={`width:${progress}%`}></i></div>
          <h2>{currentQuestion.body}</h2>
          {#if currentQuestion.image_url}<img class="question-media" src={currentQuestion.image_url} alt="Материал к вопросу" />{/if}
          <div class="options single">
            {#each currentQuestion.options as option, optionIndex}
              <button class:selected={answers[currentQuestion.id] === optionIndex} on:click={() => selectAnswer(optionIndex)}><span>{String.fromCharCode(65 + optionIndex)}</span><strong>{option}</strong></button>
            {/each}
          </div>
          <button class="submit" disabled={answers[currentQuestion.id] === undefined || submitting} on:click={nextQuestion}>{currentIndex === quiz.questions.length - 1 ? 'Отправить ответы' : 'Дальше'}</button>
        </article>
        {#if error}<p class="error">{error}</p>{/if}
      </section>
    {:else if submitted}
      <section class="waiting card"><CheckCircle2 size={38}/><h2>Ответы приняты</h2><p>Твой результат: <strong>{quiz.participant.score} баллов</strong>. Ниже видно, где ты ошибся.</p></section>
    {/if}

    {#if submitted && reviewAnswers.length}
      <section class="review card">
        <h2>Разбор ответов</h2>
        {#each reviewAnswers as answer, index}
          <article>
            <h3>{index + 1}. {answer.question?.body}</h3>
            {#if answer.question?.image_url}<img class="question-media small" src={answer.question.image_url} alt="Материал к вопросу" />{/if}
            <div class="review-options">
              {#each answer.question?.options || [] as option, optionIndex}
                <span class={answerClass(answer, optionIndex)}>{String.fromCharCode(65 + optionIndex)}. {option}</span>
              {/each}
            </div>
            <p>{answer.correct ? 'Верно' : answer.selected_option === -1 ? 'Время вышло, ответ не выбран' : 'Ошибка'} · {answer.points_awarded} баллов</p>
          </article>
        {/each}
      </section>
    {/if}

    {#if quiz.status === 'finished' || quiz.is_owner}
      <section class="leaderboard card">
        <h2><Trophy size={21}/> Рейтинг</h2>
        {#each results as participant, index}
          <div class="participant-row"><b>{index + 1}</b><span><strong>{participant.user?.display_name || participant.user?.username || 'Участник'}</strong><small>{participant.submitted_at ? `Ошибок: ${(participant.answers || []).filter((answer) => !answer.correct).length}` : 'Ещё отвечает'}</small></span><em>{participant.score} баллов</em></div>
          {#if participant.answers?.length}
            <details>
              <summary>Ответы участника</summary>
              {#each participant.answers as answer}
                <p class:bad={!answer.correct}><strong>{answer.question?.body}</strong><span>{answer.correct ? 'верно' : answer.selected_option === -1 ? 'не ответил' : `выбрал ${String.fromCharCode(65 + answer.selected_option)}`}</span></p>
              {/each}
            </details>
          {/if}
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
  .hero{display:grid;gap:15px;padding:20px}.status{display:inline-flex;border-radius:999px;background:#27272c;padding:5px 9px;color:var(--text-2);font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.7px}.status.live{background:#3f1d2e;color:#fb7185}h1{margin-top:9px;font-size:32px;font-weight:950}.hero p,.owner p,.waiting p{margin-top:5px;color:var(--text-2)}.metrics{display:flex;flex-wrap:wrap;gap:14px}.metrics span{display:flex;align-items:center;gap:6px;color:#d4d4d8;font-size:14px}.code{display:flex;align-items:center;gap:12px;border-top:1px solid var(--border);padding-top:14px}.code small{color:var(--text-2)}.code strong{color:#b6afff;font-size:22px;letter-spacing:3px}.code button,.primary,.finish{display:flex;align-items:center;gap:5px;border-radius:999px;padding:9px 13px;font-weight:800}.code button{margin-left:auto;background:#28282d}.owner{display:flex;align-items:center;justify-content:space-between;gap:14px;margin-top:14px;padding:17px}.owner h2,.waiting h2,.leaderboard h2{font-size:20px}.primary{background:var(--primary)}.finish{background:#44232a;color:#fda4af}.waiting{display:grid;justify-items:center;gap:8px;margin-top:14px;padding:35px;text-align:center;color:#a89fff}.waiting p{max-width:520px}.questions{display:grid;gap:12px;margin-top:15px}.question{padding:16px}.quiz-step{display:grid;gap:14px}.step-head{display:flex;align-items:center;justify-content:space-between;color:var(--text-2);font-size:13px;font-weight:900}.step-head b{display:grid;min-width:50px;height:36px;place-items:center;border-radius:999px;background:var(--primary-soft);color:#d8d5ff}.step-head b.urgent{background:#451a1f;color:#fda4af}.progress{height:7px;overflow:hidden;border-radius:999px;background:#25252a}.progress i{display:block;height:100%;border-radius:inherit;background:var(--primary)}.question h2{font-size:22px}.question-media{width:100%;max-height:300px;object-fit:cover;border:1px solid var(--border);border-radius:12px;background:#111}.question-media.small{max-height:180px}.options{display:grid;grid-template-columns:1fr 1fr;gap:9px;margin-top:4px}.options button{display:flex;align-items:center;gap:9px;border:1px solid var(--border);border-radius:12px;padding:12px;text-align:left;cursor:pointer}.options button.selected{border-color:#8d84ef;background:var(--primary-soft)}.options span{display:grid;width:27px;height:27px;flex:none;place-items:center;border-radius:8px;background:#28282d;color:#d8d5ff}.submit{border-radius:13px;background:var(--primary);padding:14px;font-weight:900}.submit:disabled{opacity:.45}.error{color:#f87171}.review{display:grid;gap:12px;margin-top:15px;padding:17px}.review h2{font-size:20px}.review article{display:grid;gap:9px;border-top:1px solid var(--border);padding-top:12px}.review h3{font-size:15px}.review-options{display:grid;gap:6px}.review-options span{border:1px solid var(--border);border-radius:10px;padding:8px;color:var(--text-2)}.review-options .correct{border-color:#22c55e;background:#052e1a;color:#bbf7d0}.review-options .wrong{border-color:#f87171;background:#3b1116;color:#fecdd3}.review p{color:var(--text-2);font-size:13px}.leaderboard{margin-top:15px;padding:17px}.leaderboard h2{display:flex;align-items:center;gap:7px;margin-bottom:10px}.participant-row{display:flex;align-items:center;gap:10px;border-top:1px solid var(--border);padding:11px 0}.participant-row>b{display:grid;width:27px;height:27px;place-items:center;border-radius:50%;background:#28282d}.leaderboard span{display:grid;flex:1}.leaderboard small,.leaderboard p{color:var(--text-2)}.leaderboard em{color:#b6afff;font-size:14px;font-style:normal;font-weight:900}.leaderboard details{border-top:1px solid var(--border);padding:0 0 10px 37px}.leaderboard summary{cursor:pointer;color:#a89fff;font-size:13px;font-weight:800}.leaderboard details p{display:grid;grid-template-columns:1fr auto;gap:10px;padding:6px 0;font-size:12px}.leaderboard details p.bad span{color:#fca5a5}.state{padding:80px 0;color:var(--text-2);text-align:center}@media(max-width:600px){h1{font-size:27px}.code{flex-wrap:wrap}.code button{margin-left:0}.owner{display:grid}.options{grid-template-columns:1fr}.question{padding:14px}.leaderboard details{padding-left:0}.leaderboard details p{grid-template-columns:1fr}}
</style>
