import { onMounted, onUnmounted } from 'vue'

/**
 * Scroll-triggered reveal animations using IntersectionObserver.
 * Elements with .reveal, .reveal-left, .reveal-right, .reveal-scale, .stagger-children
 * will get a .visible class when they enter the viewport.
 */
export function useReveal(rootRef = null) {
  let observer = null

  onMounted(() => {
    const selectors = '.reveal, .reveal-left, .reveal-right, .reveal-scale, .stagger-children'
    const root = rootRef?.value ?? document

    observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible')
            observer.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
    )

    root.querySelectorAll(selectors).forEach((el) => {
      observer.observe(el)
    })
  })

  onUnmounted(() => {
    observer?.disconnect()
  })
}
