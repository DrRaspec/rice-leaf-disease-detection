<template>
  <footer class="border-t" style="border-color: var(--rg-border); background: color-mix(in srgb, var(--rg-surface) 80%, var(--rg-bg))">
    <div class="site-shell px-6 py-12 sm:px-10 sm:py-14">
      <div class="grid gap-8 md:grid-cols-3">
        <div>
          <div class="flex items-center gap-3">
            <span class="icon-pill">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" class="h-5 w-5">
                <path d="M6 14c0-4.8 2.8-8.6 8.2-9 2.8-.2 4.4.3 5.8 1.3-.8 6-4.4 10.6-10.8 10.6-1.2 0-2.2-.1-3.2-.4" stroke-linecap="round" stroke-linejoin="round" />
                <path d="M7.5 17.3c1.5-2.5 3.6-4.4 6.8-6" stroke-linecap="round" />
              </svg>
            </span>
            <span class="text-lg font-bold" style="color: var(--rg-text)">RiceGuard AI</span>
          </div>
          <p class="mt-3 max-w-sm text-sm leading-relaxed" style="color: var(--rg-text-secondary)">
            {{ t('footer.desc') }}
          </p>
        </div>

        <div>
          <h3 class="text-sm font-semibold uppercase tracking-wider" style="color: var(--rg-primary)">{{ t('footer.links') }}</h3>
          <nav class="mt-4 flex flex-col gap-2 text-sm" style="color: var(--rg-text-secondary)">
            <router-link :to="{ path: '/', hash: '#home' }" class="footer-link">{{ t('footer.home') }}</router-link>
            <router-link :to="{ path: '/', hash: '#demo' }" class="footer-link">{{ t('footer.scanner') }}</router-link>
            <router-link :to="{ path: '/', hash: '#diseases' }" class="footer-link">{{ t('footer.diseases') }}</router-link>
            <router-link to="/about" class="footer-link">{{ t('footer.about') }}</router-link>
          </nav>
        </div>

        <div>
          <h3 class="text-sm font-semibold uppercase tracking-wider" style="color: var(--rg-primary)">{{ t('footer.builtWith') }}</h3>
          <p class="mt-4 text-sm leading-relaxed" style="color: var(--rg-text-secondary)">Vue 3, Tailwind CSS, Spring Boot, Python, TensorFlow</p>
        </div>
      </div>

      <p class="mt-10 text-xs" style="color: var(--rg-text-faint)">© {{ year }} RiceGuard AI. {{ t('footer.rights') }}</p>
    </div>
  </footer>
</template>

<script setup>
import { useWebI18n } from '@/composables/useWebI18n'

const year = new Date().getFullYear()
const { t } = useWebI18n()
</script>
