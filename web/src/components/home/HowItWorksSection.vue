<template>
  <section id="how-it-works" class="section-pad" style="background: var(--rg-bg)">
    <div class="site-shell">
      <div class="grid gap-8 lg:grid-cols-[minmax(0,0.75fr)_minmax(0,1.25fr)] lg:items-start">
        <div class="max-w-xl">
          <p class="eyebrow">{{ t('how.eyebrow') }}</p>
          <h2 class="section-title">{{ t('how.title') }}</h2>
          <p class="section-subtitle max-w-lg">
            {{ t('how.subtitle') }}
          </p>
        </div>

        <div class="grid gap-5 md:grid-cols-3">
          <article v-for="(step, index) in steps" :key="step.title" class="surface-card p-6">
            <div class="flex items-center justify-between gap-4">
              <div class="icon-pill" aria-hidden="true">
                <component :is="step.icon" class="h-5 w-5" />
              </div>
              <span class="text-xs font-bold uppercase tracking-[0.18em]" style="color: var(--rg-text-faint)">
                0{{ index + 1 }}
              </span>
            </div>
            <h3 class="mt-5 text-lg font-semibold" style="color: var(--rg-text)">{{ step.title }}</h3>
            <p class="mt-2 text-sm leading-relaxed" style="color: var(--rg-text-secondary)">{{ step.description }}</p>
          </article>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, defineComponent, h } from 'vue'
import { useWebI18n } from '@/composables/useWebI18n'

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

const { t } = useWebI18n()
const steps = computed(() => [
  { title: t('how.captureTitle'), description: t('how.captureDesc'), icon: CameraIcon },
  { title: t('how.analyzeTitle'), description: t('how.analyzeDesc'), icon: ScanIcon },
  { title: t('how.actTitle'), description: t('how.actDesc'), icon: AdviceIcon },
])
</script>
