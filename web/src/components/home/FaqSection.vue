<template>
  <section id="faq" class="section-pad bg-[#F5FBEF]">
    <div class="site-shell max-w-4xl">
      <div class="text-center">
        <p class="eyebrow">{{ t('faq.eyebrow') }}</p>
        <h2 class="section-title">{{ t('faq.title') }}</h2>
      </div>

      <div class="mt-8 space-y-3">
        <article v-for="(item, index) in faqs" :key="item.question" class="surface-card p-0">
          <h3>
            <button
              type="button"
              class="faq-trigger"
              :aria-expanded="openIndex === index"
              :aria-controls="`faq-panel-${index}`"
              @click="toggle(index)"
            >
              <span>{{ item.question }}</span>
              <span class="faq-icon" aria-hidden="true">{{ openIndex === index ? '-' : '+' }}</span>
            </button>
          </h3>
          <div
            v-show="openIndex === index"
            :id="`faq-panel-${index}`"
            class="faq-panel"
          >
            <p>{{ item.answer }}</p>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useWebI18n } from '@/composables/useWebI18n'

const openIndex = ref(0)

const faqsEn = [
  {
    question: 'Is it free?',
    answer: 'Yes. You can upload and scan leaf photos without a paid plan.',
  },
  {
    question: 'How accurate is it?',
    answer: 'The model is trained on multiple rice leaf classes and returns confidence for each prediction.',
  },
  {
    question: 'What photo quality is needed?',
    answer: 'Use a clear, well-lit image with one leaf centered and minimal blur.',
  },
  {
    question: 'Does it work offline?',
    answer: 'Analysis needs connection, but treatment tips can be saved for later field use.',
  },
  {
    question: 'What should I do after detection?',
    answer: 'Use the treatment and prevention guidance, then confirm actions with your agronomy advisor.',
  },
]

const faqsKm = [
  { question: 'ប្រើឥតគិតថ្លៃឬ?', answer: 'បាទ/ចាស។ អ្នកអាចបញ្ចូល និងស្កេនរូបស្លឹកដោយមិនបង់ថ្លៃ។' },
  { question: 'ភាពត្រឹមត្រូវប៉ុន្មាន?', answer: 'ម៉ូដែលត្រូវបានហ្វឹកហាត់លើប្រភេទជំងឺជាច្រើន ហើយបង្ហាញកម្រិតជឿជាក់។' },
  { question: 'រូបភាពត្រូវមានគុណភាពបែបណា?', answer: 'សូមប្រើរូបច្បាស់ ពន្លឺល្អ ហើយផ្ដោតលើស្លឹកមួយសន្លឹក។' },
  { question: 'អាចប្រើក្រៅបណ្ដាញបានទេ?', answer: 'ការវិភាគត្រូវការអ៊ីនធឺណិត ប៉ុន្តែអ្នកអាចរក្សាទុកគន្លឹះព្យាបាលសម្រាប់មើលពេលក្រោយ។' },
  { question: 'បន្ទាប់ពីរកឃើញ ត្រូវធ្វើអ្វី?', answer: 'អនុវត្តការណែនាំព្យាបាល/ការពារ ហើយពិគ្រោះអ្នកជំនាញកសិកម្មសម្រាប់ការសម្រេចចិត្តចុងក្រោយ។' },
]

const { language, t } = useWebI18n()
const faqs = computed(() => (language.value === 'km' ? faqsKm : faqsEn))

function toggle(index) {
  openIndex.value = openIndex.value === index ? -1 : index
}
</script>
