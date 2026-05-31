<script>
  import { goto } from '$app/navigation';
  import { dashboard } from '$lib/api';
  import { authStore, toastStore } from '$lib/stores';
  import Avatar from '$lib/components/Avatar.svelte';
  let display_name = '', username = '', bio = '', current = '', password = '', confirm = '';
  let avatarFile, avatarPreview = '', initialized = false, saving = false, passwordError = '';
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');
  $: if ($authStore.user && !initialized) {
    display_name = $authStore.user.display_name || '';
    username = $authStore.user.username || '';
    bio = $authStore.user.bio || '';
    initialized = true;
  }
  $: previewUser = avatarPreview ? { ...$authStore.user, avatar_url: avatarPreview, avatar_key: null } : $authStore.user;
  function selectAvatar(file) {
    if (!file) return;
    if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.type)) return toastStore.addToast('Выбери JPG, PNG или WebP', 'error');
    if (file.size > 5 * 1024 * 1024) return toastStore.addToast('Аватар должен быть меньше 5 МБ', 'error');
    avatarFile = file;
    if (avatarPreview) URL.revokeObjectURL(avatarPreview);
    avatarPreview = URL.createObjectURL(file);
  }
  async function save() {
    saving = true;
    try {
      let user = (await dashboard.updateProfile({ display_name, username, bio })).user;
      if (avatarFile) user = (await dashboard.uploadAvatar(avatarFile)).user;
      authStore.setUser(user);
      avatarFile = null;
      toastStore.addToast('Профиль сохранён', 'success');
    } catch (requestError) { toastStore.addToast(requestError?.data?.error || 'Не удалось сохранить профиль', 'error'); }
    finally { saving = false; }
  }
  async function changePassword() {
    passwordError = '';
    if (password !== confirm) return passwordError = 'Пароли не совпадают';
    try {
      await dashboard.updatePassword({ current_password: current, new_password: password });
      authStore.logout();
      goto('/login');
    } catch (requestError) { passwordError = requestError?.data?.error === 'invalid_current_password' ? 'Неверный текущий пароль' : requestError?.data?.error || 'Не удалось изменить пароль'; }
  }
</script>
<svelte:head><title>Настройки | JARQ</title></svelte:head>
<section class="shell max-w-3xl py-8">
  <h1>Настройки профиля</h1>
  <section class="card block">
    <h2>Профиль</h2>
    <div class="avatar"><Avatar user={previewUser} size={92}/><label class="btn-secondary">Загрузить фото<input type="file" accept="image/jpeg,image/png,image/webp" on:change={(event) => selectAvatar(event.currentTarget.files?.[0])}/></label></div>
    <label>Имя<input class="input" bind:value={display_name} maxlength="100" placeholder="Как тебя называть" /></label>
    <label>Username<input class="input" bind:value={username} maxlength="20" pattern="[A-Za-z0-9_]{3,20}" placeholder="username" /></label>
    <label>О себе <small>{bio.length}/150</small><textarea class="input" bind:value={bio} maxlength="150" placeholder="Расскажи немного о себе"></textarea></label>
    <button class="btn" disabled={saving} on:click={save}>{saving ? 'Сохраняем...' : 'Сохранить профиль'}</button>
  </section>
  <section class="card block">
    <h2>Изменить пароль</h2>
    <input class="input" bind:value={current} type="password" placeholder="Текущий пароль" />
    <input class="input" bind:value={password} type="password" placeholder="Новый пароль" />
    <input class="input" bind:value={confirm} type="password" placeholder="Повтори новый пароль" />
    {#if passwordError}<p class="error">{passwordError}</p>{/if}
    <button class="btn-secondary" disabled={!current || !password || password !== confirm} on:click={changePassword}>Изменить пароль</button>
  </section>
</section>
<style>
  h1{margin-bottom:22px;font-size:32px;font-weight:900}.block{display:grid;gap:14px;margin-bottom:18px;padding:20px}h2{font-size:20px;font-weight:800}label{color:#a3a3a3;font-size:13px;font-weight:700}label small{float:right}.avatar{display:flex;align-items:center;gap:16px}.avatar label{color:white}.avatar input{display:none}textarea{min-height:96px;resize:vertical}.error{color:#f87171}
</style>
