import fs from "fs";
import path from "path";

const VALID_KEY = "ACMelody2024secretkey";

export default function handler(req, res) {
  const key = req.query.key;

  // :x: wrong or missing key
  if (key !== VALID_KEY) {
    res.status(403).setHeader("Content-Type", "text/plain");
    return res.send("Forbidden");
  }

  const filePath = path.join(process.cwd(), "private", "ac.lua");
  const lua = fs.readFileSync(filePath, "utf8");

  res.status(200);
  res.setHeader("Content-Type", "text/plain");
  return res.send(lua);
}
