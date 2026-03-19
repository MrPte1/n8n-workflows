# Pipeline Output Specification — Meeting Pipeline v2

> Authoritative format specification for all meeting pipeline output artifacts.
> All LLM prompts, assembly code, and downstream consumers MUST conform to this spec.
> Any change to this spec requires updating all affected prompts and consumers.

---

## Document Status

| Field | Value |
|-------|-------|
| Version | 1.0 |
| Created | 2026-03-19 |
| Pipeline | divide-and-conquer v2 (M59) |
| Model | qwen3.5:27b-32k |
| Consumers | telegram-agent (bot.py, task_complexity.py), propagation.py, extraction.py, weekly.py |

---

## 1. Universal Rules (ALL Artifacts)

These rules apply to every output artifact without exception.

### 1.1 Name Format

| Rule | Example | Rationale |
|------|---------|-----------|
| Always **Lastname Firstname** order | `Rantala Petri`, not `Petri Rantala` | Finnish business convention; consistent wikilinks |
| Wikilink all known people | `[[Rantala Petri]]` | Obsidian graph connectivity |
| First-name-only stays plain text | `Jukka` (no wikilink) | Prevents false graph links |
| Spelling from participant list is canonical | If webhook says `Virtala Jussi`, never write `Wirtala Jussi` | Single source of truth |

### 1.2 Speaker Attribution

| Rule | Rationale |
|------|-----------|
| ONLY participants listed in the webhook may be attributed as speakers | Prevents hallucinating speakers |
| Other names mentioned in conversation are people being DISCUSSED, not speakers | Write "The participants discussed [[Name]]" not "[[Name]] said..." |
| Biometrically verified labels (real names from diar-service) are authoritative | Never re-identify them |
| Unresolved SPEAKER_XX labels: map only with STRONG evidence (self-introduction, direct address) | Prevents misattribution |
| When diarization detects fewer speakers than participants: prefer keeping SPEAKER_XX over guessing | Under-map, never mis-map |

### 1.3 Language & Style

| Rule | Value |
|------|-------|
| Language | Business American English |
| Tone | Professional, factual, concise |
| No raw transcript artifacts | No `[00:01:30.000]` timestamps, no `[Speaker Name]` labels in prose |
| Attribution woven naturally | "Rantala Petri noted that..." not "[Rantala Petri]: ..." |
| No instruction echoing | LLM template text must never appear in output |
| No invented facts | Only what is explicitly stated in the transcript |

### 1.4 Date & Time Format

| Field | Format | Example |
|-------|--------|---------|
| Dates | `YYYY-MM-DD` | `2026-03-18` |
| Date wikilinks | `[[YYYY-MM-DD]]` | `[[2026-03-18]]` |
| Times | `HH:MM` (24h) | `13:02` |
| Timestamps in headers | `YYYY-MM-DD HH:MM` | `2026-03-18 20:25` |

---

## 2. Artifact 1: Meeting Minutes

**Path:** `100 - Meeting minutes/YYYY-MM-DD {Meeting Name}.md`
**Template Version:** `2.0-v2`

### 2.1 Document Structure (exact order)

```markdown
<div style="font-size: 0.5em;"> Privacy disclaimer </div>

Minutes created: YYYY-MM-DD HH:MM © Petri Rantala
Tags: #📓 ⚖ ✅ 🤝
Template Version: 2.0-v2
Pipeline: divide-and-conquer (M59)

---

<!-- Speaker map: SPEAKER_00 = Lastname Firstname, SPEAKER_01 = ... -->

---
- **Date:** [[YYYY-MM-DD]]
- **Start Time:** HH:MM
- **End Time:** HH:MM or unknown
- **Attendees:**
- [x] [[Lastname Firstname]]
- [x] [[Lastname Firstname]]

#### Link(s) to project(s) or note(s) if any
-

## Meeting Summary
- **{Topic Name}:** One sentence describing the outcome.
- **{Topic Name}:** One sentence describing the outcome.

## Agenda
- [[#{Topic Name}]]
- [[#{Topic Name}]]

## Notes

### {Topic Name}
{One sentence summarizing the outcome — not echoed instructions}

**Key Points:**
- {Speaker} noted/proposed/confirmed that {specific detail}.
- {3-7 concrete bullets with attribution, specifics, numbers, dates}

**Outcome:** {exactly one of: Decision made | Action items created | Information shared | No outcome}

#### DECISION
**What:** {concise decision description}

- [ ] ***Action Point:*** {emoji} **What:** {task} **Who:** [[Lastname Firstname]] **When:** YYYY-MM-DD

### {Next Topic Name}
...

## Screenshots


---

*Intelligence Report: [[101 - Meeting Intelligence Reports/YYYY-MM-DD {Name} - Intelligence Report.md]]*
```

### 2.2 Topic Requirements

