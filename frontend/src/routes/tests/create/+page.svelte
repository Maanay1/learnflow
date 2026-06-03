<script>
  import { goto } from '$app/navigation';
  import { Plus, Trash2 } from 'lucide-svelte';
  import { quizzes } from '$lib/api';
  import { authStore } from '$lib/stores';

  const blankQuestion = () => ({ body: '', image_url: '', options: ['', '', '', ''], correct_option: 0, points: 100 });
  let title = '', description = '', questionSeconds = 30, questions = [blankQuestion()], saving = false, error = '', invalidQuestion = -1;
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');

  function addQuestion() {
    questions = [...questions, blankQuestion()];
  }

  function removeQuestion(index) {
    if (questions.length === 1) return;
    questions = questions.filter((_, questionIndex) => questionIndex !== index);
  }

  function questionError(question) {
    if (!question.body.trim()) return 'добавь текст вопроса';
    const optionIndex = question.options.findIndex((option) => !option.trim());
    return optionIndex === -1 ? '' : `заполни вариант ${String.fromCharCode(65 + optionIndex)}`;
  }

  async function create() {
    error = '';
    invalidQuestion = -1;
    if (!title.trim()) return error = 'Добавь название теста';
    const questionIndex = questions.findIndex((question) => questionError(question));
    if (questionIndex !== -1) {
      invalidQuestion = questionIndex;
      error = `Вопрос ${questionIndex + 1}: ${questionError(questions[questionIndex])}`;
      requestAnimationFrame(() => document.getElementById(`question-${questionIndex}`)?.scrollIntoView({ behavior: 'smooth', block: 'center' }));
      return;
    }
    saving = true;
    try {
      const seconds = Number(questionSeconds) || 30;
      const cleanedQuestions = questions.map((question) => ({ ...question, image_url: question.image_url?.trim() || null }));
      const { quiz } = await quizzes.create({ title, description, question_time_seconds: seconds, time_limit_seconds: Math.max(30, seconds * questions.length), questions: cleanedQuestions });
      goto(`/tests/${quiz.id}`);
    } catch (requestError) {
      error = requestError?.data?.error || 'Не удалось создать тест';
    } finally {
      saving = false;
    }
  }
</script>

<svelte:head><title>Создать тест | JARQ</title></svelte:head>
<section class="shell max-w-3xl py-8">
  <header><span class="eyebrow">JARQ CLASSROOM</span><h1>Новый live-тест</h1><p>После создания ты получишь код. Ученики войдут в лобби, а тест начнётся только по твоей команде.</p></header>
  <section class="card setup">
    <label>Название<input class="input" bind:value={title} maxlength="160" placeholder="Например: Основы JavaScript"/></label>
    <label>Описание<textarea class="input" bind:value={description} placeholder="Что проверяем на этом тесте"></textarea></label>
    <label>Время на один вопрос<select class="input" bind:value={questionSeconds}><option value={15}>15 секунд</option><option value={30}>30 секунд</option><option value={45}>45 секунд</option><option value={60}>1 минута</option><option value={120}>2 минуты</option></select></label>
  </section>
  <div class="questions-head"><h2>Вопросы</h2><button on:click={addQuestion}><Plus size={17}/> Добавить вопрос</button></div>
  {#each questions as question, index}
    <section id={`question-${index}`} class="card question" class:invalid={invalidQuestion === index}>
      <header><strong>Вопрос {index + 1}</strong><button class="remove" disabled={questions.length === 1} on:click={() => removeQuestion(index)} aria-label="Удалить вопрос"><Trash2 size={17}/></button></header>
      <textarea class="input" bind:value={question.body} maxlength="500" placeholder="Введите вопрос"></textarea>
      <input class="input" bind:value={question.image_url} maxlength="1000" placeholder="Ссылка на фото или материал (необязательно)" />
      {#if question.image_url}<img class="preview" src={question.image_url} alt="Превью вопроса" />{/if}
      <div class="options">
        {#each question.options as option, optionIndex}
          <label class:correct={question.correct_option === optionIndex}>
            <input type="radio" bind:group={question.correct_option} value={optionIndex}/>
            <span>{String.fromCharCode(65 + optionIndex)}</span>
            <input bind:value={question.options[optionIndex]} placeholder={`Вариант ${String.fromCharCode(65 + optionIndex)}`}/>
          </label>
        {/each}
      </div>
      <label class="points">Баллы за правильный ответ<input class="input" type="number" min="1" max="10000" bind:value={question.points}/></label>
    </section>
  {/each}
  {#if error}<p class="error">{error}</p>{/if}
  <button class="save" disabled={saving} on:click={create}>{saving ? 'Создаём...' : 'Создать тест и получить код'}</button>
</section>

<style>
  .eyebrow{color:#a89fff;font-size:11px;font-weight:900;letter-spacing:1.6px}h1{margin-top:4px;font-size:34px;font-weight:950}header p{max-width:700px;margin-top:7px;color:var(--text-2)}.setup{display:grid;gap:13px;margin-top:22px;padding:18px}label{display:grid;gap:6px;color:var(--text-2);font-size:13px;font-weight:800}textarea{min-height:80px;resize:vertical}.questions-head{display:flex;align-items:center;justify-content:space-between;margin:24px 0 12px}.questions-head h2{font-size:23px}.questions-head button{display:flex;align-items:center;gap:4px;color:#a89fff;font-weight:800}.question{display:grid;gap:13px;margin-bottom:12px;padding:17px}.question.invalid{border-color:#f87171;box-shadow:0 0 0 1px #f8717144}.question header{display:flex;align-items:center;justify-content:space-between}.preview{width:100%;max-height:260px;object-fit:cover;border:1px solid var(--border);border-radius:12px;background:#111}.remove{color:#f87171}.remove:disabled{opacity:.25}.options{display:grid;grid-template-columns:1fr 1fr;gap:9px}.options label{display:flex;align-items:center;gap:8px;border:1px solid var(--border);border-radius:12px;background:#121214;padding:8px}.options label.correct{border-color:#7f77dd;background:var(--primary-soft)}.options label>input:first-child{display:none}.options span{display:grid;width:28px;height:28px;flex:none;place-items:center;border-radius:9px;background:#27272c;color:#d8d5ff}.options label>input:last-child{min-width:0;flex:1;background:transparent;color:white;outline:0}.points{max-width:210px}.error{margin:10px 0;color:#f87171}.save{width:100%;border-radius:13px;background:var(--primary);padding:14px;font-weight:900}@media(max-width:580px){h1{font-size:29px}.options{grid-template-columns:1fr}.question{padding:14px}}
</style>
