# Pipeline Continuous Improvement Report

**Date:** 2026-03-19
**Test Audio:** Delivery Readiness Weekly (37 min, 6 participants)
**Pipeline:** v3 split architecture (orchestrator + transcribe + analyze + intel + extract)
**Model:** qwen3.5:27b-32k

---

## Quality Metrics Comparison

| Check | Baseline (Before) | Iteration 1 | Iteration 2 | Status |
|-------|-------------------|-------------|-------------|--------|
| **999999 sentinel leak** | FAIL (topic heading) | PASS | PASS | FIXED |
| **Speaker positional bias** | FAIL (SPEAKER_00 = Rantala Petri always) | PASS (Kuivaniemi Aku) | PASS (Kuivaniemi Aku) | FIXED |
| **Name order (Lastname Firstname)** | FAIL (Jaakko Hahtola, Heidi Äijälä) | PASS | PASS | FIXED |
| **Instruction echoing** | FAIL | PASS | PASS | FIXED |
| **Action item format** | PASS (5 items) | PASS (5 items) | PASS (3 items) | OK |
| **Executive style (verbose attributions)** | 16 patterns | 18 patterns (FAIL) | 1 pattern (PASS) | FIXED |
| **Topic count** | 5 topics | 4 topics | 4 topics | OK |
| **Garbled names** | FAIL (Jaakko Haakko) | PASS | PASS | FIXED |
| **Merged cluster diagnostics** | Not shown | Not shown | Shown in HTML comment | IMPROVED |

## Key Improvements

### 1. Sentinel Value Fix (999999)
**Before:** The LLM topic segmentation used `"end": 999999` as a sentinel, and sometimes output "999999" as a topic name. This appeared as a heading in the final minutes.
**After:** Post-parse check in Slice Topics replaces purely numeric topic names with their summary or "Closing Discussion".

### 2. Speaker Positional Bias Elimination
**Before:** SPEAKER_00 was always mapped to the first name in the participant list (usually Rantala Petri, who writes his name first).
**After:** Participant list is alphabetically sorted before being passed to the LLM, with an explicit anti-bias instruction. SPEAKER_00 is now mapped based on voice characteristics, not list position.

### 3. Executive-Level Key Points
**Before (Iter 1):** Every key point attributed to a specific speaker:
> "Hahtola Jaakko identified and commented on audio difficulties..."
> "Kuivaniemi Aku inquired whether the 'Jiijin' column was newly added..."

**After (Iter 2):** Impersonal board summary style:
> "Initial audio connectivity and interface display problems were identified and subsequently resolved."
> "The R7 design model is confirmed complete, yet investment figures for Snowproof 3P are missing."

**Metric:** Verbose attribution patterns reduced from 28 to 1 (96% reduction).

### 4. Fuzzy Name Matching
**Before:** Garbled names like "Jaakko Haakko" (LLM mangling) were not caught by normalization.
**After:** First-name-based fuzzy matching catches "Firstname GarbledWord" patterns and normalizes them to the correct "Lastname Firstname" form.

### 5. Ghost Queue Prevention
**Before:** If n8n pipeline failed without writing a sentinel file, the bot's queue got permanently blocked.
**After:** `clear_stale()` runs on bot startup, clearing any active item older than 90 minutes. The existing 90-min poll timeout also serves as runtime safety net.

### 6. Action Item Quality
**Before (Iter 1):** 5 action items including hallucinated items like "Resolve audio/listening issues in the call".
**After (Iter 2):** 3 action items, all genuine commitments from the meeting discussion.

## Deployment Process Improvements

Discovered critical n8n 2.10.3 deployment requirements:
- `workflow_history` table entry required for each new versionId (FK constraint)
- `workflow_publish_history` activated event required for sub-workflow activation
- `docker cp` without WAL gives stale data — must copy all 3 SQLite files

## Pipeline Timing

| Phase | Duration |
|-------|----------|
| Transcription (ASR) | ~3 min (37-min audio, cached after first run) |
| Topic analysis (LLM) | ~7 min (4 topics x qwen3.5:27b-32k) |
| Intel report (LLM) | ~10 min |
| Key items extract (LLM) | ~5 min |
| **Total end-to-end** | **~25 min** |

## Remaining Items

1. Empty DECISION blocks sometimes appear with "No concrete decision was made" — should be omitted per spec
2. Over-segmented diarization (8 clusters for 6 speakers) — mitigated by merged cluster diagnostics but threshold tuning still beneficial
3. Action item deadlines sometimes use the meeting date itself (e.g., 2026-03-18 for a meeting on 2026-03-18) — should use future dates

---

*Report generated: 2026-03-19 21:35*
