<script>
  import { goto } from '$app/navigation';
  import { Plus, Trash2 } from 'lucide-svelte';
  import { quizzes } from '$lib/api';
  import { authStore } from '$lib/stores';

  const blankQuestion = () => ({ body: '', options: ['', '', '', ''], correct_option: 0, points: 100 });
  let title = '', description = '', minutes = 10, questions = [blankQuestion()], saving = false, error = '';
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');

  function addQuestion() {
    questions = [...questions, blankQuestion()];
  }

  function removeQuestion(index) {
    if (questions.length === 1) return;
    questions = questions.filter((_, questionIndex) => questionIndex !== index);
  }

  async function create() {
    error = '';
    if (!title.trim()) return error = 'Добавь название теста';
    if (questions.some((question) => !question.body.trim() || question.options.some((option) => !option.trim()))) return error = 'Заполни вопрос и все четыре варианта ответа';
    saving = true;
    try {
      const { quiz } = await quizzes.create({ title, description, time_limit_seconds: Number(minutes) * 60, questions });
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
    <label>Время на весь тест<select class="input" bind:value={minutes}><option value={5}>5 минут</option><option value={10}>10 минут</option><option value={15}>15 минут</option><option value={30}>30 минут</option><option value={60}>60 минут</option></select></label>
  </section>
  <div class="questions-head"><h2>Вопросы</h2><button on:click={addQuestion}><Plus size={17}/> Добавить вопрос</button></div>
  {#each questions as question, index}
    <section class="card question">
      <header><strong>Вопрос {index + 1}</strong><button class="remove" disabled={questions.length === 1} on:click={() => removeQuestion(index)} aria-label="Удалить вопрос"><Trash2 size={17}/></button></header>
      <textarea class="input" bind:value={question.body} maxlength="500" placeholder="Введите вопрос"></textarea>
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
  .eyebrow{color:#a89fff;font-size:11px;font-weight:900;letter-spacing:1.6px}h1{margin-top:4px;font-size:34px;font-weight:950}header p{max-width:700px;margin-top:7px;color:var(--text-2)}.setup{display:grid;gap:13px;margin-top:22px;padding:18px}label{display:grid;gap:6px;color:var(--text-2);font-size:13px;font-weight:800}textarea{min-height:80px;resize:vertical}.questions-head{display:flex;align-items:center;justify-content:space-between;margin:24px 0 12px}.questions-head h2{font-size:23px}.questions-head button{display:flex;align-items:center;gap:4px;color:#a89fff;font-weight:800}.question{display:grid;gap:13px;margin-bottom:12px;padding:17px}.question header{display:flex;align-items:center;justify-content:space-between}.remove{color:#f87171}.remove:disabled{opacity:.25}.options{display:grid;grid-template-columns:1fr 1fr;gap:9px}.options label{display:flex;align-items:center;gap:8px;border:1px solid var(--border);border-radius:12px;background:#121214;padding:8px}.options label.correct{border-color:#7f77dd;background:var(--primary-soft)}.options label>input:first-child{display:none}.options span{display:grid;width:28px;height:28px;flex:none;place-items:center;border-radius:9px;background:#27272c;color:#d8d5ff}.options label>input:last-child{min-width:0;flex:1;background:transparent;color:white;outline:0}.points{max-width:210px}.error{margin:10px 0;color:#f87171}.save{width:100%;border-radius:13px;background:var(--primary);padding:14px;font-weight:900}@media(max-width:580px){h1{font-size:29px}.options{grid-template-columns:1fr}.question{padding:14px}}
</style>
