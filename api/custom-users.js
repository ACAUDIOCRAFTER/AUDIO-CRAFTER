// api/custom-users.js
// Vercel serverless function — stores custom AC AudioCrafter users
// Deploy to Vercel alongside your existing audio-crafter project
//
// Uses Vercel KV (Redis) for storage. If you don't have KV set up,
// falls back to a hardcoded JSON store (good for testing).
//
// SETUP:
//   1. Add this file to your audio-crafter Vercel project at /api/custom-users.js
//   2. Set env var AC_ADMIN_PASS to your admin password in Vercel dashboard
//   3. Optionally set up Vercel KV and add KV_REST_API_URL + KV_REST_API_TOKEN env vars

const ADMIN_PASS = process.env.AC_ADMIN_PASS || 'acadmin2024'
const KV_URL     = process.env.KV_REST_API_URL
const KV_TOKEN   = process.env.KV_REST_API_TOKEN
const KV_KEY     = 'ac_custom_users'

// ── KV helpers (Vercel KV REST API)
async function kvGet() {
  if (!KV_URL) return null
  try {
    const r = await fetch(`${KV_URL}/get/${KV_KEY}`, {
      headers: { Authorization: `Bearer ${KV_TOKEN}` }
    })
    const d = await r.json()
    return d.result ? JSON.parse(d.result) : {}
  } catch { return null }
}

async function kvSet(data) {
  if (!KV_URL) return false
  try {
    await fetch(`${KV_URL}/set/${KV_KEY}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${KV_TOKEN}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ value: JSON.stringify(data) })
    })
    return true
  } catch { return false }
}

// Fallback in-memory store (resets on cold start — use KV for persistence)
let memStore = {}

async function getUsers() {
  const kv = await kvGet()
  return kv || memStore
}

async function setUsers(data) {
  memStore = data
  await kvSet(data)
}

// ── CORS headers
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, x-secret',
  'Content-Type': 'application/json'
}

export default async function handler(req, res) {
  // Preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).set(CORS).end()
  }
  Object.entries(CORS).forEach(([k, v]) => res.setHeader(k, v))

  // ── GET — read users (also used for auth check)
  if (req.method === 'GET') {
    const auth = req.query.auth || req.headers['x-secret']
    if (auth !== ADMIN_PASS) {
      // Script (no auth) can read the public format
      // But only if request comes without auth param — script just reads
      if (auth === undefined) {
        const users = await getUsers()
        return res.status(200).json({ ok: true, users })
      }
      return res.status(401).json({ ok: false, error: 'Wrong password' })
    }
    const users = await getUsers()
    return res.status(200).json({ ok: true, users })
  }

  // ── POST — add/edit/delete user (admin only)
  if (req.method === 'POST') {
    let body = req.body
    if (typeof body === 'string') {
      try { body = JSON.parse(body) } catch { return res.status(400).json({ ok: false, error: 'Bad JSON' }) }
    }

    const { auth, action, username, tag, pfpId, bgId } = body || {}

    if (auth !== ADMIN_PASS) {
      return res.status(401).json({ ok: false, error: 'Wrong password' })
    }

    if (!username) return res.status(400).json({ ok: false, error: 'username required' })

    const users = await getUsers()

    if (action === 'set') {
      if (!tag) return res.status(400).json({ ok: false, error: 'tag required' })
      users[username] = {
        tag:   tag.trim(),
        pfpId: (pfpId || '').trim(),
        bgId:  (bgId  || '').trim(),
      }
      await setUsers(users)
      return res.status(200).json({ ok: true, users })
    }

    if (action === 'delete') {
      delete users[username]
      await setUsers(users)
      return res.status(200).json({ ok: true, users })
    }

    return res.status(400).json({ ok: false, error: 'Unknown action' })
  }

  return res.status(405).json({ ok: false, error: 'Method not allowed' })
}
