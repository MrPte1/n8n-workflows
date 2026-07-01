# Archived workflow exports

Files here are archived (`git mv`, not deleted) because git-history evidence
shows each was superseded by a later export. Full lineage and citations are
in `../README.md` — this file is the short per-item justification.

| File | Archived because | Evidence |
|---|---|---|
| `meeting-pipeline.json` | Original v1 monolithic meeting pipeline. Superseded by `meeting-pipeline-v2.json` (M59 divide-and-conquer rewrite of the same webhook path), then by the 5-way split. No commit touched it after `2a09564` (2026-03-17 22:05); it was never edited again once v2 was created (`9f8189d`, 12:54 the same day) and activated (`fa07f51`, 2026-03-18). | `9f8189d`, `fa07f51` |
| `meeting-pipeline-v2.json` | v2 rewrite of the same webhook path. Explicitly superseded per commit body: *"Old meeting-pipeline-v2 deactivated; orchestrator uses same webhook path."* A later commit message (`9d30cc8`) claims a revert back to v2, but every commit from that point through the last pipeline commit in the repo (`cdabffe`, 2026-03-20 07:09) touched only the 5-way split files, not this one — development did not actually return here. | `a1e690d` (deactivation statement), file-touch pattern of `9d30cc8`→`cdabffe` |
| `meeting-audio-pipeline.json` | Single-commit orphan. Added once (`dc998e6`, 2026-03-17 11:12, same workflow name/webhook path as `meeting-pipeline.json` at that point in time) and never touched again by any later commit — reads as a point-in-time duplicate/backup taken shortly before the v2 rewrite began, not a distinct maintained workflow. | `dc998e6` (sole commit) |

The 5-way split (`pipeline-orchestrator.json`, `pipeline-transcribe.json`,
`pipeline-analyze.json`, `pipeline-intel.json`, `pipeline-extract.json`) —
the apparent current successor — remains in `workflows/`, not here. See
`../README.md` for the documented residual uncertainty about whether it is
confirmed live.
