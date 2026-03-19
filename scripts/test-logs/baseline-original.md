<div style="font-size: 0.5em;"> These notes were created using a temporary audio recording of a meeting held on 2026-03-18. The audio was transcribed using a cloud-based service to support accurate note-taking. The recording was deleted immediately after transcription. The final document is stored locally and not shared externally. </div>

Minutes created: 2026-03-19 18:10 © Petri Rantala
Tags: #📓 ⚖ ✅ 🤝
Template Version: 2.0-v2
Pipeline: divide-and-conquer (M59)

---

<!-- Speaker map: SPEAKER_00 = Rantala Petri, SPEAKER_01 = Kuivaniemi Aku, SPEAKER_02 = Äijälä Heidi, SPEAKER_03 = Rita Päivi, SPEAKER_04 = Hahtola Jaakko, SPEAKER_05 = Syvänen Sirpa, SPEAKER_06 = Rantala Petri, SPEAKER_07 = Äijälä Heidi -->

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
- **System Status and Inventory Column Verification:** The meeting confirmed that the JIIHIN column has been visible continuously and verified the successful creation of all new inventory items in the system.
- **R7 Model Approval and Manufacturer Delays:** The R7 design model is complete, but the finalization of investment numbers and vendor selection is stalled due to pending approvals from Trellis regarding the non-confirmation of the lowest bid.
- **Production Planning and Factory Power Issues:** The team reported that while internal production targets were met and the Oradea shipment corrected, significant delays loom due to a factory-wide power outage for a new transformer installation that may halt morning operations.
- **Production Permission versus Estimated Launch Dates:** The group identified that frequent false alarms regarding missing labeling values for output batches have obscured real production permission risks, necessitating a review of alert logic and PPE update processes.
- **Data Visibility and Product Launch Readiness:** The team identified a critical gap where no EU values were visible in systems despite the official 3PL launch date, prompting a need for improved communication regarding data readiness prior to market release.

