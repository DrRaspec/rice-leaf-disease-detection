<template>
  <main class="min-h-screen pt-28 sm:pt-32 pb-20 sm:pb-28">
    <!-- Hero section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-16 sm:mb-20">
      <div class="text-center reveal">
        <span class="inline-block px-3 py-1 rounded-full text-[10px] sm:text-xs font-semibold uppercase tracking-widest text-rice-400 mb-4" style="background: rgba(34,197,94,0.08)">About</span>
        <h1 class="text-4xl sm:text-5xl md:text-6xl font-display font-bold tracking-tight mb-5">
          About <span class="text-gradient">RiceGuard</span> AI
        </h1>
        <p class="app-text-muted max-w-2xl mx-auto text-base sm:text-lg leading-relaxed">
          An open-source AI system helping farmers detect rice diseases early,
          reduce crop losses, and make data-driven treatment decisions.
        </p>
      </div>
    </section>

    <!-- Feature cards -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-16 sm:mb-20">
      <div class="grid md:grid-cols-2 gap-5 sm:gap-6 stagger-children">
        <div v-for="card in cards" :key="card.title"
             class="glass p-6 sm:p-8 group hover:bg-white/[0.06] transition-all duration-300 hover:-translate-y-1">
          <div class="flex items-start gap-4">
            <div class="w-12 h-12 rounded-2xl flex items-center justify-center text-2xl flex-shrink-0 transition-transform duration-500 group-hover:scale-110"
                 :style="{ background: card.bgColor }">
              {{ card.icon }}
            </div>
            <div>
              <h3 class="font-display font-bold text-lg app-text-strong mb-2">{{ card.title }}</h3>
              <p class="text-sm app-text-muted leading-relaxed">{{ card.body }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Stats section -->
    <section class="py-16 sm:py-20 noise-bg" style="background: var(--app-bg-soft)">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-10 reveal">
          <h2 class="text-2xl sm:text-3xl font-display font-bold tracking-tight mb-3">By The Numbers</h2>
          <p class="app-text-muted text-sm sm:text-base">Key metrics that define our system's capabilities.</p>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6 stagger-children">
          <div v-for="stat in aboutStats" :key="stat.label"
               class="glass-glow py-6 sm:py-8 px-4 text-center group hover:bg-white/[0.06] transition-all duration-300">
            <div class="text-3xl sm:text-4xl font-display font-bold text-gradient mb-2">{{ stat.value }}</div>
            <div class="text-xs sm:text-sm app-text-muted font-medium">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Tech stack -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-20">
      <div class="glass p-6 sm:p-8 reveal">
        <div class="flex items-center gap-3 mb-6">
          <div class="w-10 h-10 rounded-xl bg-accent-violet/10 flex items-center justify-center">
            <svg class="w-5 h-5 text-accent-violet" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5" />
            </svg>
          </div>
          <h3 class="font-display font-bold text-xl app-text-strong">Tech Stack</h3>
        </div>
        <div class="flex flex-wrap gap-2.5">
          <span v-for="tech in techs" :key="tech.name"
                class="group px-4 py-2 rounded-xl text-sm font-medium transition-all duration-300 hover:-translate-y-0.5 cursor-default"
                :style="{ background: tech.bgColor, border: '1px solid var(--app-border)' }">
            <span class="mr-1.5">{{ tech.icon }}</span>
            <span class="app-text-soft group-hover:app-text-strong">{{ tech.name }}</span>
          </span>
        </div>
      </div>
    </section>

    <!-- Architecture overview -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-8">
      <div class="glass p-6 sm:p-8 reveal">
        <div class="flex items-center gap-3 mb-6">
          <div class="w-10 h-10 rounded-xl bg-accent-cyan/10 flex items-center justify-center">
            <svg class="w-5 h-5 text-accent-cyan" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M20.25 6.375c0 2.278-3.694 4.125-8.25 4.125S3.75 8.653 3.75 6.375m16.5 0c0-2.278-3.694-4.125-8.25-4.125S3.75 4.097 3.75 6.375m16.5 0v11.25c0 2.278-3.694 4.125-8.25 4.125s-8.25-1.847-8.25-4.125V6.375m16.5 0v3.75m-16.5-3.75v3.75m16.5 0v3.75C20.25 16.153 16.556 18 12 18s-8.25-1.847-8.25-4.125v-3.75m16.5 0c0 2.278-3.694 4.125-8.25 4.125s-8.25-1.847-8.25-4.125" />
            </svg>
          </div>
          <h3 class="font-display font-bold text-xl app-text-strong">System Architecture</h3>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 stagger-children">
          <div v-for="layer in archLayers" :key="layer.title"
               class="p-4 sm:p-5 rounded-xl transition-all duration-300 hover:bg-white/[0.04]"
               style="background: var(--app-card); border: 1px solid var(--app-border)">
            <div class="text-lg mb-2">{{ layer.icon }}</div>
            <h4 class="font-display font-semibold text-sm app-text-strong mb-1">{{ layer.title }}</h4>
            <p class="text-xs app-text-muted leading-relaxed">{{ layer.desc }}</p>
          </div>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup>
import { useReveal } from '@/composables/useReveal.js'

useReveal()

const cards = [
  { icon: '🧠', title: 'Deep Learning Model', body: 'Trained on thousands of rice leaf images using a Convolutional Neural Network via TensorFlow/Keras with data augmentation for robust real-world performance.', bgColor: 'rgba(139,92,246,0.1)' },
  { icon: '⚡', title: 'Fast Inference', body: 'The Python model is exposed via a Spring Boot REST API, delivering sub-2-second predictions optimized for real-world farm use even on low bandwidth.', bgColor: 'rgba(245,158,11,0.1)' },
  { icon: '🌾', title: 'Six Conditions', body: 'Detects bacterial leaf blight, leaf blast, brown spot, leaf scald, narrow brown spot, and healthy leaves with high accuracy across diverse lighting conditions.', bgColor: 'rgba(34,197,94,0.1)' },
  { icon: '📱', title: 'Multi-platform', body: 'Available as a web app and a Flutter mobile app, so farmers can diagnose on-site from any device — no technical expertise required.', bgColor: 'rgba(6,182,212,0.1)' },
]

const aboutStats = [
  { value: '6', label: 'Disease Classes' },
  { value: '98%', label: 'Accuracy Rate' },
  { value: '<2s', label: 'Inference Time' },
  { value: '3', label: 'Platforms' },
]

const techs = [
  { name: 'TensorFlow', icon: '🔮', bgColor: 'rgba(255,111,0,0.06)' },
  { name: 'Python', icon: '🐍', bgColor: 'rgba(55,118,171,0.08)' },
  { name: 'Spring Boot', icon: '🍃', bgColor: 'rgba(34,197,94,0.06)' },
  { name: 'Vue 3', icon: '💚', bgColor: 'rgba(66,184,131,0.06)' },
  { name: 'Three.js', icon: '🎨', bgColor: 'rgba(139,92,246,0.06)' },
  { name: 'Flutter', icon: '📱', bgColor: 'rgba(6,182,212,0.06)' },
  { name: 'GetX', icon: '⚡', bgColor: 'rgba(245,158,11,0.06)' },
  { name: 'Tailwind CSS', icon: '🎯', bgColor: 'rgba(56,189,248,0.06)' },
]

const archLayers = [
  { icon: '🖼️', title: 'Frontend Layer', desc: 'Vue 3 web app with Tailwind CSS and Three.js 3D visualization, plus Flutter mobile app for on-the-go access.' },
  { icon: '🔌', title: 'API Layer', desc: 'Spring Boot REST API handling authentication, image upload, and request routing with JWT-based security.' },
  { icon: '🧠', title: 'ML Layer', desc: 'TensorFlow/Keras CNN model trained on augmented rice leaf dataset. Python inference engine for high-speed predictions.' },
]
</script>
