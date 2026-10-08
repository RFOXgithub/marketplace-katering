const REVERSE_GEOCODE_URL = 'https://nominatim.openstreetmap.org/reverse'

export async function reverseGeocode(latitude, longitude) {
  const res = await fetch(
    `${REVERSE_GEOCODE_URL}?format=json&lat=${latitude}&lon=${longitude}`,
    { headers: { Accept: 'application/json' } },
  )
  return res.json()
}
