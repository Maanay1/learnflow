<script>
  import { goto } from '$app/navigation';
  import { dashboard } from '$lib/api';
  import { authStore, toastStore } from '$lib/stores';
  import Modal from '$lib/components/Modal.svelte';
  let display_name = '', bio = '', avatar_key = '', current = '', password = '', confirm = '', danger = false, deletePassword = '';
  $: if (!$authStore.loading && !$authStore.authenticated) goto('/login');
  $: if ($authStore.user && !display_name) { display_name = $authStore.user.display_name || ''; bio = $authStore.user.bio || ''; avatar_key = $authStore.user.avatar_key || ''; }
  async function save() { const { user } = await dashboard.updateProfile({ display_name, bio, avatar_key }); authStore.setUser(user); toastStore.addToast('Профиль сохранён', 'success'); }
  async function exportData() { const data = await dashboard.exportData(); const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })); a.download = 'learnflow-export.json'; a.click(); }
</script>

<section class="shell max-w-3xl space-y-8 py-8">
  <h1 class="text-3xl font-black">Settings</h1>
  <section class="card space-y-4 p-5"><h2 class="text-xl font-bold">Profile</h2><input class="input" bind:value={display_name} placeholder="Display name" /><input class="input" bind:value={avatar_key} placeholder="Avatar key" /><textarea class="input min-h-28" bind:value={bio} placeholder="Bio"></textarea><button class="btn" on:click={save}>Save</button></section>
  <section class="card space-y-4 p-5"><h2 class="text-xl font-bold">Password</h2><input class="input" bind:value={current} type="password" placeholder="Current password" /><input class="input" bind:value={password} type="password" placeholder="New password" /><input class="input" bind:value={confirm} type="password" placeholder="Confirm" /><button class="btn-secondary" disabled={password !== confirm}>Change password</button></section>
  <section class="rounded-xl border border-[#ef4444]/30 bg-[#ef4444]/10 p-5"><h2 class="text-xl font-bold text-[#ef4444]">Danger zone</h2><div class="mt-4 flex gap-3"><button class="btn-secondary" on:click={exportData}>Export data</button><button class="rounded-xl bg-[#ef4444] px-4 py-2 font-bold" on:click={() => (danger = true)}>Удалить аккаунт</button></div></section>
</section>

<Modal open={danger} title="Удалить аккаунт" onClose={() => (danger = false)}>
  <div class="space-y-4"><input class="input" bind:value={deletePassword} type="password" placeholder="Password" /><button class="rounded-xl bg-[#ef4444] px-4 py-2 font-bold">Confirm delete</button></div>
</Modal>