| Rule | Value |
|------|-------|
| Topic names | Descriptive 3-8 words (e.g., "Ketos Report Automation"), NEVER "Segment N" or "Topic N" |
| Topic count | 2-8 well-consolidated topics per meeting |
| Consolidation | Discussions about the same subject MUST be merged into one topic, even if briefly interrupted |
| Each topic = | One distinct agenda item or decision area |
| Coverage | Every minute of the meeting must belong to exactly one topic |

### 2.3 Key Points Requirements

| Rule | Value |
|------|-------|
| Count | 3-7 per topic |
| Attribution | Every key point attributed to the speaker who made it |
| Specificity | Include numbers, systems, dates, owners — never vague |
| No action items | Action items go in ACTION ITEMS section, not key points |
| No complexity emojis | Emojis only on action item lines |

### 2.4 Decision Block

| Rule | Value |
|------|-------|
| Include only when | A concrete decision was explicitly made |
| If no decision | OMIT the entire `#### DECISION` block — never write "No decision" |
| Format | `#### DECISION` followed by `**What:** {description}` |

### 2.5 Action Item Format (CRITICAL — downstream consumers depend on this)

**Exact format — regex-validated by multiple consumers:**

```
- [ ] ***Action Point:*** {emoji} **What:** {task} **Who:** [[Lastname Firstname]] **When:** YYYY-MM-DD
```

**Consumer regex contracts:**

| Consumer | Regex | What it expects |
|----------|-------|-----------------|
| `bot.py` _AP_OPEN_RE | `^-\s+\[\s*\]\s+\*{3}Action Point:?\*{3}` | Line starts with `- [ ] ***Action Point:***` |
| `bot.py` _AP_WHAT_RE | `\*\*What:\*\*\s*(.+?)\s*\*\*Who:` | `**What:**` followed by text, then `**Who:**` |
| `bot.py` _AP_WHO_RE | `\*\*Who:\*\*\s*(.+?)\s*\*\*When:` | `**Who:**` with wikilinked name, then `**When:**` |
| `bot.py` _AP_WHEN_RE | `\*\*When:\*\*\s*(.+?)$` | `**When:**` followed by YYYY-MM-DD |
| `task_complexity.py` COMPLEXITY_RE | `\*{3}Action Point:?\*{3}\s*([🟩🟨🟧🟥])` | Emoji immediately after `***Action Point:***` |
| `task_complexity.py` _INSERT_RE | `(\*{3}Action Point:?\*{3})\s*(\*\*What:)` | Insert point between prefix and What |

**Complexity emojis (MUST use, required by task_complexity.py):**

| Emoji | Effort | Default deadline (from meeting date) |
|-------|--------|--------------------------------------|
| 🟩 | < 1 hour | + 3 days |
| 🟨 | 1-4 hours | + 7 days |
| 🟧 | 1-3 days | + 14 days |
| 🟥 | > 3 days | + 30 days |

**When field rules:**
- If a specific deadline was mentioned in the meeting, use it
- If no deadline mentioned, calculate from complexity + meeting date
- Never use "TBD" unless action is explicitly deferred
- Never use dates before the meeting date

**Action item inclusion rules:**
- Only REAL commitments or follow-ups explicitly agreed in the meeting
- Never create action items for things already done or trivial logistics
- If no action items exist for a topic, OMIT the entire `#### ACTION ITEMS` block

### 2.6 Attendee List

| Rule | Value |
|------|-------|
| Source | Participant list from webhook (canonical) |
| Supplement | Speaker map names not already in participant list |
| Format | `- [x] [[Lastname Firstname]]` (always checked) |
| No duplicates | Each person appears exactly once |

---

## 3. Artifact 2: Intelligence Report

**Path:** `101 - Meeting Intelligence Reports/YYYY-MM-DD {Name} - Intelligence Report.md`
**Template Version:** `M15.1`
**Prompt:** ELITE-INTEL-OMEGA

### 3.1 Document Structure

```markdown
Intel report generated: YYYY-MM-DD HH:MM
Classification: PERSONAL — RESTRICTED
Template Version: M15.1

---

# MEETING INTELLIGENCE REPORT
**Meeting**: {Name} — YYYY-MM-DD
**Analyst**: ELITE-INTEL-OMEGA

## 1. Executive Summary
## 2. Participant Intelligence Profiles
## 3. Linguistic & Behavioral Forensics
## 4. Secrets, Fears, Motivations & Hidden Agendas
## 5. Relationship & Power Dynamics
## 6. Actionable Recommendations
## 7. Longitudinal Delta
## 8. Obsidian PKMS Integration
```

### 3.2 Section Requirements

| Section | Content | Rules |
|---------|---------|-------|
| 1. Executive Summary | 3-5 highest-signal bullets | Strategic, not operational |
| 2. Participant Profiles | Role, Core Drivers (with evidence), Key Fears (% confidence), Leverage Points | One profile per person present; absent people mentioned get separate "External" block |
| 3. Linguistic Forensics | Deception/Withholding indicators, Emotional tone, Communication patterns | Evidence-based, confidence % |
| 4. Hidden Agendas | Inference from behavior/language | Clearly marked as inference |
| 5. Power Dynamics | Alliances, tensions, strategic leverage | Relationship mapping |
| 6. Recommendations | Immediate tactical + Strategic long-term + Monitoring signals | Actionable, specific |
| 7. Longitudinal Delta | Changes vs. previous meetings | "New baseline" if first meeting |
| 8. PKMS Integration | New wikilinks, atomic notes, MOC updates | Vault-specific suggestions |

