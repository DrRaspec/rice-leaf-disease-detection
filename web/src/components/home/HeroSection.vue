<template>
  <section id="home" class="relative overflow-hidden">
    <div class="hero-background" :style="{ backgroundImage: `url(${heroImage})` }" aria-hidden="true" />
    <div class="hero-overlay" aria-hidden="true" />
    <div class="hero-fade" aria-hidden="true" />

    <div class="site-shell relative z-10 flex min-h-[86svh] flex-col items-center justify-center px-6 py-28 text-center sm:px-10">
      <p class="badge-soft mb-6">AI-Powered Disease Detection</p>

      <h1 class="max-w-4xl text-balance text-4xl font-extrabold leading-tight text-white sm:text-5xl md:text-6xl">
        Protect Your <span class="text-[#81C784]">Rice</span> Harvest
      </h1>

      <p class="mt-6 max-w-2xl text-base leading-relaxed text-white/90 sm:text-lg">
        Upload a rice leaf photo and get instant diagnosis plus treatment tips.
      </p>

      <div class="mt-9 flex w-full max-w-md flex-col gap-3 sm:max-w-none sm:w-auto sm:flex-row sm:justify-center">
        <router-link :to="{ path: '/', hash: '#demo' }" class="btn-pill btn-primary">
          Scan Leaf
        </router-link>
        <router-link :to="{ path: '/', hash: '#diseases' }" class="btn-pill btn-secondary">
          Disease Library
        </router-link>
      </div>

      <ul class="mt-10 flex flex-wrap items-center justify-center gap-3 text-sm text-white/95 sm:gap-5">
        <li v-for="item in trustItems" :key="item.label" class="trust-chip">
          <component :is="item.icon" class="h-4 w-4" aria-hidden="true" />
          <span>{{ item.label }}</span>
        </li>
      </ul>
    </div>
  </section>
</template>

<script setup>
import { defineComponent, h } from 'vue'

// TODO: Replace with your own local asset, e.g. `/images/rice-field.jpg`.
const heroImage =
  'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg?auto=compress&cs=tinysrgb&w=1600'

const PhoneIcon = defineComponent({
  name: 'PhoneIcon',
  render() {
    return h(
      'svg',
      {
        viewBox: '0 0 24 24',
        fill: 'none',
        stroke: 'currentColor',
        'stroke-width': '1.8',
      },
      [
        h('rect', {
          x: '7',
          y: '2.5',
          width: '10',
          height: '19',
          rx: '2.5',
          'stroke-linejoin': 'round',
        }),
        h('path', {
          d: 'M11 18.5h2',
          'stroke-linecap': 'round',
        }),
      ],
    )
  },
})

const BoltIcon = defineComponent({
  name: 'BoltIcon',
  render() {
    return h(
      'svg',
      {
        viewBox: '0 0 24 24',
        fill: 'none',
        stroke: 'currentColor',
        'stroke-width': '1.8',
      },
      [
        h('path', {
          d: 'M13 2 5 14h6l-1 8 9-13h-6z',
          'stroke-linejoin': 'round',
          'stroke-linecap': 'round',
        }),
      ],
    )
  },
})

const OfflineIcon = defineComponent({
  name: 'OfflineIcon',
  render() {
    return h(
      'svg',
      {
        viewBox: '0 0 24 24',
        fill: 'none',
        stroke: 'currentColor',
        'stroke-width': '1.8',
      },
      [
        h('path', {
          d: 'm4 4 16 16',
          'stroke-linecap': 'round',
        }),
        h('path', {
          d: 'M8.5 8.5A5 5 0 0 1 17 12a5 5 0 0 1-5 5 5 5 0 0 1-3.5-1.5',
          'stroke-linecap': 'round',
          'stroke-linejoin': 'round',
        }),
        h('path', {
          d: 'M7 12h.01M12 12h.01M17 12h.01',
          'stroke-linecap': 'round',
        }),
      ],
    )
  },
})

const trustItems = [
  { label: 'Works on phone', icon: PhoneIcon },
  { label: 'Fast', icon: BoltIcon },
  { label: 'Offline tips', icon: OfflineIcon },
]
</script>
