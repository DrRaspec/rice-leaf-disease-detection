<template>
  <header
    class="sticky top-0 z-50 border-b backdrop-blur-xl"
    style="border-color: var(--rg-border); background: color-mix(in srgb, var(--rg-bg) 86%, transparent)"
  >
    <div class="site-shell flex h-20 items-center justify-between px-6 sm:px-10">
      <router-link
        to="/"
        class="flex items-center gap-3 rounded-full focus-visible:outline-none focus-visible:ring-2"
        style="--tw-ring-color: var(--rg-primary)"
      >
        <span
          class="flex h-9 w-9 items-center justify-center rounded-xl shadow-sm"
          style="background: var(--rg-primary-deep); color: white"
        >
          <svg viewBox="0 0 24 24" class="h-[18px] w-[18px]">
            <path d="M17.8 4.2C16.2 3.4 14 3 11.5 3.5 7.4 4.4 4.6 8.2 4.6 13c0 .6.1 1.2.2 1.8l.6-.2c1.2-.5 2.2-1.2 3-2" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
            <path d="M8.4 12.6c1.8-2.2 4.2-3.8 7.2-5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" opacity=".7" />
            <path d="M19 5c-.6 5.4-3.6 9.6-9.2 10.8" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
          </svg>
        </span>
        <span class="flex flex-col leading-none">
          <span class="text-lg font-bold tracking-tight" style="color: var(--rg-text)">RiceGuard AI</span>
          <span class="mt-1 text-[0.7rem] font-semibold uppercase tracking-[0.18em]" style="color: var(--rg-text-faint)">
            Field-ready detection
          </span>
        </span>
      </router-link>

      <nav class="hidden items-center gap-2 lg:flex" aria-label="Primary">
        <router-link v-for="link in links" :key="link.label" :to="link.to" class="nav-link" @click="menuOpen = false">
          {{ link.label }}
        </router-link>
      </nav>

      <div class="flex items-center gap-3">
        <button type="button" class="btn-pill btn-secondary hidden !px-4 !py-2 text-xs sm:inline-flex" @click="toggleLanguage">
          {{ language.toUpperCase() }}
        </button>
        <button type="button" class="btn-pill btn-secondary hidden !px-4 !py-2 text-xs sm:inline-flex" @click="toggleTheme">
          {{ themeLabel }}
        </button>
        <router-link :to="scanLeafLink" class="btn-pill btn-primary hidden sm:inline-flex">{{ t('nav.scan') }}</router-link>

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

    <nav
      v-if="menuOpen"
      id="mobile-menu"
      class="border-t px-6 py-4 lg:hidden"
      style="border-color: var(--rg-border); background: var(--rg-bg)"
      aria-label="Mobile"
    >
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
        <div class="mt-3 flex gap-3">
          <button type="button" class="btn-pill btn-secondary flex-1 !px-4 !py-3 text-xs" @click="toggleLanguage">
            {{ language.toUpperCase() }}
          </button>
          <button type="button" class="btn-pill btn-secondary flex-1 !px-4 !py-3 text-xs" @click="toggleTheme">
            {{ themeLabel }}
          </button>
        </div>
        <router-link :to="scanLeafLink" class="btn-pill btn-primary mt-2" @click="menuOpen = false">
          {{ t('nav.scan') }}
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
