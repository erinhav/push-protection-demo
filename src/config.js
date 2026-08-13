// src/config.js
//
// Credentials are read from the environment — never from source.
// Copy .env.example to .env (git-ignored) and set the value there.

const HF_API_TOKEN = process.env.HF_API_TOKEN;

if (!HF_API_TOKEN) {
  throw new Error(
    'HF_API_TOKEN is not set. Copy .env.example to .env and add your token.',
  );
}

module.exports = {
  HF_API_TOKEN,
  HF_BASE: process.env.HF_BASE ?? 'https://api-inference.huggingface.co',
  SUMMARY_MODEL: process.env.SUMMARY_MODEL ?? 'facebook/bart-large-cnn',
};
