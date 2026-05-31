<script>
  import { goto } from '$app/navigation';
  import { Eye, EyeOff } from 'lucide-svelte';
  import { API_BASE, auth } from '$lib/api';
  import { authStore } from '$lib/stores';

  export let initialMode = 'login';
  let mode = initialMode;
  let username = '', email = '', password = '', confirmPassword = '';
  let showPassword = false, error = '', loading = false;
  $: registering = mode === 'register';

  async function submit() {
    error = '';
    if (registering && password !== confirmPassword) return error = 'Пароли не совпадают';
    loading = true;
    try {
      const body = registering ? { username, email, password } : { email, password };
      const { user } = registering ? await auth.register(body) : await auth.login(body);
      authStore.login(user);
      goto('/feed');
    } catch (requestError) {
      error = requestError?.data?.error || (registering ? 'Не удалось зарегистрироваться' : 'Неверный email или пароль');
    } finally {
      loading = false;
    }
  }
</script>

<section class="auth-page">
  <form class="card" on:submit|preventDefault={submit}>
    <a class="logo" href="/feed">LearnFlow</a>
    <p class="subtitle">Учись. Общайся. Развивайся.</p>
    <button class="google" type="button" on:click={() => (window.location.href = `${API_BASE}/auth/google`)}>
      <svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path fill="#4285F4" d="M22.6 12.2c0-.7-.1-1.5-.2-2.2H12v4.3h6a5.1 5.1 0 0 1-2.2 3.3v2.8h3.6c2.1-2 3.2-4.8 3.2-8.2Z"/><path fill="#34A853" d="M12 23c3 0 5.5-1 7.4-2.6l-3.6-2.8c-1 .7-2.3 1-3.8 1a6.5 6.5 0 0 1-6.1-4.5H2.2V17A11.2 11.2 0 0 0 12 23Z"/><path fill="#FBBC05" d="M5.9 14.1a6.7 6.7 0 0 1 0-4.2V7H2.2a11.1 11.1 0 0 0 0 10l3.7-2.9Z"/><path fill="#EA4335" d="M12 5.4c1.8 0 3.4.6 4.7 1.8l3.5-3.4A11 11 0 0 0 2.2 7l3.7 2.9A6.5 6.5 0 0 1 12 5.4Z"/></svg>
      Войти через Google
    </button>
    <div class="divider"><span></span><b>или</b><span></span></div>
    {#if registering}<input bind:value={username} autocomplete="username" placeholder="Имя пользователя" required />{/if}
    <input bind:value={email} type="email" autocomplete="email" placeholder="Email" required />
    <label><input bind:value={password} type={showPassword ? 'text' : 'password'} autocomplete={registering ? 'new-password' : 'current-password'} placeholder="Пароль" required /><button type="button" on:click={() => (showPassword = !showPassword)} aria-label="Показать пароль">{#if showPassword}<EyeOff size={18} />{:else}<Eye size={18} />{/if}</button></label>
    {#if registering}<input bind:value={confirmPassword} type="password" autocomplete="new-password" placeholder="Повторите пароль" required />{/if}
    {#if error}<p class="error">{error}</p>{/if}
    <button class="submit" disabled={loading}>{loading ? 'Подождите...' : registering ? 'Зарегистрироваться' : 'Войти'}</button>
    <p class="toggle">{registering ? 'Уже есть аккаунт?' : 'Нет аккаунта?'} <button type="button" on:click={() => { mode = registering ? 'login' : 'register'; error = ''; }}>{registering ? 'Войти' : 'Зарегистрироваться'}</button></p>
  </form>
</section>

<style>
  :global(main){padding-left:0}:global(.desktop-sidebar),:global(.mobile-nav){display:none}.auth-page{display:grid;min-height:100vh;place-items:center;background:#000;padding:20px}.card{width:min(100%,420px);border:1px solid rgba(255,255,255,.1);border-radius:20px;background:#111;padding:40px}.logo{display:block;background:linear-gradient(135deg,#6366f1,#a855f7,#ec4899);background-clip:text;color:transparent;text-align:center;font-size:32px;font-weight:900}.subtitle{margin:8px 0 28px;color:#a3a3a3;text-align:center}.google,.submit{display:flex;width:100%;height:52px;align-items:center;justify-content:center;gap:12px;border-radius:12px;font-size:16px;font-weight:600}.google{background:white;color:black}.google:hover{background:#f5f5f5;box-shadow:0 8px 22px rgba(255,255,255,.08)}.divider{display:grid;grid-template-columns:1fr auto 1fr;gap:12px;align-items:center;margin:20px 0;color:#737373;font-size:13px}.divider span{height:1px;background:rgba(255,255,255,.1)}input{width:100%;height:48px;margin-bottom:12px;border:1px solid rgba(255,255,255,.1);border-radius:10px;background:#1a1a1a;padding:0 16px;color:white;outline:none}input:focus{border-color:#6366f1}label{position:relative;display:block}label input{padding-right:48px}label button{position:absolute;top:0;right:0;display:grid;width:48px;height:48px;place-items:center;color:#a3a3a3}.submit{height:48px;background:linear-gradient(135deg,#6366f1,#a855f7);color:white}.error{margin:0 0 12px;color:#f87171;font-size:14px}.toggle{margin-top:20px;color:#a3a3a3;text-align:center;font-size:14px}.toggle button{color:#a78bfa;font-weight:700}
</style>
