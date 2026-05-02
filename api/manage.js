export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    if (req.method === 'OPTIONS') return res.status(200).end();

    const kvUrl  = process.env.KV_REST_API_URL;
    const kvTok  = process.env.KV_REST_API_TOKEN;
    if (!kvUrl || !kvTok) return res.status(500).json({ error: 'KV not configured' });

    const ADMIN_PASS  = process.env.AC_ADMIN_PASS;
    const EXEC_SECRET = process.env.AC_EXEC_SECRET;
    const EXEC_TTL    = 45;
    const MSG_TTL_MS  = 7 * 24 * 60 * 60 * 1000;
    const GC_MAX      = 200;   // max global chat messages to keep
    const hdrs        = { Authorization: 'Bearer ' + kvTok };

    if (!ADMIN_PASS || !EXEC_SECRET)
        return res.status(500).json({ error: 'Env vars not set' });

    async function kvGet(key) {
        try {
            const r = await fetch(`${kvUrl}/get/${encodeURIComponent(key)}`, { headers: hdrs });
            const d = await r.json();
            return d.result ? JSON.parse(d.result) : null;
        } catch { return null; }
    }
    async function kvSet(key, value) {
        const enc = encodeURIComponent(JSON.stringify(value));
        await fetch(`${kvUrl}/set/${encodeURIComponent(key)}/${enc}`, { method: 'POST', headers: hdrs });
    }

    const q   = req.query;
    const bod = req.body || {};
    const action = q.action || bod.action;
    const secret = q.secret || bod.secret;

    // ── exec_list ─────────────────────────────────────────────────────────────
    if (action === 'exec_list') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false, error:'Invalid secret' });
        const map = (await kvGet('ac_executing')) || {};
        const now = Date.now();
        return res.status(200).json({ ok:true, executing: Object.entries(map).filter(([,t])=>now-t<EXEC_TTL*1000).map(([u])=>u) });
    }

    // ── exec ping ─────────────────────────────────────────────────────────────
    if (action === 'exec') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false, error:'Invalid secret' });
        const username=q.user, userId=q.uid||'', displayName=q.dn||q.user;
        if (!username) return res.status(400).json({ ok:false });
        const now=Date.now();
        const map=(await kvGet('ac_executing'))||{};
        map[username]=now;
        for(const [u,t] of Object.entries(map)) if(now-t>=EXEC_TTL*1000) delete map[u];
        await kvSet('ac_executing',map);
        const all=(await kvGet('ac_all_users'))||{};
        if(!all[username]) all[username]={userId,displayName,firstSeen:now,lastSeen:now};
        else { all[username].lastSeen=now; if(userId) all[username].userId=userId; if(displayName) all[username].displayName=displayName; }
        await kvSet('ac_all_users',all);
        return res.status(200).json({ ok:true });
    }

    // ── dm_send ───────────────────────────────────────────────────────────────
    if (action === 'dm_send') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false, error:'Invalid secret' });
        const from=bod.from||q.from, fromId=bod.fromId||q.fromId, toId=bod.toId||q.toId, text=bod.text||q.text, ts=Number(bod.ts||q.ts||Date.now());
        if (!from||!fromId||!toId||!text) return res.status(400).json({ ok:false, error:'Missing fields' });
        const key=`ac_dm_inbox_${toId}`;
        const inbox=(await kvGet(key))||[];
        inbox.push({from,fromId,text,ts});
        // Keep all DM messages forever (no deletion)
        await kvSet(key, inbox);
        return res.status(200).json({ ok:true });
    }

    // ── dm_poll ───────────────────────────────────────────────────────────────
    if (action === 'dm_poll') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false, error:'Invalid secret' });
        const toId=q.toId||bod.toId;
        if (!toId) return res.status(400).json({ ok:false });
        const inbox=(await kvGet(`ac_dm_inbox_${toId}`))||[];
        const typing=(await kvGet(`ac_dm_typing_${toId}`))||[];
        const now=Date.now();
        const activeTyping=typing.filter(t=>now-t.ts<5000);
        return res.status(200).json({ ok:true, messages:inbox, typing:activeTyping });
    }

    // ── gc_send — global chat ─────────────────────────────────────────────────
    if (action === 'gc_send') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false, error:'Invalid secret' });
        const from=bod.from||q.from, fromId=bod.fromId||q.fromId, text=bod.text||q.text, ts=Number(bod.ts||q.ts||Date.now());
        if (!from||!text) return res.status(400).json({ ok:false, error:'Missing fields' });
        const msgs=(await kvGet('ac_global_chat'))||[];
        msgs.push({from,fromId,text,ts});
        // Keep only last GC_MAX messages
        if (msgs.length > GC_MAX) msgs.splice(0, msgs.length - GC_MAX);
        await kvSet('ac_global_chat', msgs);
        return res.status(200).json({ ok:true });
    }

    // ── gc_poll — fetch global chat since timestamp ───────────────────────────
    if (action === 'gc_poll') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false, error:'Invalid secret' });
        const since=Number(q.since||0);
        const msgs=(await kvGet('ac_global_chat'))||[];
        const gcTyping=(await kvGet('ac_gc_typing'))||[];
        const gcNow=Date.now();
        return res.status(200).json({ ok:true, messages: msgs.filter(m=>m.ts>since), typing:gcTyping.filter(t=>gcNow-t.ts<5000) });
    }


    // ── dm_typing — user is typing in a DM ───────────────────────────────────
    if (action === 'dm_typing') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false });
        const from=q.from, fromId=q.fromId, toId=q.toId;
        if (!from||!fromId||!toId) return res.status(400).json({ ok:false });
        const key=`ac_dm_typing_${toId}`;
        const typing=(await kvGet(key))||[];
        const now=Date.now();
        const filtered=typing.filter(t=>t.fromId!==fromId&&now-t.ts<5000);
        filtered.push({from,fromId,ts:now});
        await kvSet(key,filtered);
        return res.status(200).json({ ok:true });
    }

    // ── gc_typing — user is typing in global chat ─────────────────────────────
    if (action === 'gc_typing') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false });
        const from=q.from||bod.from, fromId=q.fromId||bod.fromId;
        if (!from) return res.status(400).json({ ok:false });
        const typing=(await kvGet('ac_gc_typing'))||[];
        const now=Date.now();
        const filtered=typing.filter(t=>t.fromId!==fromId&&now-t.ts<5000);
        filtered.push({from,fromId,ts:now});
        await kvSet('ac_gc_typing',filtered);
        return res.status(200).json({ ok:true });
    }

    // ── ban/whitelist check ───────────────────────────────────────────────────
    if (action === 'check') {
        if (secret !== EXEC_SECRET) return res.status(403).json({ ok:false, error:'Invalid secret' });
        const username=q.user;
        const [bans,wl]=await Promise.all([kvGet('ac_banned'),kvGet('ac_whitelist')]);
        return res.status(200).json({ ok:true, banned:(bans||[]).includes(username), whitelisted:(wl||[]).includes(username) });
    }

    // ── Admin ─────────────────────────────────────────────────────────────────
    const auth=q.auth||bod.auth;
    if (auth !== ADMIN_PASS) return res.status(401).json({ ok:false, error:'Unauthorized' });

    if (req.method === 'GET') {
        const [bans,wl,execMap,allUsers]=await Promise.all([kvGet('ac_banned'),kvGet('ac_whitelist'),kvGet('ac_executing'),kvGet('ac_all_users')]);
        const now=Date.now();
        return res.status(200).json({ ok:true, banned:bans||[], whitelist:wl||[],
            executing:Object.entries(execMap||{}).filter(([,t])=>now-t<EXEC_TTL*1000).map(([u])=>u),
            allUsers:allUsers||{} });
    }

    if (req.method === 'POST') {
        let body=typeof bod==='string'?JSON.parse(bod):bod;
        const {action:a, username:u}=body;
        if (!u) return res.status(400).json({ ok:false, error:'username required' });
        if (a==='ban_add'){const bans=(await kvGet('ac_banned'))||[];if(!bans.includes(u))bans.push(u);await kvSet('ac_banned',bans);const m=(await kvGet('ac_executing'))||{};delete m[u];await kvSet('ac_executing',m);return res.status(200).json({ok:true,banned:bans});}
        if (a==='ban_remove'){const bans=((await kvGet('ac_banned'))||[]).filter(x=>x!==u);await kvSet('ac_banned',bans);return res.status(200).json({ok:true,banned:bans});}
        if (a==='whitelist_add'){const wl=(await kvGet('ac_whitelist'))||[];if(!wl.includes(u))wl.push(u);await kvSet('ac_whitelist',wl);return res.status(200).json({ok:true,whitelist:wl});}
        if (a==='whitelist_remove'){const wl=((await kvGet('ac_whitelist'))||[]).filter(x=>x!==u);await kvSet('ac_whitelist',wl);return res.status(200).json({ok:true,whitelist:wl});}
        return res.status(400).json({ ok:false, error:'Unknown action' });
    }
    return res.status(405).json({ ok:false, error:'Method not allowed' });
}
