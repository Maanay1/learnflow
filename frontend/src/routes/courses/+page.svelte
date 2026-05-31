<script>
  import { onMount } from 'svelte';
  import { courses } from '$lib/api';
  import CourseCard from '$lib/components/CourseCard.svelte';
  import LoadingSkeleton from '$lib/components/LoadingSkeleton.svelte';
  let items = [], loading = true, filters = { subject_tag_id: '', difficulty: '', price: '' };
  async function load() {
    loading = true;
    items = (await courses.list(filters)).courses || [];
    loading = false;
  }
  onMount(load);
</script>

<section class="shell space-y-6 py-8">
  <div class="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
    <div>
      <p class="font-bold text-primary">LearnFlow Courses</p>
      <h1 class="text-3xl font-black">Курсы</h1>
    </div>
    <div class="grid gap-2 sm:grid-cols-3">
      <input class="input" bind:value={filters.subject_tag_id} placeholder="subject tag id" on:change={load} />
      <select class="input" bind:value={filters.difficulty} on:change={load}>
        <option value="">Любая сложность</option>
        <option value="beginner">Beginner</option>
        <option value="intermediate">Intermediate</option>
        <option value="advanced">Advanced</option>
      </select>
      <select class="input" bind:value={filters.price} on:change={load}>
        <option value="">Любая цена</option>
        <option value="free">Бесплатно</option>
        <option value="paid">Платные</option>
      </select>
    </div>
  </div>

  {#if loading}
    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{#each Array(6) as _}<LoadingSkeleton className="h-72" />{/each}</div>
  {:else if items.length}
    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{#each items as course}<CourseCard {course} />{/each}</div>
  {:else}
    <div class="card p-10 text-center text-[var(--text-2)]">Курсы скоро появятся</div>
  {/if}
</section>
