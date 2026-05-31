<script>
  export let tag = { name: 'General', color: '#6366f1' };
</script>

<span class="inline-flex rounded-full px-2.5 py-1 text-xs font-semibold text-white" style={`background:${tag.color || '#6366f1'}33;color:${tag.color || '#6366f1'}`}>
  {tag.name}
</span>
