<script setup>
import { ref } from 'vue'

const props = defineProps({
  text: { type: String, required: true },
  chars: { type: String, default: '!<>-_\\/[]{}—=+*^?#________' },
  speed: { type: Number, default: 40 },
  scrambleChars: { type: Number, default: 8 },
  tag: { type: String, default: 'span' },
})

const display = ref(props.text)
let intervalId = null

function randomChar() {
  return props.chars[Math.floor(Math.random() * props.chars.length)]
}

function scramble() {
  if (intervalId) clearInterval(intervalId)

  const target = props.text
  const len = target.length
  let revealed = 0
  let frame = 0

  intervalId = setInterval(() => {
    frame++
    display.value = target
      .split('')
      .map((char, i) => {
        if (char === ' ') return ' '
        if (i < revealed) return char
        return randomChar()
      })
      .join('')

    if (frame % props.scrambleChars === 0) revealed++
    if (revealed > len) {
      clearInterval(intervalId)
      intervalId = null
    }
  }, props.speed)
}

function handleMouseEnter() {
  scramble()
}
</script>

<template>
  <component :is="tag" @mouseenter="handleMouseEnter">{{ display }}</component>
</template>
