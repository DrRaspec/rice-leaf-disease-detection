import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import HomeView from './views/HomeView.vue'
import './assets/styles/main.css'
import { initUiSettings } from './composables/useUiSettings'

initUiSettings()

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: HomeView, meta: { title: 'RiceGuard AI' } },
    {
      path: '/about',
      component: () => import('./views/AboutView.vue'),
      meta: { title: 'About — RiceGuard AI' }
    }
  ],
  scrollBehavior(to, _from, savedPosition) {
    if (savedPosition) return savedPosition
    if (to.hash) {
      return {
        el: to.hash,
        top: 88,
        behavior: 'smooth',
      }
    }
    return { top: 0, behavior: 'smooth' }
  }
})

router.afterEach((to) => {
  document.title = to.meta.title || 'RiceGuard AI'
})

createApp(App).use(router).mount('#app')
