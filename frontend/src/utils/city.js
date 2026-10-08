/**
 * Matches a reverse-geocoding result's address parts against the known
 * city list, trying the most specific locality fields first and ignoring
 * the "Kota"/"Kabupaten" administrative prefix.
 */
export function matchCityFromAddress(addressParts, cities) {
  const candidates = [
    addressParts.city,
    addressParts.town,
    addressParts.municipality,
    addressParts.county,
    addressParts.city_district,
    addressParts.suburb,
  ].filter(Boolean)

  for (const candidate of candidates) {
    const normalized = candidate.replace(/^(Kota|Kabupaten)\s+/i, '').trim().toLowerCase()
    const match = cities.find(
      (c) =>
        c.name.toLowerCase() === normalized ||
        c.name.toLowerCase().replace(/^(kota|kabupaten)\s+/i, '') === normalized,
    )
    if (match) return match.name
  }

  return null
}