### 3.3 Quality Rules

| Rule | Value |
|------|-------|
| All person mentions | `[[Lastname Firstname]]` wikilinks |
| Confidence markers | Every non-obvious inference has % confidence |
| Evidence citations | Each claim references specific meeting behavior/quote |
| No speculation without marker | Clearly label inferences vs. facts |

---

## 4. Artifact 3: Key Items Extract

**Path:** `102 - Meeting Extracts/YYYY-MM-DD {Name} - Key Items.md`
**Template Version:** `M20.1`

### 4.1 Document Structure

```markdown
---
meeting: "[[100 - Meeting minutes/YYYY-MM-DD {Name}.md]]"
date: YYYY-MM-DD
participants: [{comma-separated Lastname Firstname list}]
tags: [meeting-extract]
---

Extract created: YYYY-MM-DD HH:MM
Template Version: M20.1

---

## People
- **[[Lastname Firstname]]** — {role or contribution in this meeting}

## Projects & Initiatives
- **[[Project Name]]** — {status or decision from meeting}

## Tools & Technologies
- **[[Tool Name]]** — {how it was discussed/proposed}

## Concepts & Terms
- **[[Concept]]** — {definition or context from meeting}

## Resources & References
- **[[Reference]]** — {what it is and why it was mentioned}

---

*[[path-to-minutes]] · [[path-to-intel-report]]*
```

### 4.2 Section Rules

| Section | Content | Rules |
|---------|---------|-------|
| People | All people mentioned (attendees + discussed) | Wikilinked; one-line role/contribution description |
| Projects & Initiatives | Named projects, initiatives, workstreams | Wikilinked; current status from meeting |
| Tools & Technologies | Software, platforms, methods mentioned | Wikilinked; how discussed |
| Concepts & Terms | Domain terms, acronyms, abstract concepts | Wikilinked; definition/context |
| Resources & References | Dates, departments, external entities | Wikilinked where applicable |

### 4.3 Quality Rules

| Rule | Value |
|------|-------|
| Every item wikilinked | `**[[Name]]** — description` format |
| No empty sections | Omit section if nothing to list |
| Descriptions | One line, factual, from meeting content only |
| YAML frontmatter | Required, must match meeting note path exactly |

---

## 5. Post-Processing Rules (Assemble Minutes)

These deterministic code rules run AFTER LLM output, BEFORE writing to vault.

### 5.1 Name Normalization
- Build `Firstname Lastname → Lastname Firstname` mapping from participant list
- Replace all `[[Firstname Lastname]]` with `[[Lastname Firstname]]` in body
- Replace plain text mentions similarly (outside wikilinks)

### 5.2 Instruction Echo Removal
- Strip any echoed LLM template text (format instructions, rules, examples)
- Remove empty DECISION blocks ("No decision", "N/A", "—")
- Remove empty ACTION ITEMS blocks ("No action items", "N/A")
- Remove duplicate topic sections (same ### heading appearing twice)

### 5.3 Format Normalization
- Fix doubled labels: `**WhenWhen:**` → `**When:**`
- Fix repeated consecutive words: `"from from"` → `"from"`
- Ensure `***Action Point:***` prefix on all action items
- Strip complexity emojis from non-action-item lines
- Collapse 3+ consecutive blank lines to 2

---

## 6. Validation Checklist

Before any pipeline prompt or assembly code change, verify:

- [ ] Action item format matches all 6 consumer regexes (Section 2.5)
- [ ] Topic names are descriptive, not generic (Section 2.2)
- [ ] Speaker attribution follows the cautious mapping rules (Section 1.2)
- [ ] Name ordering is Lastname Firstname throughout (Section 1.1)
- [ ] All sections present in correct order (Sections 2.1, 3.1, 4.1)
- [ ] No instruction text echoed in output (Section 5.2)
- [ ] Complexity emojis used on action items (Section 2.5)
- [ ] YAML frontmatter correct in Key Items Extract (Section 4.1)
- [ ] Cross-references between artifacts use correct paths

---

## 7. Change Control

| Rule | Detail |
|------|--------|
| Spec is authoritative | Prompts are derived from this spec, not the other way around |
| Version tracked | Increment version number on any change |
| Breaking changes | Require updating all affected consumers (bot.py regexes, task_complexity.py, propagation.py, extraction.py) |
| Prompt changes | Must cite which spec section they implement |
| Test after change | Run a meeting audio through the pipeline and verify against this checklist |

---

*Last updated: 2026-03-19 — Version 1.0*
