// src/summarize.js
//
// HotPot Express — condenses customer reviews into a one-line summary
// for the store dashboard, using a Hugging Face inference endpoint.

const { HF_API_TOKEN, HF_BASE, SUMMARY_MODEL } = require('./config');

async function summarizeReviews(reviews) {
  if (!reviews.length) return null;

  const res = await fetch(`${HF_BASE}/models/${SUMMARY_MODEL}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${HF_API_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      inputs: reviews.map((r) => r.body).join('\n\n'),
      parameters: { max_length: 60, min_length: 15 },
    }),
  });

  if (!res.ok) {
    throw new Error(`Summarization failed (${res.status}): ${await res.text()}`);
  }

  const [result] = await res.json();
  return result.summary_text;
}

module.exports = { summarizeReviews };
