<script>
  export let compact = false;
  export let size = 'md';
</script>

<span class:compact class:large={size === 'lg'} class="jarq-logo" aria-label="JARQ">
  <svg viewBox="0 0 42 42" role="img" aria-hidden="true">
    <path d="M14 10h7v14.3c0 5.1-3 7.8-8.2 7.8-1.1 0-2-.1-2.8-.4v-5.5c.6.2 1.2.3 1.9.3 1.5 0 2.1-.8 2.1-2.5V10Z" fill="#161004" />
    <path d="m25.4 11.3 8.8 5.7a2 2 0 0 1 0 3.4l-8.8 5.7a2 2 0 0 1-3.1-1.7V13a2 2 0 0 1 3.1-1.7Z" fill="#fff8e6" />
    <path d="m28 25.5 5.4 5.4" stroke="#161004" stroke-width="3.2" stroke-linecap="round" />
  </svg>
  {#if !compact}<strong>JAR<span>Q</span></strong>{/if}
</span>

<style>
  .jarq-logo{display:inline-flex;align-items:center;gap:9px;color:#f7f7f8}.jarq-logo svg{width:34px;height:34px;flex:none;border-radius:31%;background:linear-gradient(135deg,#fbd27a 0%,#f4b740 45%,#e3951a 100%)}.jarq-logo strong{font-size:27px;font-weight:950;letter-spacing:-1.7px}.jarq-logo strong span{color:var(--primary-text)}.jarq-logo.large svg{width:43px;height:43px}.jarq-logo.large strong{font-size:34px}.jarq-logo.compact{display:inline-grid}
</style>