## Agenda
- [[#System Status and Inventory Column Verification]]
- [[#R7 Model Approval and Manufacturer Delays]]
- [[#Production Planning and Factory Power Issues]]
- [[#Production Permission versus Estimated Launch Dates]]
- [[#Data Visibility and Product Launch Readiness]]

## Notes

### System Status and Inventory Column Verification
The meeting confirmed that the JIIHIN column has been visible continuously and verified the successful creation of all new inventory items in the system.

**Key Points:**
*   Rantala Petri raised a concern regarding whether a new column was previously hidden but is now visible.
*   Syvänen Sirpa confirmed that the specific column in question has been present in the system the entire time.
*   Rantala Petri identified that the interface appeared locked due to a browser-related issue rather than a system error.
*   Kuivaniemi Aku announced that notifications regarding new inventory items had arrived and that all requested items were successfully created.
*   Rantala Petri suggested proceeding to the next agenda item after the inventory verification was completed.

**Outcome:** Information shared

#### DECISION
**What:** The participants agreed that the inventory update process was successful and the column visibility was confirmed, allowing the meeting to proceed to the next topic.

- [ ] ***Action Point:*** 🟩 **What:** Continue the meeting discussion on the next agenda item **Who:** [[Rantala Petri]] **When:** 2026-03-18

### R7 Model Approval and Manufacturer Delays
The R7 design model is complete, but the finalization of investment numbers and vendor selection is stalled due to pending approvals from Trellis regarding the non-confirmation of the lowest bid.

**Key Points:**
*   Hahtola Jaakko confirmed that the R7 design model ("äitimalli") is finished but highlighted that investment numbers for 3P and Snowproof 3P vendors are still missing.
*   Kuivaniemi Aku clarified that while the 3P vendor was approved, the actual investment data has not yet been received or processed.
*   Hahtola Jaakko explained that Laten is withholding the delivery of images until the investment number is officially created, causing the item to be flagged in red.
*   Hahtola Jaakko reported that a representative named Paolo Kavikainen from Trellis has questioned the selected manufacturer, noting that the cheapest offer is no longer being considered the standard OK option.
*   The participants discussed the uncertainty regarding whether the current Trellis representative is an internal employee or an external partner involved in the decision-making process.
*   Rita Päivi noted the ambiguity in the conversation regarding why the Himilä option is being considered despite potential cost implications.
*   Hahtola Jaakko emphasized that design work is proceeding to the maximum extent possible despite the ongoing procurement delays.

**Outcome:** Information shared

### Production Planning and Factory Power Issues
The team reported that while internal production targets were met and the Oradea shipment corrected, significant delays loom due to a factory-wide power outage for a new transformer installation that may halt morning operations.

**Key Points:**
*   Rita Päivi confirmed that the Oradea shipment was successfully corrected with minor actions and the first Entras delivery is on schedule to the data center.
*   Syvänen Sirpa noted that internal targets were fully met, though one component required scrapping and reworking due to incorrect filling volume.
*   Syvänen Sirpa indicated that the timeline for the primary production line has been adjusted, with a current plan extending for at least 20 weeks.
*   Heidi Äijälä reported that while four targets were met, persistent data entry errors in Planedit require constant manual correction.
*   Heidi Äijälä revealed that molds received after issues this week are now under inspection, but factory-wide power is cut off tomorrow morning for a new transformer installation.
*   Heidi Äijälä expressed uncertainty regarding whether power will be restored in time for operations, as rumors suggest the upgrade might be postponed or delayed.
*   Rantala Petri mentioned that a recent meeting yielded an output, though it did not fully match the original plan, and inquired about the Dayton situation without receiving a clear update.

**Outcome:** Information shared

- [ ] ***Action Point:*** 🟧 **What:** Monitor factory power restoration status to confirm availability for morning shifts and production lines. **Who:** [[Äijälä Heidi]] **When:** 2026-03-19

### Production Permission versus Estimated Launch Dates
The group identified that frequent false alarms regarding missing labeling values for output batches have obscured real production permission risks, necessitating a review of alert logic and PPE update processes.

**Key Points:**
*   Rantala Petri reported a specific case where a product launched into production at Nokia without required labeling values, highlighting a gap in the current alert system's effectiveness.
*   Rantala Petri explained that the SRAL alert system currently generates excessive false positives by flagging output batches, which risks causing teams to overlook genuine critical errors amidst the noise.
*   Rita Päivi clarified the distinct roles of the data points, defining PPE (Estimated Production Start) as the planning forecast for production schedules and Production Permission (via MDS) as the final technical approval required before actual manufacturing begins.
*   The participants agreed that if a PPE date falls into the past without a corresponding Production Permission being granted, it indicates a process failure where the estimate was not updated to reflect delays.
*   Rita Päivi emphasized that production planning relies entirely on the PPE for future scheduling, whereas the Production Permission serves as the final gate confirming the product meets all technical and quality requirements.
*   Rantala Petri noted that while Riku (a colleague not present) has moved three specific products forward, the team must verify if product management is kept informed of these shifts or if updates are handled ad-hoc.
*   Kuivaniemi Aku and Rita Päivi discussed the feasibility of filtering out false alarms by excluding "amputi" (prototype/output) quantities from the alert triggers, noting that volume thresholds are used in other reports.

**Outcome:** Information shared

- [ ] ***Action Point:*** 🟨 **What:** Review the SRAL alert system logic to filter out false positives caused by output batches and improve detection of missing labeling values. **Who:** [[Rantala Petri]] **When:** 2026-03-25
- [ ] ***Action Point:*** 🟧 **What:** Investigate the root cause of the Nokia production launch without labeling values and verify the status of the three specific products moved forward by Riku. **Who:** [[Rantala Petri]] **When:** 2026-03-25
- [ ] ***Action Point:*** 🟨 **What:** Discuss the clarification of PPE versus Production Permission definitions and update workflows once Riku returns from leave. **Who:** [[Rantala Petri]] **When:** 2026-03-25

### Data Visibility and Product Launch Readiness
The team identified a critical gap where no EU values were visible in systems despite the official 3PL launch date, prompting a need for improved communication regarding data readiness prior to market release.

**Key Points:**
*   Äijälä Heidi highlighted that on the official launch date for the 3PL product line, zero items had visible EU values in the system, creating a disconnect between the announced launch and actual data availability.
*   Rantala Petri clarified that the "Traceable the Market" date acts as the final deadline, but noted that label values for product families often arrive at different times due to varying performance classes.
*   Rantala Petri reported specific quality issues with the PowerTru 2 product, including noise levels failing to meet limits, technical fitment problems requiring new testing, and rolling resistance issues necessitating re-testing of specific sizes.
*   Äijälä Heidi raised concerns about the lifecycle management of PowerTru 2 units that were returned to hold and remanufactured, questioning whether their existing values remain valid or if they risk appearing in customer warehouses unexpectedly.
*   Rantala Petri expressed the understanding that the PowerTru 2 issues are likely technical in nature and may not impact the EU values or type approvals, though this requires confirmation.
*   The participants discussed the need to better communicate technical readiness status to prevent situations where data appears ready but is actually missing critical components like EU values.

**Outcome:** Action items created

- [ ] ***Action Point:*** 🟨 **What:** Investigate the specific impact of PowerTru 2 D12 quality issues on EU values and type approvals to confirm if data remains valid. **Who:** [[Kuivaniemi Aku]] **When:** 2026-03-25
- [ ] ***Action Point:*** 🟧 **What:** Review the SRA/PPE process and coordinate a follow-up meeting to address the workflow regarding returned and remanufactured products. **Who:** [[Rantala Petri]] **When:** 2026-04-01

## Screenshots


---

*Intelligence Report: [[101 - Meeting Intelligence Reports/2026-03-18 Delivery Readiness Weekly - Intelligence Report.md]]*