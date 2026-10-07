const API_URL = import.meta.env.VITE_API_URL

export async function login(credentials) {
  const res = await fetch(`${API_URL}/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify(credentials),
  })

  if (!res.ok) throw new Error('Email atau password salah')
  return res.json()
}

export async function register(data) {
  const res = await fetch(`${API_URL}/register`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: json.stringify(data),
  })

  if (!res.ok) throw new Error('Registrasi gagal, periksa data kamu')
  return res.json()
}
