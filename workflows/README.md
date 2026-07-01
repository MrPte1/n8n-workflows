# Workflow Exports — Index

This folder holds git-tracked JSON exports of n8n workflows. n8n's live state
(the DB inside the running container) is the actual source of truth for what
executes; these files are periodic manual exports and can drift from live
state — that drift is exactly what this README exists to document and
minimize going forward.

## Meeting-audio pipeline lineage (the "3 overlapping exports" finding)

Three files (`meeting-pipeline.json`, `meeting-pipeline-v2.json`,
`meeting-audio-pipeline.json`) all export a workflow whose webhook path is
`meeting-audio` (`POST http://localhost:5678/webhook/meeting-audio` — see
`docker-compose.yml`, port `5678`, and `scripts/pipeline-test-loop.sh`). Only
one workflow can actually own that webhook path in a live n8n instance at a
time, so at most one of these (or of the 5-file split below) is truly live.

**Reconstructed lineage, from `git log` (dates/SHAs are load-bearing evidence,
not paraphrase):**

1. **`meeting-pipeline.json`** ("Meeting Audio Pipeline") — the original v1
   monolithic workflow. Committed `1ce6d62` (2026-03-05), developed steadily
   through `2a09564` (2026-03-17 22:05). No commit has touched it since.
   Its committed `"active"` field is `true`, but that value was already
   present at creation and was never revisited after v2 was built and
   activated — i.e. it is a **stale artifact of the export, not evidence of
   current live state**.

2. **`meeting-audio-pipeline.json`** ("Meeting Audio Pipeline") — added in a
   single commit, `dc998e6` (2026-03-17 11:12, "fix: Build LLM Body reads
   transcript from Get Transcript node, not $input", fixing bug B9). Same
   workflow name and webhook path as (1). It was never touched again by any
   later commit. Content-wise it is a point-in-time duplicate/backup of v1
   taken ~1.5h before v1 development continued (`3db93a1`, 12:34 the same
   day) and ~1.7h before the v2 rewrite began (`9f8189d`, 12:54). There is no
   commit message or later reference anywhere in history that treats this
   file as a distinct, ongoing workflow — it reads as an orphaned one-off
   export.

3. **`meeting-pipeline-v2.json`** ("Meeting Audio Pipeline v2") — created by
   `9f8189d` (2026-03-17 12:54, "feat: M59 divide-and-conquer meeting
   pipeline v2"), explicitly built to replace (1). Activated by `fa07f51`
   (2026-03-18 06:38, "activate v2 pipeline"). Then explicitly superseded by
   `a1e690d` (2026-03-18 17:59, "feat: split meeting pipeline into 5
   workflows"), whose commit body states verbatim: *"Old meeting-pipeline-v2
   deactivated; orchestrator uses same webhook path."*
   One later commit, `9d30cc8` (2026-03-19 15:43), has a commit message
   claiming *"Switched back to v2 monolithic pipeline (n8n 2.10.3
   executeWorkflow sub-workflow publishing broken — '0 published workflows'
   despite correct DB)"* and does touch `meeting-pipeline-v2.json`. **However**,
   checking the actual file-touch pattern of every commit from that point
   forward (measured, not assumed): all ~15 commits from `9d30cc8`
   (15:43) through the last pipeline-related commit in the repo, `cdabffe`
   (2026-03-20 07:09), touch **only** `pipeline-orchestrator.json` /
   `pipeline-analyze.json` / `pipeline-transcribe.json` / `pipeline-extract.json`
   / `pipeline-intel.json` — the 5-way split. `meeting-pipeline-v2.json`
   itself was never edited again after `f3ebf58` (2026-03-19 16:43). So the
   "switched back" commit message describes an intent that the subsequent
   ~15 hours of actual development contradicts: development activity
   resumed on, and stayed on, the split architecture, not on v2.

4. **The 5-way split** — `pipeline-orchestrator.json`, `pipeline-transcribe.json`,
   `pipeline-analyze.json`, `pipeline-intel.json`, `pipeline-extract.json` —
   created by `a1e690d` (2026-03-18) and under continuous, exclusive
   development from `9d30cc8` (2026-03-19 15:43) through `cdabffe`
   (2026-03-20 07:09, "fix: calculate meeting end_time from transcript
   segments", the last meeting-pipeline commit in the repo before a 3+ month
   gap to today). This is **not** one of the 3 files flagged in the original
   finding, but the evidence above shows it is the most recently and most
   continuously developed candidate for "what actually runs."

### Canonical determination

**Best-evidence canonical candidate: the 5-way split**
(`pipeline-orchestrator.json` + `pipeline-transcribe.json` +
`pipeline-analyze.json` + `pipeline-intel.json` + `pipeline-extract.json`),
based on it being the sole target of all meeting-pipeline development in the
final ~15 hours of activity on this feature (2026-03-19 15:43 →
2026-03-20 07:09).

**Documented uncertainty — cannot be fully confirmed from repo evidence
alone:**
- Whether the n8n 2.10.3 `executeWorkflow` sub-workflow publishing bug cited
  in `9d30cc8` was actually resolved before development moved back onto the
  split files, or whether the live instance is currently running something
  else as a result of manual UI intervention never captured in a later
  export.
- There has been **no commit touching any of these workflow files since
  2026-03-20** (a 3+ month gap to today, 2026-07-01). A 3-month-stable split
  architecture is consistent with the split having stabilized as the live
  workflow, but is equally consistent with development having stalled or
  been rolled back via the n8n UI without a corresponding git export.
- This repo does not contain n8n's internal SQLite/Postgres DB, a CI import
  step, or any script that pushes these JSON files into the live container
  — no artifact here can prove which workflow's `active` flag is currently
  `true` inside the running n8n instance. **Confirming true live state
  requires checking the n8n instance itself (UI or API), which is outside
  what this repo can attest to.**

### Archive decision

Given the evidence above, the 3 originally-flagged files
(`meeting-pipeline.json`, `meeting-pipeline-v2.json`,
`meeting-audio-pipeline.json`) are each superseded by a later, better-evidenced
successor (v1→v2→5-way-split chain, plus the orphaned one-off duplicate) and
have been moved to `_archive/` (via `git mv`, not deleted) with per-file
justification in `_archive/README.md`. The 5-way split files remain in place
at `workflows/` as the current best candidate — but flagged above as not
fully confirmed against the live instance.

**Action item for whoever next touches the live n8n instance:** re-export
whichever workflow is actually active for the `meeting-audio` webhook path
and note the date/commit here, closing the uncertainty documented above.

## Other workflows in this folder

| File | Name | Committed `active` | Purpose |
|---|---|---|---|
| `chat-summarize.json` | Nightly Chat Summarize | `false` | Nightly chat digest summarization workflow. |
| `email-ingestion.json` | Email Ingestion | `false` | Email ingestion workflow. |
| `error-notifier.json` | Pipeline Error Notifier | `true` | Sends Telegram error notifications for pipeline failures (uses HTTP Request node per `3f11c18`, not the native Telegram node). Actively maintained (`435a7cb`, 2026-07-01). |

These three are unrelated to the meeting-pipeline overlap finding and were
left untouched by this remediation.
