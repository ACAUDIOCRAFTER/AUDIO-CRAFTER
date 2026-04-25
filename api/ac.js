export default function handler(req, res) {
    const key = req.query.key
    if (key !== process.env.AC_SECRET_KEY) {
        return res.status(403).send("Forbidden")
    }
    res.setHeader("Content-Type", "text/plain")
    res.setHeader("Cache-Control", "no-store")
    const fs = require("fs")
    const path = require("path")
    const script = fs.readFileSync(path.join(process.cwd(), "private", "ac.lua"), "utf8")
    res.send(script)
}
