<template>
  <header class="sticky top-0 z-50 border-b backdrop-blur" style="border-color: var(--rg-border); background: color-mix(in srgb, var(--rg-bg) 95%, transparent)">
    <div class="site-shell flex h-20 items-center justify-between px-6 sm:px-10">
      <router-link to="/" class="flex items-center gap-3 rounded-full focus-visible:outline-none focus-visible:ring-2" style="--tw-ring-color: var(--rg-primary)">
        <span class="icon-pill">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" class="h-5 w-5">
            <path d="M6 14c0-4.8 2.8-8.6 8.2-9 2.8-.2 4.4.3 5.8 1.3-.8 6-4.4 10.6-10.8 10.6-1.2 0-2.2-.1-3.2-.4" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M7.5 17.3c1.5-2.5 3.6-4.4 6.8-6" stroke-linecap="round" />
          </svg>
        </span>
        <span class="text-lg font-bold tracking-tight" style="color: var(--rg-text)">RiceGuard AI</span>
      </router-link>

      <nav class="hidden items-center gap-2 lg:flex" aria-label="Primary">
        <router-link v-for="link in links" :key="link.label" :to="link.to" class="nav-link" @click="menuOpen = false">
          {{ link.label }}
        </router-link>
      </nav>

      <div class="flex items-center gap-3">
        <button type="button" class="btn-pill btn-secondary !px-4 !py-2 text-xs" @click="toggleLanguage">
          {{ language.toUpperCase() }}
        </button>
        <button type="button" class="btn-pill btn-secondary !px-4 !py-2 text-xs" @click="toggleTheme">
          {{ themeLabel }}
        </button>
        <router-link :to="scanLeafLink" class="btn-pill btn-primary">{{ t('nav.scan') }}</router-link>

        <button
          type="button"
          class="mobile-menu-btn lg:hidden"
          :aria-expanded="menuOpen"
          aria-controls="mobile-menu"
          aria-label="Toggle menu"
          @click="menuOpen = !menuOpen"
        >
          <svg v-if="!menuOpen" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
            <path d="M3.5 6.5h17M3.5 12h17M3.5 17.5h17" stroke-linecap="round" />
          </svg>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
            <path d="M6 6 18 18M6 18 18 6" stroke-linecap="round" />
          </svg>
        </button>
      </div>
    </div>

    <nav v-if="menuOpen" id="mobile-menu" class="border-t px-6 py-4 lg:hidden" style="border-color: var(--rg-border); background: var(--rg-bg)" aria-label="Mobile">
      <div class="site-shell flex flex-col gap-2">
        <router-link
          v-for="link in links"
          :key="`mobile-${link.label}`"
          :to="link.to"
          class="mobile-nav-link"
          @click="menuOpen = false"
        >
          {{ link.label }}
        </router-link>
      </div>
    </nav>
  </header>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useUiSettings } from '@/composables/useUiSettings'
import { useWebI18n } from '@/composables/useWebI18n'

const menuOpen = ref(false)
const { theme, setTheme } = useUiSettings()
const { language, setLanguage, t } = useWebI18n()

const links = computed(() => [
  { label: t('nav.how'), to: { path: '/', hash: '#how-it-works' } },
  { label: t('nav.diseases'), to: { path: '/', hash: '#diseases' } },
  { label: t('nav.demo'), to: { path: '/', hash: '#demo' } },
  { label: t('nav.about'), to: '/about' },
])

const scanLeafLink = computed(() => ({ path: '/', hash: '#demo' }))
const themeLabel = computed(() => (theme.value === 'dark' ? 'Dark' : 'Light'))

function toggleTheme() {
  setTheme(theme.value === 'dark' ? 'light' : 'dark')
}

function toggleLanguage() {
  setLanguage(language.value === 'km' ? 'en' : 'km')
}
</script>
