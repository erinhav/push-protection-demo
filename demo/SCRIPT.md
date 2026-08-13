# Presenter run-book

Total run time: about 90 seconds. Rehearse once before presenting — step 4 is the moment everything hangs on.

## Before you start

- [ ] **Run `./demo/preflight.sh` — it must print `Ready to demo.`** See [Appendix A](#appendix-a--preflight-and-the-two-silent-failures)
- [ ] Repo is cloned locally and `git status` is clean
- [ ] Terminal font size raised to ~18pt — the block message is the hero shot and it must be legible in a deck
- [ ] Terminal window sized so the full block message fits without scrolling
- [ ] You are **not** in a screen-share that hides your terminal's colour output

## Step 1 — establish the setup

Show `src/config.js` and say the honest version of the story:

> "The token comes from the environment. That's the correct pattern. Now watch what happens when somebody in a hurry doesn't do that."

## Step 2 — generate the synthetic credential

```bash
./demo/make-demo-secret.sh
```

Copy the output. It is random, worthless, and matches the Hugging Face token format. Say so out loud — an audience of engineers will wonder, and answering it pre-empts the question:

> "This is synthetic. Push protection matches on pattern, not validity, so the block is identical either way."

## Step 3 — introduce the mistake

Paste the token into `src/config.js`, replacing the environment lookup:

```js
const HF_API_TOKEN = '<paste the generated token here>';
```

```bash
git add src/config.js
git commit -m "Temporarily hardcode token to unblock local testing"
```

Note that the commit **succeeds**. This matters, and it is worth saying plainly:

> "The commit went through. Push protection isn't a commit hook — it's at the push boundary. Local history is your business; what leaves your machine is GitHub's."

## Step 4 — the block  ⭐ hero moment

```bash
git push
```

The push is **rejected**. Let the output sit on screen for a beat before narrating. The audience should read it themselves.

Land the point:

> "Nothing reached GitHub. There's no alert to triage, no history to rewrite, no credential to rotate. The secret never left the laptop."

## Step 5 — recover, and close

```bash
git reset --hard HEAD~1
```

> "In real life the fix is the same shape: put it back in the environment, and push."

## Optional step 6 — the bypass path

Only show this to an internal audience, and only if someone asks. **Never** capture it for marketing.

Push protection lets a developer bypass the block with a stated reason, which is recorded and surfaces as an alert with `push_protection_bypassed: true`. It's the right design — an escape hatch that leaves an audit trail — but it is not the story you want in a launch asset. A screenshot of the block being overridden reads as "the feature was defeated."

If you do demo it, make sure you're in a throwaway repo, and delete it afterwards.

---

## Screenshot shot-list

These have to be captured by hand — a real push against a real remote, with real UI. Don't mock them up; product screenshots that don't match shipped UI are a problem the moment someone spots it.

| # | Shot | Where | Notes |
|---|------|-------|-------|
| 1 | `src/config.js` showing the env-var pattern | Editor | The "before" state |
| 2 | Successful `git commit` | Terminal | Proves the block is at push, not commit |
| 3 | **The rejected push** | Terminal | **Hero shot.** Full message, no scroll, large font |
| 4 | The same block in the editor's Git output | VS Code | Optional — shows it isn't CLI-only |
| 5 | Push protection settings toggle | Repo Settings → Code security | Establishes it's a setting, on by default for public repos |
| 6 | Clean security tab — zero alerts | Repo → Security | The payoff: nothing to clean up |

**Deliberately excluded:** the bypass dialog, and any alert list showing `push_protection_bypassed: true`. See step 6.

For shot 3, capture the terminal at 2x/Retina. Cropped, upscaled terminal text looks bad on a conference slide and can't be re-used at print resolution.

---

## Appendix A — preflight, and the two silent failures

**Run this before every demo:**

```bash
./demo/preflight.sh
```

It must print `Ready to demo.` Do not skip it. Both failure modes below are silent — they don't produce an error, they produce a push that quietly **succeeds**, which demonstrates the exact opposite of the intended message.

### Silent failure 1 — push protection is off

```bash
gh api repos/OWNER/REPO --jq '.security_and_analysis.secret_scanning_push_protection.status'
```

Expect `enabled`. If it returns `disabled`, the secret is pushed and lands on the remote.

### Silent failure 2 — the token doesn't match the pattern

The token body must be **letters only**: `hf_` followed by `[a-zA-Z]{34}`.

A body containing **digits** — `hf_zYTIKZbMIJVwWfOOiS8CiG4KlbMvg9SkL1` — is the right length and looks entirely plausible, but is **not detected**. The push sails straight through.

This was established empirically: pushing five candidates in one commit, the letters-only ones were each reported by the block, and the digit-bearing ones were not flagged at all. Mutating individual letters of a known-good token still triggers detection, so this is a character-class constraint, not a checksum.

`make-demo-secret.sh` generates letters-only bodies. If you hand-craft a token, verify it:

```bash
echo "$TOKEN" | grep -qE '^hf_[A-Za-z]{34}$' && echo ok || echo "WILL NOT FIRE"
```

### Afterwards

Confirm nothing landed:

```bash
gh api repos/OWNER/REPO/secret-scanning/alerts --jq 'length'   # expect 0
```

If that ever returns non-zero, the demo leaked. Reset and force-push to the last clean commit, then re-check.
