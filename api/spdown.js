// api/spdown.js  — deploy to your audio-crafter.vercel.app project
// Place this file at: /api/spdown.js in your repo root
// Endpoint: https://audio-crafter.vercel.app/api/spdown?type=playlist&id=SPOTIFY_ID
export const config = { runtime: "edge" };
const SD_BASE = "https://api.spotifydown.com";
const SD_HEADERS = {
  "origin": "https://spotifydown.com",
  "referer": "https://spotifydown.com/",
  "sec-fetch-site": "same-site",
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
};
async function resolveTrackUrl(trackId) {
  const res = await fetch(`${SD_BASE}/download/${trackId}`, { headers: SD_HEADERS });
  if (!res.ok) return null;
  const data = await res.json();
  return data.link || data.downloadLink || null;
}
export default async function handler(req) {
  const { searchParams } = new URL(req.url);
  const type = searchParams.get("type") || "track";
  const id = searchParams.get("id");
  if (!id) {
    return new Response(JSON.stringify({ error: "missing id" }), {
      status: 400,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  }
  try {
    const tracks = [];
    if (type === "track") {
      // Single track
      const dlUrl = await resolveTrackUrl(id);
      if (dlUrl) {
        // Get metadata
        const meta = await fetch(`${SD_BASE}/track/${id}`, { headers: SD_HEADERS });
        const metaData = meta.ok ? await meta.json() : {};
        tracks.push({
          url: dlUrl,
          title: metaData.title || metaData.name || "Track",
          artist: metaData.artists || metaData.artist || "",
          art: metaData.cover || metaData.image || "",
        });
      }
    } else {
      // Playlist or album - get track list
      const listRes = await fetch(`${SD_BASE}/${type}/${id}`, { headers: SD_HEADERS });
      if (!listRes.ok) throw new Error("Failed to fetch track list");
      const listData = await listRes.json();
      const trackList = listData.trackList || listData.tracks || [];
      // Resolve download URLs (limit to 20 tracks to avoid timeout)
      const limited = trackList.slice(0, 20);
      const resolved = await Promise.allSettled(
        limited.map(async (track) => {
          const tid = track.id || track.spotifyId;
          if (!tid) return null;
          const dlUrl = await resolveTrackUrl(tid);
          if (!dlUrl) return null;
          return {
            url: dlUrl,
            title: track.title || track.name || "Track",
            artist: track.artists || track.artist || "",
            art: track.cover || track.image || "",
          };
        })
      );
      for (const r of resolved) {
        if (r.status === "fulfilled" && r.value) tracks.push(r.value);
      }
    }
    return new Response(JSON.stringify({ tracks }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "no-store",
      },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message, tracks: [] }), {
      status: 500,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  }
}
