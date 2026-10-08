const API_URL = import.meta.env.VITE_API_URL

async function request(path, body) {
  console.log('Payload:', body)
  const res = await fetch(`${API_URL}${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify(body),
  })

  const data = await res.json()

  if (!res.ok) {
    throw new Error(data.message || 'Terjadi kesalahan')
  }

  return data
}

export async function login(credentials) {
  const data = await request('/login', credentials)
  localStorage.setItem('token', data.token)
  localStorage.setItem('user', JSON.stringify(data.user))
  return data
}

export async function register(payload) {
  const data = await request('/register', payload)
  localStorage.setItem('token', data.token)
  localStorage.setItem('user', JSON.stringify(data.user))
  return data
}

export async function logout() {
  const token = localStorage.getItem('token')
  await fetch(`${API_URL}/logout`, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${token}`,
    },
  })
  localStorage.removeItem('token')
  localStorage.removeItem('user')
}

export function getToken() {
  return localStorage.getItem('token')
}

export function getUser() {
  const raw = localStorage.getItem('user')
  return raw ? JSON.parse(raw) : null
}
