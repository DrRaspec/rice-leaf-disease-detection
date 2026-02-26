<template>
  <div
    class="upload-zone p-6 sm:p-10 flex flex-col items-center justify-center gap-4 sm:gap-5 min-h-[200px] sm:min-h-[280px] select-none group"
    :class="{ 'drag-over': isDragging }"
    @dragover.prevent="isDragging = true"
    @dragleave.prevent="isDragging = false"
    @drop.prevent="onDrop"
    @click="fileInput.click()"
  >
    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      class="hidden"
      @change="onFileChange"
    />

    <!-- Preview -->
    <template v-if="preview">
      <div class="relative w-36 h-36 sm:w-48 sm:h-48 rounded-2xl overflow-hidden ring-2 ring-rice-500/40 shadow-2xl shadow-rice-900/20 transition-all duration-500">
        <img :src="preview" alt="Preview" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" />
        <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent" />
        <div class="absolute bottom-2 left-2 right-2 flex items-center gap-2">
          <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-black/50 backdrop-blur-sm text-white/80 text-xs font-medium">
            <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="m2.25 15.75 5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909M3.75 21h16.5" />
            </svg>
            Ready to analyse
          </span>
        </div>
      </div>
      <p class="text-sm app-text-faint flex items-center gap-1.5">
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182" />
        </svg>
        Click or drag to replace
      </p>
    </template>

    <!-- Empty state -->
    <template v-else>
      <!-- Animated upload icon -->
      <div class="relative">
        <div
          class="w-18 h-18 sm:w-24 sm:h-24 rounded-2xl flex items-center justify-center transition-all duration-500"
          :class="isDragging ? 'scale-110 bg-rice-500/15' : 'bg-rice-900/30 group-hover:bg-rice-900/50'"
          style="width: 4.5rem; height: 4.5rem;"
        >
          <!-- Orbiting ring -->
          <div class="absolute inset-0 rounded-2xl border-2 border-dashed transition-all duration-500"
               :class="isDragging ? 'border-rice-400/50 animate-spin-slow' : 'border-transparent'" />
          <svg
            class="w-8 h-8 sm:w-10 sm:h-10 transition-all duration-500 drop-shadow-sm"
            :class="isDragging ? 'text-rice-400 -translate-y-1' : 'text-rice-500/70 group-hover:text-rice-400'"
            fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round"
              d="m2.25 15.75 5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909M3.75 21h16.5a2.25 2.25 0 0 0 2.25-2.25V5.25a2.25 2.25 0 0 0-2.25-2.25H3.75A2.25 2.25 0 0 0 1.5 5.25v13.5A2.25 2.25 0 0 0 3.75 21Z" />
          </svg>
        </div>
        <!-- Glow effect on drag -->
        <div v-if="isDragging" class="absolute inset-0 rounded-2xl bg-rice-400/10 blur-xl animate-pulse-glow" />
      </div>

      <div class="text-center space-y-2">
        <p class="font-display font-semibold text-base sm:text-lg transition-colors duration-300"
           :class="isDragging ? 'text-rice-300' : 'app-text-soft'">
          {{ isDragging ? 'Drop your image here' : 'Upload Rice Leaf Image' }}
        </p>
        <p class="text-xs sm:text-sm app-text-faint leading-relaxed">
          Drag &amp; drop or click to browse
        </p>
        <div class="flex items-center justify-center gap-2 pt-1">
          <span class="px-2 py-0.5 rounded-md text-[10px] font-medium app-text-faint" style="background: var(--app-card)">JPG</span>
          <span class="px-2 py-0.5 rounded-md text-[10px] font-medium app-text-faint" style="background: var(--app-card)">PNG</span>
          <span class="px-2 py-0.5 rounded-md text-[10px] font-medium app-text-faint" style="background: var(--app-card)">WebP</span>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({ preview: String })
const emit = defineEmits(['file-selected'])

const fileInput = ref(null)
const isDragging = ref(false)

function onFileChange(e) {
  const file = e.target.files?.[0]
  if (file) emit('file-selected', file)
}

function onDrop(e) {
  isDragging.value = false
  const file = e.dataTransfer.files?.[0]
  if (file && file.type.startsWith('image/')) emit('file-selected', file)
}
</script>
