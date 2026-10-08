import { ref } from 'vue'

const STORAGE_KEY = 'theme'

function readInitial() {
  try {
    return localStorage.getItem(STORAGE_KEY) === 'light' ? 'light' : 'dark'
  } catch {
    return 'dark'
  }
}

export const theme = ref(readInitial())

function apply(value) {
  document.documentElement.classList.toggle('dark', value === 'dark')
}

apply(theme.value)

export function toggleTheme() {
  theme.value = theme.value === 'dark' ? 'light' : 'dark'
  apply(theme.value)
  try {
    localStorage.setItem(STORAGE_KEY, theme.value)
  } catch {
    // storage unavailable: theme still applies for this session
  }
}
