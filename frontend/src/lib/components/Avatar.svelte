<script>
  import { API_BASE } from '$lib/api';
  export let user = {};
  export let size = 32;
  $: name = user?.display_name || user?.username || 'LF';
  $: initials = name.split(/\s|_/).filter(Boolean).slice(0, 2).map((p) => p[0]).join('').toUpperCase();
  $: hue = [...(user?.username || name)].reduce((sum, ch) => sum + ch.charCodeAt(0), 0) % 360;
</script>

{#if user?.avatar_url || user?.avatar_key}
  <img class="rounded-full object-cover" style={`width:${size}px;height:${size}px`} src={user.avatar_url || `${API_BASE}/api/users/avatar/${user.avatar_key}`} alt={name} />
{:else}
  <div class="grid rounded-full font-bold text-white" style={`width:${size}px;height:${size}px;place-items:center;background:hsl(${hue} 60% 42%)`}>
    <span style={`font-size:${Math.max(11, size * 0.36)}px`}>{initials}</span>
  </div>
{/if}
