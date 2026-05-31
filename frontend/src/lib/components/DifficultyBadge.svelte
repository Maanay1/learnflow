<script>
  export let difficulty = 'beginner';
  const labels = { beginner: 'Beginner', intermediate: 'Intermediate', advanced: 'Advanced' };
  const styles = {
    beginner: 'bg-[#22c55e]/15 text-[#22c55e]',
    intermediate: 'bg-[#f59e0b]/15 text-[#f59e0b]',
    advanced: 'bg-[#ef4444]/15 text-[#ef4444]'
  };
</script>

<span class={`inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ${styles[difficulty] || styles.beginner}`}>
  {labels[difficulty] || difficulty}
</span>
