# n8n-workflows

Git-tracked n8n workflow JSON exports, plus a test harness for the
meeting-audio pipeline. This repo does not run n8n itself — n8n runs as a
Docker container (see `docker-compose.yml`) elsewhere on the host, and the
files under `workflows/` are periodic manual exports of what's configured
inside it.

## Relationship to the live n8n instance

`docker-compose.yml` in this repo defines the n8n container (image
`docker.n8n.io/n8nio/n8n`, published on host port **5678**,
`WEBHOOK_URL=http://localhost:5678/`). That container's internal database —
not this repo — is the actual source of truth for which workflows are
currently active. The JSON files here are **exports imported into that live
instance**; they can and have drifted from live state (see
`workflows/README.md` for a concrete, evidenced case of this happening with
the meeting-audio pipeline). There is no automated import/export sync
between this repo and the running container — re-exporting after any live
change is a manual step, and is currently the main known gap.

## Layout

- `workflows/` — n8n workflow JSON exports. See
  [`workflows/README.md`](workflows/README.md) for what each workflow is and
  which one is canonical for the meeting-audio pipeline (with git-history
  evidence).
- `workflows/_archive/` — exports confirmed superseded by a later export,
  moved (not deleted) with per-file justification in
  [`workflows/_archive/README.md`](workflows/_archive/README.md).
- `scripts/pipeline-test-loop.sh` — continuous test/quality-check loop for
  the meeting-audio pipeline (see below).
- `test_pipeline.py` — integration test hitting transcribe-docker, the
  diarization service, and the n8n webhook directly.
- `PIPELINE-OUTPUT-SPEC.md` — output format spec the pipeline's generated
  meeting minutes must satisfy.

## `scripts/pipeline-test-loop.sh`

Drives the meeting-audio pipeline end-to-end for iterative quality tuning:
it POSTs a fixed test payload to `http://localhost:5678/webhook/meeting-audio`,
waits for the pipeline to finish, then runs 7 output-quality checks (no
`999999` sentinel leaking into topic names, speaker-map sanity, etc.) against
the resulting minutes note and appends results to `scripts/test-report.md`
and `scripts/test-logs/`.

```bash
./scripts/pipeline-test-loop.sh [max_iterations]   # default 5
```

It requires two environment variables to be set before running:

- `PIPELINE_BOT_TOKEN` — Telegram bot token used to drive the test payload.
- `PIPELINE_CHAT_ID` — Telegram chat ID the test payload is addressed to.

The script fails fast (`: "${VAR:?...}"`) if either is unset. A committed
`.env.example` in the repo root documents both variables (along with
`ANTHROPIC_API_KEY`, consumed by `docker-compose.yml`); copy it to `.env` and
fill in real values before running the loop or the container.
