<template>
  <NavBar />
  <router-view v-slot="{ Component }">
    <transition
      name="page"
      mode="out-in"
    >
      <component :is="Component" />
    </transition>
  </router-view>
</template>

<script setup>
import NavBar from '@/components/NavBar.vue'
</script>

<style scoped>
.page-enter-active {
  transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
}
.page-leave-active {
  transition: all 0.2s ease-in;
}
.page-enter-from {
  opacity: 0;
  transform: translateY(16px);
}
.page-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
