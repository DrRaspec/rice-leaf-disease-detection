<template>
  <section id="faq" class="section-pad bg-[#F5FBEF]">
    <div class="site-shell max-w-4xl">
      <div class="text-center">
        <p class="eyebrow">FAQ</p>
        <h2 class="section-title">Common questions</h2>
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
import { ref } from 'vue'

const openIndex = ref(0)

const faqs = [
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

function toggle(index) {
  openIndex.value = openIndex.value === index ? -1 : index
}
</script>
