<div style="font-size: 0.5em;"> These notes were created using a temporary audio recording of a meeting held on 2026-03-18. The audio was transcribed using a cloud-based service to support accurate note-taking. The recording was deleted immediately after transcription. The final document is stored locally and not shared externally. </div>

Minutes created: 2026-03-19 21:34 © Petri Rantala
Tags: #📓 ⚖ ✅ 🤝
Template Version: 2.0-v2
Pipeline: divide-and-conquer (M59)

---

<!-- Speaker map: SPEAKER_00 = Kuivaniemi Aku, SPEAKER_01 = Hahtola Jaakko, SPEAKER_02 = Äijälä Heidi, SPEAKER_03 = Syvänen Sirpa, SPEAKER_04 = Kuivaniemi Aku, SPEAKER_05 = Rita Päivi, SPEAKER_06 = Rantala Petri, SPEAKER_07 = Äijälä Heidi | Merged clusters: Kuivaniemi Aku ← SPEAKER_00+SPEAKER_04; Äijälä Heidi ← SPEAKER_02+SPEAKER_07 -->

---
- **Date:** [[2026-03-18]]
- **Start Time:** 14:00
- **End Time:** unknown
- **Attendees:**
- [x] [[Rantala Petri]]
- [x] [[Rita Päivi]]
- [x] [[Hahtola Jaakko]]
- [x] [[Kuivaniemi Aku]]
- [x] [[Syvänen Sirpa]]
- [x] [[Äijälä Heidi]]

#### Link(s) to project(s) or note(s) if any
-

## Meeting Summary
- **Technical Troubleshooting and SKU Status Checks:** Audio and interface issues were resolved as the participants confirmed that all product SKUs have been successfully created and the R7 model is complete.
- **Investment Approval and Supply Chain Updates:** The R7 design model is finalized, but investment numbers remain pending due to unresolved supplier negotiations and cost queries.
- **Production Targets and Infrastructure Challenges:** Production targets for internal operations were largely met despite one batch requiring rework due to incorrect filling, while factory-wide power outages scheduled for the morning shift have created operational uncertainty.
- **Production Permission and Estimation Data Discrepancies:** The meeting clarified the distinct roles of the Production Permission Estimation (PPE) and the formal Production Permission, identified a critical issue with false system alerts regarding labeling values, and established the need to align data visibility between development and production planning.

## Agenda
- [[#Technical Troubleshooting and SKU Status Checks]]
- [[#Investment Approval and Supply Chain Updates]]
- [[#Production Targets and Infrastructure Challenges]]
- [[#Production Permission and Estimation Data Discrepancies]]

## Notes

### Technical Troubleshooting and SKU Status Checks
Audio and interface issues were resolved as the participants confirmed that all product SKUs have been successfully created and the R7 model is complete.

**Key Points:**
- Initial audio connectivity and interface display problems were identified and subsequently resolved.
- Participants confirmed that a new column previously hidden is now visible in the system.
- The status of the R7 model was verified as completed, and all associated product SKUs were confirmed as created.
- System notifications regarding the new SKUs were observed and acknowledged by the group.

**Outcome:** Information shared

#### DECISION
**What:** No concrete decision was made; the meeting focused on status verification and technical troubleshooting.

### Investment Approval and Supply Chain Updates
The R7 design model is finalized, but investment numbers remain pending due to unresolved supplier negotiations and cost queries.

**Key Points:**
- The R7 design model is confirmed complete, yet investment figures for Snowproof 3P are missing because the approval process is stalled.
- Supplier image deliveries are blocked until the investment numbers are officially generated and verified.
- Negotiations with Laten are delayed as a representative questioned the manufacturing choice and cost competitiveness regarding Himilä.
- Design work continues to the fullest extent possible despite the uncertainty surrounding the investment numbers.

**Outcome:** Information shared

### Production Targets and Infrastructure Challenges
Production targets for internal operations were largely met despite one batch requiring rework due to incorrect filling, while factory-wide power outages scheduled for the morning shift have created operational uncertainty.

**Key Points:**
*   The first Entras shipment is proceeding on schedule to the data center after minor corrections to the Oraadean delivery.
*   One production batch required rework due to incorrect filling, resulting in scrap material that is being addressed to repair the components.
*   The internal operation timeline has been extended to a 20-week duration to accommodate current progress.
*   Mold deliveries faced delays earlier in the week but have arrived and are currently undergoing inspection.
*   Critical uncertainty exists regarding factory-wide power availability for the morning shift due to a planned transformer upgrade, with rumors suggesting the power cut may be indefinite.

**Outcome:** Information shared

### Production Permission and Estimation Data Discrepancies
The meeting clarified the distinct roles of the Production Permission Estimation (PPE) and the formal Production Permission, identified a critical issue with false system alerts regarding labeling values, and established the need to align data visibility between development and production planning.

**Key Points:**
*   Participants distinguished that the Production Permission Estimation (PPE) serves as a rolling forecast for production planning, whereas the formal Production Permission confirms technical validation and readiness for actual manufacturing.
*   A significant volume of false alerts was identified in the SRAL system, where labeling value warnings are triggered by output batches that do not require production planning, thereby obscuring genuine non-compliance risks.
*   The group noted a recent instance where a product entered production at the Nokia facility without the required labeling values, highlighting a failure in the current alert filtering mechanism.
*   It was agreed that the PPE must be updated immediately when delays occur to maintain accurate production schedules, rather than waiting for the formal permission date to pass.
*   Discrepancies were observed where official launch dates were met, yet products remained invisible in systems due to missing labeling values or pending technical test results.

#### DECISION
**What:** The team agreed that the PPE must be treated as the primary source for production planning visibility and requires immediate updates when project delays occur, while the formal Production Permission remains the gate for technical validation.

- [ ] ***Action Point:*** 🟧 **What:** Investigate and resolve the filtering logic for SRAL alerts to exclude output batches and prevent false labeling value warnings. **Who:** [[Kuivaniemi Aku]] **When:** 2026-04-01
- [ ] ***Action Point:*** 🟨 **What:** Review and clarify the PPE update process with Riku upon his return next week to ensure alignment on data handling. **Who:** [[Kuivaniemi Aku]] **When:** 2026-03-25
- [ ] ***Action Point:*** 🟧 **What:** Evaluate the current status of PowerTru 2 products returned to production to determine the necessary hold procedures. **Who:** [[Äijälä Heidi]] **When:** 2026-04-01

## Screenshots


---

*Intelligence Report: [[101 - Meeting Intelligence Reports/2026-03-18 TEST Delivery Readiness Weekly - Intelligence Report.md]]*