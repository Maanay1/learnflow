<script>
  import { search, dashboard } from '$lib/api';
  import { authStore } from '$lib/stores';
  let username = '', available = false, checking = false, error = '', timer;
  $: open = $authStore.user?.requires_username_setup;
  $: {
    username;
    clearTimeout(timer);
    available = false;
    error = '';
    if (open && /^[A-Za-z0-9_]{3,20}$/.test(username)) {
      checking = true;
      timer = setTimeout(check, 500);
    } else checking = false;
  }
  async function check() {
    try { available = (await search.usernameAvailable(username)).available; }
    catch { available = false; }
    finally { checking = false; }
  }
  async function save() {
    if (!available) return;
    try { authStore.setUser((await dashboard.updateProfile({ username })).user); }
    catch (requestError) { error = requestError?.data?.error || 'Не удалось сохранить имя'; }
  }
</script>
{#if open}
  <div class="overlay">
    <section>
      <h2>Выбери имя пользователя</h2>
      <p>Так тебя будут находить другие пользователи JARQ.</p>
      <label><span>@</span><input bind:value={username} maxlength="20" placeholder="username" />{#if checking}<b>...</b>{:else if available}<b class="ok">✓</b>{:else if username}<b class="bad">✗</b>{/if}</label>
      <small>3-20 символов: латинские буквы, цифры и _</small>
      {#if error}<em>{error}</em>{/if}
      <button disabled={!available} on:click={save}>Продолжить</button>
    </section>
  </div>
{/if}
<style>
  .overlay{position:fixed;inset:0;z-index:100;display:grid;place-items:center;background:rgba(0,0,0,.86);padding:20px}section{width:min(100%,420px);border:1px solid var(--border);border-radius:20px;background:#111;padding:28px}h2{font-size:24px;font-weight:900}p,small{display:block;margin-top:9px;color:#a3a3a3}label{display:flex;height:50px;align-items:center;gap:5px;margin-top:20px;border:1px solid #333;border-radius:11px;padding:0 14px}input{min-width:0;flex:1;background:transparent;color:white;outline:0}.ok{color:#4ade80}.bad,em{color:#f87171}em{display:block;margin-top:9px;font-style:normal}button{width:100%;height:48px;margin-top:20px;border-radius:11px;background:var(--accent);font-weight:800}button:disabled{cursor:not-allowed;opacity:.4}
</style>
