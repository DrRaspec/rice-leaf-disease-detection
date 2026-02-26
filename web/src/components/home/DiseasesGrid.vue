<template>
  <section id="diseases" class="section-pad bg-[#F8FCF3]">
    <div class="site-shell">
      <div class="text-center">
        <p class="eyebrow">Disease Library</p>
        <h2 class="section-title">Known Rice Diseases</h2>
      </div>

      <div class="mt-10 grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
        <article
          v-for="disease in diseases"
          :key="disease.name"
          class="surface-card disease-card p-6"
        >
          <div class="icon-pill mb-4" aria-hidden="true">
            <component :is="disease.icon" class="h-5 w-5" />
          </div>
          <h3 class="text-lg font-semibold text-[#102016]">{{ disease.name }}</h3>
          <p class="mt-2 text-sm leading-relaxed text-[#38503F]">{{ disease.description }}</p>
          <span class="risk-chip mt-4 inline-flex" :class="riskChipClass(disease.risk)">
            {{ disease.risk }} risk
          </span>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup>
import { defineComponent, h } from 'vue'

const LeafIcon = defineComponent({
  name: 'LeafIcon',
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
          d: 'M5 14c0-5.5 3.5-9 9-9 3 0 5 .8 6 2-1.2 5.3-4.8 10-11 10-1.3 0-2.6-.2-4-.6',
          'stroke-linejoin': 'round',
          'stroke-linecap': 'round',
        }),
        h('path', {
          d: 'M7 17c1.7-2.7 4-4.7 7.3-6.5',
          'stroke-linecap': 'round',
        }),
      ],
    )
  },
})

const ShieldIcon = defineComponent({
  name: 'ShieldIcon',
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
          d: 'M12 3 5 6v6c0 4.3 2.4 7.3 7 9 4.6-1.7 7-4.7 7-9V6z',
          'stroke-linejoin': 'round',
        }),
        h('path', {
          d: 'm9.2 12 1.8 1.8 3.8-3.8',
          'stroke-linecap': 'round',
          'stroke-linejoin': 'round',
        }),
      ],
    )
  },
})

const AlertIcon = defineComponent({
  name: 'AlertIcon',
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
          d: 'M12 3 2.7 19h18.6z',
          'stroke-linejoin': 'round',
        }),
        h('path', {
          d: 'M12 9v4M12 17h.01',
          'stroke-linecap': 'round',
        }),
      ],
    )
  },
})

const diseases = [
  {
    name: 'Healthy',
    description: 'Leaf texture and color look normal with no major disease signals.',
    risk: 'Low',
    icon: ShieldIcon,
  },
  {
    name: 'Leaf Blast',
    description: 'Diamond-like lesions can spread quickly in humid weather.',
    risk: 'High',
    icon: AlertIcon,
  },
  {
    name: 'Bacterial Leaf Blight',
    description: 'Yellowing from edges often worsens after heavy rainfall.',
    risk: 'High',
    icon: AlertIcon,
  },
  {
    name: 'Brown Spot',
    description: 'Brown circular spots appear on older leaves under stress.',
    risk: 'Medium',
    icon: LeafIcon,
  },
  {
    name: 'Leaf Scald',
    description: 'Scald-like streaks start near leaf tips and extend downward.',
    risk: 'Medium',
    icon: LeafIcon,
  },
  {
    name: 'Narrow Brown Spot',
    description: 'Slim dark streaks indicate early-stage fungal stress.',
    risk: 'Low',
    icon: LeafIcon,
  },
]

function riskChipClass(risk) {
  if (risk === 'High') return 'chip-risk-high'
  if (risk === 'Medium') return 'chip-risk-medium'
  return 'chip-risk-low'
}
</script>
