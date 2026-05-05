// api/upload-gif.js
import { Octokit } from "@octokit/rest";
import formidable from "formidable";
import fs from "fs";
import path from "path";

export const config = { api: { bodyParser: false } }; // required for file uploads

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const OWNER = "ACAUDIOCRAFTER";
const REPO = "AUDIO-CRAFTER";
const BRANCH = "main";
const GIFS_FOLDER = "dm_gifs";
const LIST_PATH = `${GIFS_FOLDER}/list.json`;

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    // 1. Parse the uploaded file
    const form = formidable({ multiples: false, keepExtensions: true });
    const [fields, files] = await form.parse(req);
    const uploadedFile = files.file?.[0];
    if (!uploadedFile) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    // 2. Generate a unique filename
    const ext = path.extname(uploadedFile.originalFilename);
    const timestamp = Date.now();
    const newFilename = `gif_${timestamp}${ext}`;
    const githubPath = `${GIFS_FOLDER}/${newFilename}`;

    // 3. Read file and convert to base64
    const fileBuffer = fs.readFileSync(uploadedFile.filepath);
    const base64Content = fileBuffer.toString("base64");

    // 4. Upload the GIF file to GitHub
    await octokit.repos.createOrUpdateFileContents({
      owner: OWNER,
      repo: REPO,
      path: githubPath,
      message: `Add GIF: ${newFilename}`,
      content: base64Content,
      branch: BRANCH,
    });

    // 5. Build the permanent raw URL
    const rawUrl = `https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${githubPath}`;

    // 6. Update list.json
    let currentList = [];
    try {
      const { data } = await octokit.repos.getContent({
        owner: OWNER,
        repo: REPO,
        path: LIST_PATH,
        ref: BRANCH,
      });
      const content = Buffer.from(data.content, "base64").toString("utf-8");
      currentList = JSON.parse(content);
    } catch (err) {
      if (err.status !== 404) throw err; // file doesn't exist yet
    }

    const label = fields.label?.[0] || "";
    currentList.push({
      url: rawUrl,
      thumb: rawUrl,   // use same URL as thumbnail (or generate a smaller one later)
      label: label,
    });

    const updatedListContent = JSON.stringify(currentList, null, 2);
    const listBase64 = Buffer.from(updatedListContent).toString("base64");

    let listSha = undefined;
    try {
      const { data } = await octokit.repos.getContent({
        owner: OWNER,
        repo: REPO,
        path: LIST_PATH,
        ref: BRANCH,
      });
      listSha = data.sha;
    } catch (err) {}

    await octokit.repos.createOrUpdateFileContents({
      owner: OWNER,
      repo: REPO,
      path: LIST_PATH,
      message: `Add GIF entry: ${newFilename}`,
      content: listBase64,
      sha: listSha,
      branch: BRANCH,
    });

    // 7. Return success
    res.status(200).json({ success: true, url: rawUrl });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
}
