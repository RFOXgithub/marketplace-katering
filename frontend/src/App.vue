<script setup>
import { ref, onMounted } from 'vue'
import router from '@/router'
import TrueFocus from '@/components/animations/TrueFokus.vue'
import PixelSwap from '@/components/animations/PixelSwap.vue'
import LightRays from '@/components/animations/LightRays.vue'
import CartConflictModal from '@/components/customer/CartConflictModal.vue'
import ClickSpark from '@/components/animations/ClickSpark.vue'

const isSwapped = ref(false)
const fadeOut = ref(false)
const transitionName = ref('slide-left')

const hasSeenSplash = sessionStorage.getItem('hasSeenSplash')
const showSplash = ref(!hasSeenSplash)

router.beforeEach((to, from) => {
  const toOrder = to.meta.order ?? 0
  const fromOrder = from.meta.order ?? 0
  transitionName.value = toOrder < fromOrder ? 'slide-right' : 'slide-left'
})

onMounted(() => {
  if (!showSplash.value) return

  sessionStorage.setItem('hasSeenSplash', 'true')

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
  <ClickSpark spark-color="#f5a623" :spark-size="10" :spark-radius="15" :spark-count="8" :duration="400">
  <div class="page-wrapper">
    <RouterView v-slot="{ Component, route }">
      <Transition :name="transitionName">
        <component :is="Component" :key="route.path" />
      </Transition>
    </RouterView>
  </div>

  <CartConflictModal />

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
        <div class="splash-content" style="position: relative; overflow: hidden">
          <div style="position: absolute; inset: 0">
            <LightRays
              rays-origin="top-center"
              rays-color="#f5a623"
              :rays-speed="1.5"
              :light-spread="0.8"
              :ray-length="1.2"
              :follow-mouse="true"
              :mouse-influence="0.1"
              :noise-amount="0.1"
              :distortion="0.05"
            />
          </div>
          <div
            style="
              position: relative;
              z-index: 10;
              display: flex;
              flex-direction: column;
              align-items: center;
              gap: 1rem;
            "
          >
            <TrueFocus
              sentence="Marketplace Katering"
              :manual-mode="false"
              :blur-amount="3"
              border-color="#f5a623"
              :animation-duration="1"
              :pause-between-animations="1"
            />
            <span
              style="
                border-radius: 9999px;
                background: rgba(245, 166, 35, 0.12);
                padding: 0.35rem 0.9rem;
                font-size: 10px;
                font-weight: 600;
                letter-spacing: 0.2em;
                text-transform: uppercase;
                color: #f5a623;
              "
            >
              Katering bertemu kantor
            </span>
          </div>
        </div>
      </template>
      <template #second>
        <div style="width: 100%; height: 100%; background-color: var(--color-primary)"></div>
      </template>
    </PixelSwap>
  </div>
  </ClickSpark>
</template>
