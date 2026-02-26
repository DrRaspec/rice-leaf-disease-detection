import { readonly, ref, watch } from 'vue'

const STORAGE_KEYS = {
  fontScale: 'ui.fontScale',
  fontFamily: 'ui.fontFamily',
}

const THEME_OPTIONS = ['light']
const FONT_SCALE_OPTIONS = ['small', 'medium', 'large']
const FONT_FAMILY_OPTIONS = ['inter', 'jakarta', 'system']

const theme = ref('light')
const fontScale = ref('medium')
const fontFamily = ref('inter')

function loadFromStorage() {
  const savedScale = localStorage.getItem(STORAGE_KEYS.fontScale)
  const savedFamily = localStorage.getItem(STORAGE_KEYS.fontFamily)

  theme.value = 'light'
  if (savedScale && FONT_SCALE_OPTIONS.includes(savedScale)) fontScale.value = savedScale
  if (savedFamily && FONT_FAMILY_OPTIONS.includes(savedFamily)) fontFamily.value = savedFamily
}

function applyDomState() {
  const root = document.documentElement
  root.dataset.theme = theme.value
  root.dataset.fontScale = fontScale.value
  root.dataset.fontFamily = fontFamily.value
}

function persist() {
  localStorage.setItem(STORAGE_KEYS.fontScale, fontScale.value)
  localStorage.setItem(STORAGE_KEYS.fontFamily, fontFamily.value)
}

function dispatchThemeEvent() {
  window.dispatchEvent(
    new CustomEvent('app-theme-change', {
      detail: { theme: theme.value },
    }),
  )
}

export function initUiSettings() {
  loadFromStorage()
  applyDomState()
  dispatchThemeEvent()

  watch(
    [theme, fontScale, fontFamily],
    () => {
      applyDomState()
      persist()
      dispatchThemeEvent()
    },
    { deep: false },
  )
}

export function useUiSettings() {
  const setTheme = (value) => {
    if (THEME_OPTIONS.includes(value)) {
      theme.value = value
    }
  }

  const setFontScale = (value) => {
    if (FONT_SCALE_OPTIONS.includes(value)) {
      fontScale.value = value
    }
  }

  const setFontFamily = (value) => {
    if (FONT_FAMILY_OPTIONS.includes(value)) {
      fontFamily.value = value
    }
  }

  return {
    theme: readonly(theme),
    fontScale: readonly(fontScale),
    fontFamily: readonly(fontFamily),
    setTheme,
    setFontScale,
    setFontFamily,
    options: {
      themes: THEME_OPTIONS,
      fontScales: FONT_SCALE_OPTIONS,
      fontFamilies: FONT_FAMILY_OPTIONS,
    },
  }
}
