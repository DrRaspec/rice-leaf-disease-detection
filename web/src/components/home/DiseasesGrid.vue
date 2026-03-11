<template>
  <section id="diseases" class="section-pad" style="background: var(--rg-surface-alt)">
    <div class="site-shell">
      <div class="text-center">
        <p class="eyebrow">{{ t('diseases.eyebrow') }}</p>
        <h2 class="section-title">{{ t('diseases.title') }}</h2>
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
          <h3 class="text-lg font-semibold" style="color: var(--rg-text)">{{ disease.name }}</h3>
          <p class="mt-2 text-sm leading-relaxed" style="color: var(--rg-text-secondary)">{{ disease.description }}</p>
          <span class="risk-chip mt-4 inline-flex" :class="riskChipClass(disease.risk)">
            {{ disease.risk }} {{ t('diseases.risk') }}
          </span>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, defineComponent, h } from 'vue'
import { useWebI18n } from '@/composables/useWebI18n'

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

const diseasesEn = [
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

const diseasesKm = [
  { name: 'សុខភាពល្អ', description: 'ស្លឹកមានពណ៌ និងសភាពធម្មតា មិនឃើញរោគសញ្ញាសំខាន់។', risk: 'ទាប', icon: ShieldIcon },
  { name: 'ជំងឺក្រុង', description: 'ស្នាមរាងពេជ្រអាចរាលដាលលឿន នៅពេលអាកាសធាតុសើម។', risk: 'ខ្ពស់', icon: AlertIcon },
  { name: 'ជំងឺរលាកស្លឹកដោយបាក់តេរី', description: 'ស្លឹកលឿងពីគែម ហើយអាការៈអាចធ្ងន់ក្រោយភ្លៀងច្រើន។', risk: 'ខ្ពស់', icon: AlertIcon },
  { name: 'ជំងឺអុចត្នោត', description: 'ចំណុចត្នោតរាងមូលលើស្លឹក ច្រើនកើតនៅដំណាំខ្សោយ។', risk: 'មធ្យម', icon: LeafIcon },
  { name: 'ជំងឺដំបៅស្លឹក', description: 'ស្នាមដូចរលាក ចាប់ផ្ដើមពីចុងស្លឹក ហើយរាលចុះក្រោម។', risk: 'មធ្យម', icon: LeafIcon },
  { name: 'ជំងឺឆ្នូតត្នោត', description: 'ស្នាមតូចរាងបន្ទាត់បង្ហាញពីសម្ពាធជំងឺផ្សិតដំណាក់កាលដំបូង។', risk: 'ទាប', icon: LeafIcon },
]

const { language, t } = useWebI18n()
const diseases = computed(() => (language.value === 'km' ? diseasesKm : diseasesEn))

function riskChipClass(risk) {
  if (risk === 'High' || risk === 'ខ្ពស់') return 'chip-risk-high'
  if (risk === 'Medium' || risk === 'មធ្យម') return 'chip-risk-medium'
  return 'chip-risk-low'
}
</script>
