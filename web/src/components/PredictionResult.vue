<template>
  <div class="space-y-5 animate-fade-up">
    <!-- Main result card -->
    <div
      class="glass-glow p-5 sm:p-7 relative overflow-hidden"
      :style="{ '--glow': result.info.color }"
    >
      <!-- Animated glow blob -->
      <div
        class="absolute -top-16 -right-16 w-56 h-56 rounded-full opacity-[0.07] blur-3xl pointer-events-none animate-pulse-glow"
        :style="{ background: result.info.color }"
      />
      <div
        class="absolute -bottom-20 -left-20 w-40 h-40 rounded-full opacity-[0.04] blur-3xl pointer-events-none"
        :style="{ background: result.info.color }"
      />

      <div class="relative flex items-start gap-4 sm:gap-5">
        <!-- Icon with ring -->
        <div class="relative flex-shrink-0">
          <div
            class="w-14 h-14 sm:w-[4.5rem] sm:h-[4.5rem] rounded-2xl flex items-center justify-center text-2xl sm:text-3xl shadow-xl animate-scale-in"
            :style="{ background: `${result.info.color}15`, border: `1.5px solid ${result.info.color}30` }"
          >
            {{ result.info.icon }}
          </div>
          <!-- Severity dot -->
          <div
            class="absolute -top-1 -right-1 w-4 h-4 rounded-full border-2 animate-bounce-gentle"
            :class="severityDotClass(result.info.severity)"
            style="border-color: var(--app-bg)"
          />
        </div>

        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2.5 flex-wrap mb-1">
            <h3 class="text-lg sm:text-xl font-display font-bold app-text-strong tracking-tight">
              {{ result.info.label }}
            </h3>
            <span
              class="px-2.5 py-1 rounded-lg text-[10px] sm:text-xs font-bold uppercase tracking-wider"
              :class="severityClass(result.info.severity)"
            >
              {{ result.info.severity === 'none' ? 'Healthy' : result.info.severity + ' risk' }}
            </span>
          </div>

          <!-- Confidence meter -->
          <div class="mt-4">
            <div class="flex justify-between items-center text-xs mb-2">
              <span class="app-text-muted font-medium uppercase tracking-wider text-[10px]">Confidence</span>
              <span class="font-mono font-bold text-sm" :style="{ color: result.info.color }">
                {{ pct(result.confidence) }}%
              </span>
            </div>
            <div class="h-3 rounded-full overflow-hidden relative" style="background: var(--app-card-strong)">
              <!-- Background shimmer -->
              <div class="absolute inset-0 opacity-30"
                   style="background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); background-size: 200% 100%;"
                   :class="'animate-shimmer'" />
              <div
                class="confidence-bar h-full rounded-full relative"
                :style="{ width: pct(result.confidence) + '%', background: `linear-gradient(90deg, ${result.info.color}cc, ${result.info.color})` }"
              >
                <div class="absolute inset-0 rounded-full" style="background: linear-gradient(180deg, rgba(255,255,255,0.2), transparent)" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Description -->
      <p class="mt-5 text-sm app-text-muted leading-relaxed pl-[4.5rem] sm:pl-[5.5rem]">
        {{ result.info.description }}
      </p>
    </div>

    <!-- Treatment card -->
    <div class="glass p-5 sm:p-6 animate-fade-up" style="animation-delay: 100ms">
      <div class="flex items-center gap-2.5 mb-3">
        <div class="w-8 h-8 rounded-xl bg-rice-500/10 flex items-center justify-center">
          <svg class="w-4 h-4 text-rice-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9.75 3.104v5.714a2.25 2.25 0 0 1-.659 1.591L5 14.5M9.75 3.104c-.251.023-.501.05-.75.082m.75-.082a24.301 24.301 0 0 1 4.5 0m0 0v5.714c0 .597.237 1.17.659 1.591L19.8 15.3M14.25 3.104c.251.023.501.05.75.082M19.8 15.3l-1.57.393A9.065 9.065 0 0 1 12 15a9.065 9.065 0 0 0-6.23-.693L5 14.5m14.8.8 1.402 1.402c1.232 1.232.65 3.318-1.067 3.611A48.309 48.309 0 0 1 12 21c-2.773 0-5.491-.235-8.135-.687-1.718-.293-2.3-2.379-1.067-3.61L5 14.5" />
          </svg>
        </div>
        <h4 class="text-sm font-display font-semibold text-rice-400 uppercase tracking-wider">
          Recommended Treatment
        </h4>
      </div>
      <p class="text-sm app-text-soft leading-relaxed">{{ result.info.treatment }}</p>
    </div>

    <!-- Top predictions -->
    <div class="glass p-5 sm:p-6 animate-fade-up" style="animation-delay: 200ms">
      <div class="flex items-center gap-2.5 mb-5">
        <div class="w-8 h-8 rounded-xl bg-accent-violet/10 flex items-center justify-center">
          <svg class="w-4 h-4 text-accent-violet" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z" />
          </svg>
        </div>
        <h4 class="text-sm font-display font-semibold app-text-muted uppercase tracking-wider">
          All Predictions
        </h4>
      </div>
      <div class="space-y-3.5">
        <div
          v-for="(pred, idx) in result.top_predictions"
          :key="pred.class"
          class="flex items-center gap-3"
          :style="{ animationDelay: `${300 + idx * 80}ms` }"
          :class="idx === 0 ? 'animate-fade-up' : 'animate-fade-up'"
        >
          <span
            class="w-6 h-6 rounded-lg flex items-center justify-center text-[10px] font-bold"
            :class="idx === 0 ? 'bg-rice-500/20 text-rice-400' : 'app-text-faint'"
            :style="idx === 0 ? {} : { background: 'var(--app-card)' }"
          >
            {{ idx + 1 }}
          </span>
          <span class="text-sm flex-1 capitalize" :class="idx === 0 ? 'app-text-strong font-medium' : 'app-text-soft'">
            {{ pred.class.replace(/_/g, ' ') }}
          </span>
          <div class="w-20 sm:w-32 h-2 rounded-full overflow-hidden" style="background: var(--app-card-strong)">
            <div
              class="confidence-bar h-full rounded-full"
              :class="idx === 0 ? 'bg-rice-500' : 'bg-rice-700'"
              :style="{ width: pct(pred.confidence) + '%', transitionDelay: `${400 + idx * 100}ms` }"
            />
          </div>
          <span class="text-xs font-mono w-12 text-right" :class="idx === 0 ? 'app-text-strong font-semibold' : 'app-text-faint'">
            {{ pct(pred.confidence) }}%
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({ result: { type: Object, required: true } })

const pct = (v) => (v * 100).toFixed(1)

const severityClass = (s) => ({
  none:    'bg-rice-500/15 text-rice-400 ring-1 ring-rice-500/20',
  low:     'bg-yellow-500/15 text-yellow-400 ring-1 ring-yellow-500/20',
  medium:  'bg-orange-500/15 text-orange-400 ring-1 ring-orange-500/20',
  high:    'bg-red-500/15 text-red-400 ring-1 ring-red-500/20',
  unknown: 'bg-gray-500/15 text-gray-400 ring-1 ring-gray-500/20',
}[s] ?? '')

const severityDotClass = (s) => ({
  none:    'bg-rice-500',
  low:     'bg-yellow-500',
  medium:  'bg-orange-500',
  high:    'bg-red-500',
  unknown: 'bg-gray-500',
}[s] ?? 'bg-gray-500')
</script>
