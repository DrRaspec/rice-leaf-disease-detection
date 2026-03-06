import { readonly, ref } from 'vue'

const STORAGE_KEY = 'ui.language'
const SUPPORTED = ['en', 'km']

const messages = {
  en: {
    nav: { how: 'How it works', diseases: 'Diseases', demo: 'Demo', about: 'About', scan: 'Scan Leaf' },
    hero: {
      badge: 'AI-Powered Disease Detection',
      titlePrefix: 'Protect Your',
      titleAccent: 'Rice',
      titleSuffix: 'Harvest',
      subtitle: 'Upload a rice leaf photo and get instant diagnosis plus treatment tips.',
      scan: 'Scan Leaf',
      library: 'Disease Library',
      trustPhone: 'Works on phone',
      trustFast: 'Fast',
      trustOffline: 'Offline tips',
    },
    how: {
      eyebrow: 'How it works',
      title: 'Simple steps for faster field decisions',
      subtitle: 'Built for busy farmers and field teams. Take a photo, check the result, and act quickly.',
      captureTitle: 'Capture',
      captureDesc: 'Take a clear rice leaf photo in good light with the leaf centered.',
      analyzeTitle: 'Analyze',
      analyzeDesc: 'Upload once and let the model detect likely disease patterns in seconds.',
      actTitle: 'Act',
      actDesc: 'Follow treatment and prevention guidance to protect nearby plants early.',
    },
    diseases: { eyebrow: 'Disease Library', title: 'Known Rice Diseases', risk: 'risk' },
    faq: { eyebrow: 'FAQ', title: 'Common questions' },
    scanner: {
      eyebrow: 'Scanner Demo',
      title: 'Upload and analyze a rice leaf',
      subtitle: 'Choose a clear leaf photo to get disease name, confidence, and practical treatment guidance.',
      optimizing: 'Optimizing image for faster upload...',
      analyzing: 'Analyzing...',
      upload: 'Uploading {progress}%...',
      optimized: 'Optimized from {from} to {to}',
    },
    upload: {
      title: 'Upload Rice Leaf Photo',
      drag: 'Drag and drop or click to upload',
      note: 'Use JPG, PNG, WebP, or HEIC image files.',
      tip1: 'Good light',
      tip2: 'Leaf centered',
      tip3: 'No blur',
      replace: 'Replace',
      remove: 'Remove',
      analyze: 'Analyze',
      analyzing: 'Analyzing...',
      clickZoom: 'Click to zoom',
      close: 'Close',
    },
    footer: {
      desc: 'Helping farmers detect rice disease early and protect harvest quality with practical AI support.',
      links: 'Links',
      builtWith: 'Built with',
      home: 'Home',
      scanner: 'Scanner',
      diseases: 'Diseases',
      about: 'About',
      rights: 'All rights reserved.',
    },
  },
  km: {
    nav: { how: 'របៀបដំណើរការ', diseases: 'ជំងឺ', demo: 'សាកល្បង', about: 'អំពី', scan: 'ស្កេនស្លឹក' },
    hero: {
      badge: 'ប្រព័ន្ធ AI រកជំងឺ',
      titlePrefix: 'ការពារ',
      titleAccent: 'ដំណាំស្រូវ',
      titleSuffix: 'របស់អ្នក',
      subtitle: 'បញ្ចូលរូបស្លឹកស្រូវ ដើម្បីទទួលលទ្ធផលវិភាគ និងការណែនាំព្យាបាលភ្លាមៗ។',
      scan: 'ស្កេនស្លឹក',
      library: 'បណ្ណាល័យជំងឺ',
      trustPhone: 'ប្រើបានលើទូរស័ព្ទ',
      trustFast: 'លឿន',
      trustOffline: 'មើលគន្លឹះក្រៅបណ្ដាញ',
    },
    how: {
      eyebrow: 'របៀបដំណើរការ',
      title: 'ជំហានសាមញ្ញ សម្រាប់សម្រេចចិត្តលឿននៅក្នុងស្រែ',
      subtitle: 'រចនាសម្រាប់កសិករ និងក្រុមការងារវាលស្រែ។ ថតរូប ពិនិត្យលទ្ធផល ហើយអនុវត្តភ្លាម។',
      captureTitle: 'ថតរូប',
      captureDesc: 'ថតរូបស្លឹកស្រូវឱ្យច្បាស់ ក្នុងពន្លឺល្អ ហើយដាក់ស្លឹកនៅកណ្ដាលរូប។',
      analyzeTitle: 'វិភាគ',
      analyzeDesc: 'បញ្ចូលតែម្ដង ហើយប្រព័ន្ធនឹងរកលំនាំជំងឺក្នុងរយៈពេលប៉ុន្មានវិនាទី។',
      actTitle: 'អនុវត្ត',
      actDesc: 'អនុវត្តការណែនាំព្យាបាល និងការពារ ដើម្បីទប់ស្កាត់ការរាលដាលឱ្យបានឆាប់។',
    },
    diseases: { eyebrow: 'បណ្ណាល័យជំងឺ', title: 'ជំងឺស្រូវដែលស្គាល់', risk: 'ហានិភ័យ' },
    faq: { eyebrow: 'សំណួរញឹកញាប់', title: 'សំណួរដែលគេសួរញឹកញាប់' },
    scanner: {
      eyebrow: 'ផ្នែកសាកល្បង',
      title: 'បញ្ចូល និងវិភាគស្លឹកស្រូវ',
      subtitle: 'ជ្រើសរើសរូបស្លឹកឱ្យច្បាស់ ដើម្បីទទួលឈ្មោះជំងឺ កម្រិតជឿជាក់ និងការណែនាំព្យាបាល។',
      optimizing: 'កំពុងបង្ហាប់រូប ដើម្បីបញ្ចូលបានលឿន...',
      analyzing: 'កំពុងវិភាគ...',
      upload: 'កំពុងបញ្ចូល {progress}%...',
      optimized: 'បានបង្ហាប់ពី {from} ទៅ {to}',
    },
    upload: {
      title: 'បញ្ចូលរូបស្លឹកស្រូវ',
      drag: 'អូសទម្លាក់ ឬចុចដើម្បីបញ្ចូល',
      note: 'គាំទ្រ JPG, PNG, WebP ឬ HEIC។',
      tip1: 'ពន្លឺល្អ',
      tip2: 'ស្លឹកនៅកណ្ដាល',
      tip3: 'មិនព្រាល',
      replace: 'ប្តូររូប',
      remove: 'លុប',
      analyze: 'វិភាគ',
      analyzing: 'កំពុងវិភាគ...',
      clickZoom: 'ចុចដើម្បីពង្រីក',
      close: 'បិទ',
    },
    footer: {
      desc: 'ជួយកសិកររកជំងឺស្រូវឱ្យបានឆាប់ និងការពារគុណភាពផលដំណាំ ដោយមានការគាំទ្រពី AI។',
      links: 'តំណភ្ជាប់',
      builtWith: 'បង្កើតដោយ',
      home: 'ទំព័រដើម',
      scanner: 'ស្កេន',
      diseases: 'ជំងឺ',
      about: 'អំពី',
      rights: 'រក្សាសិទ្ធិគ្រប់យ៉ាង។',
    },
  },
}

