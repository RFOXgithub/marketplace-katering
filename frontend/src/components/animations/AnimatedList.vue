<template>
  <div :class="`relative w-full ${className}`.trim()">
    <div
      ref="listRef"
      :class="[
        'max-h-[28rem] overflow-y-auto',
        !displayScrollbar && '[&::-webkit-scrollbar]:hidden scrollbar-none',
      ]"
      :style="{ scrollbarWidth: displayScrollbar ? 'thin' : 'none' }"
      @scroll="handleScroll"
    >
      <AnimatedItem
        v-for="(item, index) in items"
        :key="index"
        :index="index"
        :delay="0.08"
        @mouseenter="handleItemMouseEnter(index)"
        @click="handleItemClick(item, index)"
      >
        <slot :item="item" :index="index" :is-selected="selectedIndex === index" />
      </AnimatedItem>
    </div>
    <template v-if="showGradients">
      <div
        class="pointer-events-none absolute inset-x-0 top-0 h-8 bg-gradient-to-b from-card to-transparent transition-opacity duration-300 ease"
        :style="{ opacity: topGradientOpacity }"
      />
      <div
        class="pointer-events-none absolute inset-x-0 bottom-0 h-8 bg-gradient-to-t from-card to-transparent transition-opacity duration-300 ease"
        :style="{ opacity: bottomGradientOpacity }"
      />
    </template>
  </div>
</template>

<script setup>
import { motion, useInView } from 'motion-v'
import { defineComponent, h, onMounted, onUnmounted, ref, watch } from 'vue'

const AnimatedItem = defineComponent({
  name: 'AnimatedItem',
  props: {
    index: { type: Number, required: true },
    delay: { type: Number, default: 0 },
  },
  emits: ['mouseenter', 'click'],
  setup(props, { slots, emit }) {
    const itemRef = ref(null)
    const inView = useInView(itemRef, { amount: 0.3, once: true })

    return () =>
      h(
        motion.div,
        {
          ref: itemRef,
          'data-index': props.index,
          initial: { scale: 0.9, opacity: 0 },
          animate: inView.value ? { scale: 1, opacity: 1 } : { scale: 0.9, opacity: 0 },
          transition: { duration: 0.25, delay: props.delay },
          onMouseenter: (e) => emit('mouseenter', e),
          onClick: (e) => emit('click', e),
        },
        slots.default?.(),
      )
  },
})

const props = defineProps({
  items: { type: Array, default: () => [] },
  showGradients: { type: Boolean, default: true },
  enableArrowNavigation: { type: Boolean, default: false },
  className: { type: String, default: '' },
  displayScrollbar: { type: Boolean, default: true },
  initialSelectedIndex: { type: Number, default: -1 },
})

const emit = defineEmits(['itemSelected'])

const listRef = ref(null)
const selectedIndex = ref(props.initialSelectedIndex)
const keyboardNav = ref(false)
const topGradientOpacity = ref(0)
const bottomGradientOpacity = ref(1)

const handleItemMouseEnter = (index) => {
  selectedIndex.value = index
}

const handleItemClick = (item, index) => {
  selectedIndex.value = index
  emit('itemSelected', item, index)
}

const handleScroll = (e) => {
  const target = e.target
  const { scrollTop, scrollHeight, clientHeight } = target
  topGradientOpacity.value = Math.min(scrollTop / 50, 1)
  const bottomDistance = scrollHeight - (scrollTop + clientHeight)
  bottomGradientOpacity.value = scrollHeight <= clientHeight ? 0 : Math.min(bottomDistance / 50, 1)
}

const handleKeyDown = (e) => {
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    keyboardNav.value = true
    selectedIndex.value = Math.min(selectedIndex.value + 1, props.items.length - 1)
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    keyboardNav.value = true
    selectedIndex.value = Math.max(selectedIndex.value - 1, 0)
  } else if (e.key === 'Enter') {
    if (selectedIndex.value >= 0 && selectedIndex.value < props.items.length) {
      e.preventDefault()
      emit('itemSelected', props.items[selectedIndex.value], selectedIndex.value)
    }
  }
}

watch([selectedIndex, keyboardNav], () => {
  if (!keyboardNav.value || selectedIndex.value < 0 || !listRef.value) return
  const container = listRef.value
  const selectedItem = container.querySelector(`[data-index="${selectedIndex.value}"]`)
  if (selectedItem) {
    const extraMargin = 50
    const containerScrollTop = container.scrollTop
    const containerHeight = container.clientHeight
    const itemTop = selectedItem.offsetTop
    const itemBottom = itemTop + selectedItem.offsetHeight
    if (itemTop < containerScrollTop + extraMargin) {
      container.scrollTo({ top: itemTop - extraMargin, behavior: 'smooth' })
    } else if (itemBottom > containerScrollTop + containerHeight - extraMargin) {
      container.scrollTo({ top: itemBottom - containerHeight + extraMargin, behavior: 'smooth' })
    }
  }
  keyboardNav.value = false
})

onMounted(() => {
  if (props.enableArrowNavigation) {
    window.addEventListener('keydown', handleKeyDown)
  }
})

onUnmounted(() => {
  if (props.enableArrowNavigation) {
    window.removeEventListener('keydown', handleKeyDown)
  }
})
</script>
