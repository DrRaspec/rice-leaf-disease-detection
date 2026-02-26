<template>
  <section id="how-it-works" class="section-pad bg-[#F5FBEF]">
    <div class="site-shell">
      <div class="text-center">
        <p class="eyebrow">How it works</p>
        <h2 class="section-title">Simple steps for faster field decisions</h2>
        <p class="section-subtitle mx-auto max-w-2xl">
          Built for busy farmers and field teams. Take a photo, check the result, and act quickly.
        </p>
      </div>

      <div class="mt-10 grid gap-5 md:grid-cols-3">
        <article v-for="step in steps" :key="step.title" class="surface-card p-6">
          <div class="icon-pill mb-4" aria-hidden="true">
            <component :is="step.icon" class="h-5 w-5" />
          </div>
          <h3 class="text-lg font-semibold text-[#102016]">{{ step.title }}</h3>
          <p class="mt-2 text-sm leading-relaxed text-[#38503F]">{{ step.description }}</p>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup>
import { defineComponent, h } from 'vue'

const CameraIcon = defineComponent({
  name: 'CameraIcon',
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
          d: 'M4 8.5h16v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z',
          'stroke-linejoin': 'round',
        }),
        h('path', {
          d: 'M9 8.5 10.3 5h3.4L15 8.5',
          'stroke-linejoin': 'round',
          'stroke-linecap': 'round',
        }),
        h('circle', {
          cx: '12',
          cy: '13.5',
          r: '3',
        }),
      ],
    )
  },
})

const ScanIcon = defineComponent({
  name: 'ScanIcon',
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
          d: 'M7 3H4a1 1 0 0 0-1 1v3M17 3h3a1 1 0 0 1 1 1v3M7 21H4a1 1 0 0 1-1-1v-3M17 21h3a1 1 0 0 0 1-1v-3',
          'stroke-linecap': 'round',
        }),
        h('path', {
          d: 'M7 12h10',
          'stroke-linecap': 'round',
        }),
      ],
    )
  },
})

const AdviceIcon = defineComponent({
  name: 'AdviceIcon',
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
          d: 'M8 12.5 11 15.5 16.5 10',
          'stroke-linecap': 'round',
          'stroke-linejoin': 'round',
        }),
        h('path', {
          d: 'M4 4h16v16H4z',
          'stroke-linejoin': 'round',
        }),
      ],
    )
  },
})

const steps = [
  {
    title: 'Capture',
    description: 'Take a clear rice leaf photo in good light with the leaf centered.',
    icon: CameraIcon,
  },
  {
    title: 'Analyze',
    description: 'Upload once and let the model detect likely disease patterns in seconds.',
    icon: ScanIcon,
  },
  {
    title: 'Act',
    description: 'Follow treatment and prevention guidance to protect nearby plants early.',
    icon: AdviceIcon,
  },
]
</script>
