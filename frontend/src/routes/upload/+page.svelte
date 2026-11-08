<script>
  import { goto } from '$app/navigation';
  import { UploadCloud } from 'lucide-svelte';
  import { videos } from '$lib/api';
  import { authStore } from '$lib/stores';

  const MAX_BYTES = 2_000_000_000;
  // MP4 is published instantly; other formats (iPhone MOV, WebM, ...) are converted by the server.
  const TYPES_BY_EXT = { mp4: 'video/mp4', m4v: 'video/x-m4v', mov: 'video/quicktime', webm: 'video/webm', '3gp': 'video/3gpp', mkv: 'video/x-matroska' };
  const ALLOWED_TYPES = Object.values(TYPES_BY_EXT);
  const uploadErrors = {
    storage_not_configured: 'Хранилище видео не настроено на сервере. Добавьте S3/MinIO переменные окружения.',
    invalid_video_type: 'Этот формат видео не поддерживается. Выберите MP4, MOV или WebM.',
    invalid_video_size: 'Максимальный размер видео: 2 ГБ'
  };
  const subjects = {
    mathematics: 'Математика', physics: 'Физика', chemistry: 'Химия', biology: 'Биология', programming: 'Программирование',
    history: 'История', languages: 'Языки', economics: 'Экономика', design: 'Дизайн', philosophy: 'Философия'
  };
  let title = '', description = '', subject = 'programming', difficulty = 'beginner', format = 'jq';
  let file, fileType = '', error = '', notice = '', progress = 0, uploading = false, dragging = false, duration = 0;
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');

  function selectFile(selected) {
    error = ''; notice = ''; duration = 0;
    if (!selected) return;
    const ext = (selected.name.split('.').pop() || '').toLowerCase();
    // Some phones report an empty or generic type; fall back to the file extension.
    const type = ALLOWED_TYPES.includes(selected.type) ? selected.type : TYPES_BY_EXT[ext];
    if (!type) return error = 'Выберите видео MP4, MOV или WebM';
    if (selected.size > MAX_BYTES) return error = 'Максимальный размер видео: 2 ГБ';
    file = selected;
    fileType = type;
    const video = document.createElement('video');
    video.preload = 'metadata';
    // Formats the browser cannot preview (e.g. HEVC) still upload; the server measures them.
    video.onerror = () => URL.revokeObjectURL(video.src);
    video.onloadedmetadata = () => {
      duration = Math.round(video.duration || 0);
      URL.revokeObjectURL(video.src);
      if (format === 'jq' && duration > 180) error = 'JQ должен быть короче 3 минут';
    };
    video.src = URL.createObjectURL(selected);
  }

  function upload(url) {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('PUT', url);
      xhr.setRequestHeader('Content-Type', fileType);
      xhr.upload.onprogress = (event) => { if (event.lengthComputable) progress = Math.round(event.loaded / event.total * 100); };
      xhr.onload = () => xhr.status < 400 ? resolve() : reject(new Error('Не удалось загрузить видео'));
      xhr.onerror = () => reject(new Error('Ошибка сети во время загрузки'));
      xhr.send(file);
    });
  }

  async function publish() {
    if (!title.trim() || !file) return error = 'Добавьте название и выберите видео';
    if (format === 'jq' && duration > 180) return error = 'JQ должен быть короче 3 минут';
    error = ''; notice = ''; uploading = true; progress = 0;
    try {
      const { video } = await videos.create({ title, description, difficulty, format, tags: [subject], language: 'ru' });
      const signed = await videos.uploadUrl(video.id, { content_type: fileType, file_size_bytes: file.size });
      await upload(signed.upload_url);
      const { video: published } = await videos.confirm(video.id, { video_key: signed.key, duration_seconds: duration });
      if (published.status !== 'active') {
        notice = 'Видео загружено и обрабатывается. Оно появится в ленте через несколько минут.';
        file = null; title = ''; description = ''; progress = 0;
        return;
      }
      goto(format === 'jq' ? '/jq' : `/video/${published.slug}`);
    } catch (uploadError) {
      const apiError = uploadError?.data?.error;
      error = uploadErrors[apiError] || apiError || uploadError.message || 'Не удалось опубликовать видео';
    } finally {
      uploading = false;
    }
  }

  const size = (bytes) => `${(bytes / 1024 / 1024).toFixed(1)} МБ`;