const language = ref('en')

function detectLanguage() {
  const saved = localStorage.getItem(STORAGE_KEY)
  if (saved && SUPPORTED.includes(saved)) return saved
  const candidates = [...(navigator.languages ?? []), navigator.language].filter(Boolean)
  return candidates.some((v) => String(v).toLowerCase().startsWith('km')) ? 'km' : 'en'
}

function applyLanguage(value) {
  language.value = SUPPORTED.includes(value) ? value : 'en'
  document.documentElement.setAttribute('lang', language.value === 'km' ? 'km' : 'en')
  localStorage.setItem(STORAGE_KEY, language.value)
}

function deepGet(obj, path) {
  return path.split('.').reduce((acc, key) => (acc && acc[key] != null ? acc[key] : null), obj)
}

function format(template, vars = {}) {
  return String(template).replace(/\{(\w+)\}/g, (_, key) => (vars[key] ?? `{${key}}`))
}

export function initWebI18n() {
  applyLanguage(detectLanguage())
}

export function useWebI18n() {
  const t = (key, vars = {}) => {
    const fallback = deepGet(messages.en, key) ?? key
    const localized = deepGet(messages[language.value], key) ?? fallback
    return format(localized, vars)
  }
  return {
    language: readonly(language),
    setLanguage: applyLanguage,
    t,
  }
}

