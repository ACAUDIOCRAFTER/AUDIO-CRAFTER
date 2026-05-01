// api/manage.js — AC AudioCrafter manage API
// Uses same Vercel KV REST fetch pattern as custom-users.js

export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    if (req.method === 'OPTIONS') return res.status(200).end();

    const url   = process.env.KV_REST_API_URL;
    const token = process.env.KV_REST_API_TOKEN;
    if (!url || !token) return res.status(500).json({ error: 'KV not configured' });

    // ── Secrets — ALL come from Vercel env vars, nothing hardcoded ───────────
    // Set these in Vercel dashboard → Project → Settings → Environment Variables:
    //   AC_ADMIN_PASS   = your admin panel password
    //   AC_EXEC_SECRET  = a random string only your Lua script knows (e.g. "xK9mP2qR")
    const ADMIN_PASS  = process.env.AC_ADMIN_PASS;
    const EXEC_SECRET = process.env.AC_EXEC_SECRET;  // shared secret for exec pings
    const EXEC_TTL    = 45; // seconds before user drops off live list
    const hdrs        = { Authorization: 'Bearer ' + token };

    if (!ADMIN_PASS)  return res.status(500).json({ error: 'AC_ADMIN_PASS env var not set' });
    if (!EXEC_SECRET) return res.status(500).json({ error: 'AC_EXEC_SECRET env var not set' });

    // ── KV helpers (exact same pattern as custom-users.js) ───────────────────

    async function kvGet(key) {
        try {
            const r = await fetch(`${url}/get/${key}`, { headers: hdrs });
            const d = await r.json();
            if (!d.result) return null;
            return JSON.parse(d.result);
        } catch { return null; }
    }

    async function kvSet(key, value) {
        const encoded = encodeURIComponent(JSON.stringify(value));
        await fetch(`${url}/set/${key}/${encoded}`, { method: 'POST', headers: hdrs });
    }

    async function getBans()     { return (await kvGet('ac_banned'))    || []; }
    async function getWl()       { return (await kvGet('ac_whitelist')) || []; }
    async function getExecMap()  { return (await kvGet('ac_executing')) || {}; }
    async function setExecMap(m) { await kvSet('ac_executing', m); }

    function liveUsers(map) {
        const now = Date.now();
        return Object.entries(map)
            .filter(([, t]) => now - t < EXEC_TTL * 1000)
            .map(([u]) => u);
    }

    // ── Script pings — protected by EXEC_SECRET, no admin auth needed ────────

    // POST /api/manage?action=exec&user=USERNAME&secret=EXEC_SECRET
    if (req.method === 'POST' && req.query.action === 'exec') {
        // Reject if secret is wrong or missing — prevents fake ping spam
        if (req.query.secret !== EXEC_SECRET)
            return res.status(403).json({ ok: false, error: 'Invalid secret' });

        const username = req.query.user;
        if (!username) return res.status(400).json({ ok: false });

        const map = await getExecMap();
        map[username] = Date.now();
        // Prune stale entries
        const now = Date.now();
        for (const [u, t] of Object.entries(map))
            if (now - t >= EXEC_TTL * 1000) delete map[u];
        await setExecMap(map);
        return res.status(200).json({ ok: true });
    }

    // GET /api/manage?action=check&user=USERNAME&secret=EXEC_SECRET
    if (req.method === 'GET' && req.query.action === 'check') {
        if (req.query.secret !== EXEC_SECRET)
            return res.status(403).json({ ok: false, error: 'Invalid secret' });

        const username = req.query.user;
        if (!username) return res.status(400).json({ ok: false });

        const [bans, wl] = await Promise.all([getBans(), getWl()]);
        return res.status(200).json({
            ok:          true,
            banned:      bans.includes(username),
            whitelisted: wl.includes(username),
        });
    }

    // ── Admin routes — require admin password ─────────────────────────────────

    const auth = req.query.auth || (req.body && req.body.auth);
    if (auth !== ADMIN_PASS)
        return res.status(401).json({ ok: false, error: 'Unauthorized' });

    // GET /api/manage?auth=...  — dashboard poll
    if (req.method === 'GET') {
        const [bans, wl, execMap] = await Promise.all([getBans(), getWl(), getExecMap()]);
        return res.status(200).json({
            ok:        true,
            banned:    bans,
            whitelist: wl,
            executing: liveUsers(execMap),
        });
    }

    // POST /api/manage  — admin mutations (ban/whitelist)
    if (req.method === 'POST') {
        let body = req.body || {};
        if (typeof body === 'string') {
            try { body = JSON.parse(body); } catch {
                return res.status(400).json({ ok: false, error: 'Bad JSON' });
            }
        }
        const { action, username } = body;
        if (!username) return res.status(400).json({ ok: false, error: 'username required' });

        if (action === 'ban_add') {
            const bans = await getBans();
            if (!bans.includes(username)) bans.push(username);
            await kvSet('ac_banned', bans);
            // Kick them off the live list immediately
            const map = await getExecMap();
            delete map[username];
            await setExecMap(map);
            return res.status(200).json({ ok: true, banned: bans });
        }
        if (action === 'ban_remove') {
            const bans = (await getBans()).filter(u => u !== username);
            await kvSet('ac_banned', bans);
            return res.status(200).json({ ok: true, banned: bans });
        }
        if (action === 'whitelist_add') {
            const wl = await getWl();
            if (!wl.includes(username)) wl.push(username);
            await kvSet('ac_whitelist', wl);
            return res.status(200).json({ ok: true, whitelist: wl });
        }
        if (action === 'whitelist_remove') {
            const wl = (await getWl()).filter(u => u !== username);
            await kvSet('ac_whitelist', wl);
            return res.status(200).json({ ok: true, whitelist: wl });
        }
        return res.status(400).json({ ok: false, error: 'Unknown action: ' + action });
    }

    return res.status(405).json({ ok: false, error: 'Method not allowed' });
}
