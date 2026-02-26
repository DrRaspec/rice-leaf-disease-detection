<template>
  <article class="surface-card p-6 sm:p-7">
    <h3 class="text-xl font-semibold text-[#102016]">Upload Rice Leaf Photo</h3>

    <div
      class="upload-dropzone mt-5"
      :class="{ 'is-dragging': isDragging, 'is-disabled': loading }"
      role="button"
      tabindex="0"
      aria-label="Upload rice leaf image"
      @click="openFilePicker"
      @keydown.enter.prevent="openFilePicker"
      @keydown.space.prevent="openFilePicker"
      @dragover.prevent="handleDragOver"
      @dragleave.prevent="handleDragLeave"
      @drop.prevent="handleDrop"
    >
      <input
        ref="fileInput"
        type="file"
        class="sr-only"
        accept="image/*"
        :disabled="loading"
        @change="handleFileChange"
      />

      <template v-if="previewSrc">
        <button
          class="group block w-full"
          type="button"
          :disabled="loading"
          @click.stop="openZoom"
        >
          <div class="preview-frame">
            <img :src="previewSrc" alt="Selected rice leaf preview" class="h-full w-full object-contain" />
            <div class="preview-overlay">Click to zoom</div>
          </div>
        </button>

        <div class="mt-4 flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-[#38503F]">
          <span class="font-medium text-[#102016]">{{ selectedFile?.name }}</span>
          <span>{{ formattedSize }}</span>
        </div>
      </template>

      <template v-else>
        <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-[#E9F5E6] text-[#2E7D32]">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" class="h-8 w-8">
            <path d="M4 14.5 8.8 9.7a2 2 0 0 1 2.8 0l4.8 4.8" stroke-linecap="round" stroke-linejoin="round" />
            <path d="m14.5 12 1.7-1.7a2 2 0 0 1 2.8 0L21 12.3" stroke-linecap="round" stroke-linejoin="round" />
            <rect x="3" y="4" width="18" height="16" rx="2" />
          </svg>
        </div>

        <p class="mt-4 text-base font-semibold text-[#102016]">Drag and drop or click to upload</p>
        <p class="mt-2 text-sm text-[#4D6653]">Use JPG, PNG, or WebP image files.</p>

        <ul class="mt-4 space-y-1 text-sm text-[#38503F]">
          <li>Good light</li>
          <li>Leaf centered</li>
          <li>No blur</li>
        </ul>
      </template>
    </div>

    <div class="mt-6 flex flex-wrap items-center gap-3">
      <button type="button" class="btn-pill btn-secondary" :disabled="loading" @click="openFilePicker">
        Replace
      </button>
      <button
        type="button"
        class="btn-pill btn-ghost-danger"
        :disabled="!previewSrc || loading"
        @click="$emit('remove')"
      >
        Remove
      </button>
      <button
        type="button"
        class="btn-pill btn-primary ml-auto"
        :disabled="!selectedFile || loading"
        @click="$emit('analyze')"
      >
        <span v-if="loading" class="inline-flex items-center gap-2">
          <span class="spinner" aria-hidden="true" />
          Analyzing...
        </span>
        <span v-else>Analyze</span>
      </button>
    </div>
  </article>

  <div v-if="showZoom" class="zoom-modal" role="dialog" aria-modal="true" @click.self="showZoom = false">
    <button type="button" class="zoom-close" aria-label="Close zoomed preview" @click="showZoom = false">Close</button>
    <img :src="previewSrc" alt="Zoomed rice leaf preview" class="zoom-image" />
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'

const props = defineProps({
  selectedFile: {
    type: Object,
    default: null,
  },
  previewSrc: {
    type: String,
    default: '',
  },
  loading: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['file-selected', 'analyze', 'remove'])

const fileInput = ref(null)
const isDragging = ref(false)
const showZoom = ref(false)

const formattedSize = computed(() => {
  const size = props.selectedFile?.size
  if (!size) return ''
  if (size >= 1024 * 1024) {
    return `${(size / (1024 * 1024)).toFixed(2)} MB`
  }
  return `${Math.max(1, Math.round(size / 1024))} KB`
})

function openFilePicker() {
  if (props.loading) return
  fileInput.value?.click()
}

function emitSelected(file) {
  if (!file || !file.type.startsWith('image/')) return
  showZoom.value = false
  isDragging.value = false
  fileInput.value && (fileInput.value.value = '')
  // Keep selected file state in parent so preview/result can sync cleanly.
  emit('file-selected', file)
}

function handleFileChange(event) {
  const file = event.target.files?.[0]
  emitSelected(file)
}

function handleDragOver() {
  if (props.loading) return
  isDragging.value = true
}

function handleDragLeave() {
  isDragging.value = false
}

function handleDrop(event) {
  if (props.loading) return
  const file = event.dataTransfer?.files?.[0]
  emitSelected(file)
}

function openZoom() {
  if (!props.previewSrc || props.loading) return
  showZoom.value = true
}

function onKeydown(event) {
  if (event.key === 'Escape') {
    showZoom.value = false
  }
}

onMounted(() => {
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', onKeydown)
})
</script>