</script>

<section class="shell max-w-3xl py-10">
  <h1>Загрузить видео</h1>
  <div class="card">
    <h2>1. Формат</h2>
    <div class="formats">
      <button class:active={format === 'jq'} on:click={() => (format = 'jq')}><strong>JQ</strong><span>Вертикальный учебный ролик до 3 минут</span></button>
      <button class:active={format === 'media'} on:click={() => (format = 'media')}><strong>Медиа</strong><span>Обычное видео для подробного разбора</span></button>
    </div>
    <h2>2. Описание</h2>
    <input class="input" bind:value={title} placeholder="Название" />
    <textarea class="input" bind:value={description} placeholder="Описание"></textarea>
    <div class="grid">
      <select class="input" bind:value={subject}>{#each Object.entries(subjects) as [tag, label]}<option value={tag}>{label}</option>{/each}</select>
      <select class="input" bind:value={difficulty}><option value="beginner">Начальный</option><option value="intermediate">Средний</option><option value="advanced">Сложный</option></select>
    </div>
    <h2>3. Видео</h2>
    <label class:dragging class="drop" on:dragover|preventDefault={() => (dragging = true)} on:dragleave={() => (dragging = false)} on:drop|preventDefault={(event) => { dragging = false; selectFile(event.dataTransfer.files[0]); }}>
      <input type="file" accept="video/*,.mp4,.mov,.m4v,.webm" on:change={(event) => selectFile(event.target.files[0])} />
      <UploadCloud size={34} /><strong>{file ? file.name : 'Перетащи видео сюда или нажми для выбора'}</strong>
      <span>{file ? size(file.size) : 'MP4, MOV (iPhone) или WebM, максимум 2 ГБ'}</span>
    </label>
    <h2>4. Публикация</h2>
    {#if uploading}<div class="progress"><span style={`width:${progress}%`}></span></div><p>{progress}%</p>{/if}
    {#if error}<p class="error">{error}</p>{/if}
    {#if notice}<p class="notice">{notice}</p>{/if}
    <button class="publish" disabled={uploading} on:click={publish}>{uploading ? 'Загружаем...' : format === 'jq' ? 'Опубликовать JQ' : 'Загрузить медиа'}</button>
  </div>
</section>

<style>
  h1{margin-bottom:20px;font-size:32px;font-weight:900}.card{display:grid;gap:14px;border:1px solid var(--border);border-radius:18px;background:#111;padding:24px}h2{margin-top:8px;font-size:18px;font-weight:800}.formats,.grid{display:grid;gap:12px}.formats button{display:grid;gap:3px;border:1px solid var(--border);border-radius:14px;padding:14px;text-align:left}.formats button.active{border-color:#8d84ef;background:var(--primary-soft)}.formats span{color:var(--text-2);font-size:13px}.input{width:100%}textarea{min-height:110px}@media(min-width:640px){.formats,.grid{grid-template-columns:1fr 1fr}}.drop{display:grid;min-height:190px;place-items:center;border:1px dashed #52525b;border-radius:14px;background:#181818;padding:20px;text-align:center}.drop.dragging{border-color:#818cf8;background:#201d3b}.drop input{display:none}.drop span{color:#a3a3a3;font-size:13px}.progress{height:10px;overflow:hidden;border-radius:99px;background:#262626}.progress span{display:block;height:100%;background:linear-gradient(135deg,#6366f1,#a855f7)}.error{color:#f87171}.notice{border-radius:12px;background:var(--primary-soft);padding:12px 14px;color:#c7c2ff}.publish{height:50px;border-radius:11px;background:linear-gradient(135deg,#6366f1,#a855f7);font-weight:800}
</style>
