<template>
  <section id="home" class="relative overflow-hidden">
    <div class="hero-background" :style="{ backgroundImage: `url(${heroImage})` }" aria-hidden="true" />
    <div class="hero-overlay" aria-hidden="true" />
    <div class="hero-fade" aria-hidden="true" />

    <div class="site-shell relative z-10 px-6 py-24 sm:px-10 sm:py-28">
      <div class="flex min-h-[72svh] items-end">
        <div class="max-w-2xl">
          <h1
            class="max-w-3xl text-balance text-4xl leading-[0.96] text-white sm:text-5xl md:text-6xl lg:text-7xl"
            style="font-family: var(--rg-font-display); font-weight: 700"
          >
            {{ t('hero.titlePrefix') }}
            <span style="color: var(--rg-accent)">{{ t('hero.titleAccent') }}</span>
            {{ t('hero.titleSuffix') }}
          </h1>

          <p class="mt-5 max-w-lg text-base leading-relaxed text-white/88 sm:text-lg">
            {{ t('hero.subtitle') }}
          </p>

          <div class="mt-8 flex w-full max-w-md flex-col gap-3 sm:max-w-none sm:w-auto sm:flex-row sm:items-center">
            <router-link :to="{ path: '/', hash: '#demo' }" class="btn-pill btn-primary min-w-[170px]">
              {{ t('hero.scan') }}
            </router-link>
            <router-link :to="{ path: '/', hash: '#diseases' }" class="btn-pill btn-secondary min-w-[170px]">
              {{ t('hero.library') }}
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { useWebI18n } from '@/composables/useWebI18n'

// TODO: Replace with your own local asset, e.g. `/images/rice-field.jpg`.
const heroImage =
  'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg?auto=compress&cs=tinysrgb&w=1600'

const { t } = useWebI18n()
</script>
