<script>
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  let retry = 5;
  $: is404 = $page.status === 404;
</script>

<section class="shell grid min-h-[70vh] place-items-center py-12">
  <div class="card max-w-lg p-8 text-center">
    <h1 class="text-4xl font-black">{is404 ? 'Страница не найдена' : 'Ошибка сети'}</h1>
    <p class="mt-3 text-[var(--text-2)]">{is404 ? 'Такой страницы нет или она была перемещена.' : `Попробуйте обновить страницу. Повтор через ${retry} сек.`}</p>
    <div class="mt-6 flex justify-center gap-3">
      <a class="btn" href="/">На главную</a>
      {#if !is404}<button class="btn-secondary" on:click={() => location.reload()}>Повторить</button>{/if}
    </div>
  </div>
</section>
