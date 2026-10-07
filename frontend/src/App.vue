<script setup>
import { ref, onMounted } from 'vue'
import TrueFocus from '@/components/animations/TrueFokus.vue'
import PixelSwap from '@/components/animations/PixelSwap.vue'

const isSwapped = ref(false)
const showSplash = ref(true)
const fadeOut = ref(false)

onMounted(() => {
  setTimeout(() => {
    isSwapped.value = true
  }, 4000)

  setTimeout(() => {
    fadeOut.value = true
  }, 4900)

  setTimeout(() => {
    showSplash.value = false
  }, 5900)
})
</script>

<template>
  <RouterView />

  <div v-if="showSplash" class="splash" :class="{ 'splash-fade-out': fadeOut }">
    <PixelSwap
      :pixelSize="64"
      :gap="0"
      :pixelRadius="0"
      :pixelSpin="0"
      :pixelScale="0.5"
      :duration="800"
      :pixelDuration="300"
      pattern="random"
      :randomness="0"
      fade
      trigger="manual"
      :active="isSwapped"
      :style="{ width: '100%', height: '100%' }"
    >
      <template #first>
        <div class="splash-content">
          <TrueFocus
            sentence="Katerin Kita"
            :manual-mode="false"
            :blur-amount="3"
            border-color="red"
            :animation-duration="1"
            :pause-between-animations="1"
          />
        </div>
      </template>
      <template #second>
        <div style="width: 100%; height: 100%; background-color: var(--color-primary)"></div>
      </template>
    </PixelSwap>
  </div>
</template>
