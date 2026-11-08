<script>
  export let tag = { name: 'General', color: 'var(--primary)' };
</script>

<span class="inline-flex rounded-full px-2.5 py-1 text-xs font-semibold text-white" style={`background:${tag.color || 'var(--primary)'}33;color:${tag.color || 'var(--primary)'}`}>
  {tag.name}
</span>
