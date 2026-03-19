<template>
  <main
    style="
      background:
        radial-gradient(circle at top, color-mix(in srgb, var(--rg-accent) 10%, transparent), transparent 30%),
        linear-gradient(180deg, var(--rg-bg) 0%, var(--rg-bg) 100%);
    "
  >
    <HeroSection />
    <ScannerSection />
    <DiseasesGrid />
    <FaqSection />
    <SiteFooter />
  </main>
</template>

<script setup>
import HeroSection from '@/components/home/HeroSection.vue'
import ScannerSection from '@/components/home/ScannerSection.vue'
import DiseasesGrid from '@/components/home/DiseasesGrid.vue'
import FaqSection from '@/components/home/FaqSection.vue'
import SiteFooter from '@/components/home/SiteFooter.vue'
</script>
