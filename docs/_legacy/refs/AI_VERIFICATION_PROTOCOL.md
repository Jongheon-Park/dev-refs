# AI_VERIFICATION_PROTOCOL.md

## PURPOSE
This document defines the strict verification protocol for solution and project analysis. All analysis must follow this protocol to ensure accuracy and prevent false assumptions.

---

## VERIFICATION LEVELS

### 🟢 VERIFIED (100% Confirmed)
**Requirements:**
- Primary evidence (source code line)
- User confirmation ✓
- Verification date recorded
- Verifier name recorded

**Example:**
```markdown
### OpenCV Version
🟢 VERIFIED | Verifier: User | Date: 2026-03-05

**Evidence (Primary):**
File: Vision.vcxproj:67
```cpp
<AdditionalDependencies>opencv_core455.lib</AdditionalDependencies>
```

**Conclusion:** OpenCV 4.5.5 confirmed
```

---

### 🟡 PENDING (Evidence Found, Unverified)
**Status:**
- Evidence exists
- User verification required
- **NOT included in final documentation**
- Listed in "Verification Queue"

**Example:**
```markdown
### Canny Edge Detection
🟡 PENDING

**Evidence (Primary):**
File: Vision.cpp:234
```cpp
cv::Canny(src, dst, threshold1, threshold2);
```

**Unconfirmed:** threshold values
**Action Required:** User must verify Vision.cpp:234
**Priority:** High
**Deadline:** TBD
```

---

### 🔴 UNKNOWN (No Evidence)
**Status:**
- No direct evidence
- Speculation forbidden
- Additional investigation required
- Listed in "Investigation Required"

**Example:**
```markdown
### PLC Communication Protocol
🔴 UNKNOWN

**Reason:** No evidence found in code
**Investigation Method:** 
- Option 1: Developer interview
- Option 2: Runtime analysis
- Option 3: External documentation
**Priority:** High
```

---

## EVIDENCE CLASSIFICATION

### Primary Evidence (Grade 1) ⭐⭐⭐
- Actual source code lines
- Compilation logs
- Build configuration files
- Executable output

### Secondary Evidence (Grade 2) ⭐⭐
- Official code comments
- Project settings
- Library version numbers
- Configuration files

### Tertiary Evidence (Grade 3) ⭐
- Variable/function names
- Folder structure
- File naming patterns

### Non-Evidence (INVALID) ❌
- "Generally..."
- "Usually..."
- "Probably..."
- "It seems..."
- Domain knowledge without code proof

---

## SOLUTION ANALYSIS WORKFLOW

### Phase 1: Discovery (Evidence Collection)

```markdown
## Step 1.1: Scan Solution Structure
**Task:** List all projects in .sln file
**Evidence Required:** .sln file content
**Output Format:**
```
Solution: [Name.sln]
├── Project1 [.vcxproj] - Status: 🟡 PENDING
├── Project2 [.vcxproj] - Status: 🟡 PENDING
└── Project3 [.vcxproj] - Status: 🟡 PENDING

Verification Queue:
- [ ] User confirm all projects listed
```

## Step 1.2: Parse Project Dependencies
**Task:** Extract ProjectReference from .vcxproj files
**Evidence Required:** Each .vcxproj file
**Output Format:**
```
Project: MainApp.vcxproj
Dependencies Found:
- Common.lib (Line 45) - 🟡 PENDING
- Vision.dll (Line 46) - 🟡 PENDING

Verification Queue:
- [ ] User confirm dependencies are correct
```

## Step 1.3: Identify External Libraries
**Task:** List AdditionalDependencies
**Evidence Required:** .vcxproj Link settings
**Output Format:**
```
External Libraries Detected:
1. opencv_core455.lib
   - File: Vision.vcxproj:67
   - Status: 🟡 PENDING
   - Action: User verify OpenCV version

2. CustomVendor.lib
   - File: Hardware.vcxproj:89
   - Status: 🔴 UNKNOWN (vendor name unclear)
   - Action: User identify vendor
```
```

---

### Phase 2: Verification (User Confirmation)

```markdown
## Verification Checklist Template

### Project: [ProjectName]

#### Build Configuration
- [ ] Platform: Win32/x64 (File: .vcxproj:Line X)
- [ ] Configuration: Debug/Release (File: .vcxproj:Line Y)
- [ ] Output Type: .exe/.dll (File: .vcxproj:Line Z)

Status: 🟡→🟢 (After user confirms)

#### Dependencies
- [ ] Dependency 1: [Name] (File: .vcxproj:Line X)
- [ ] Dependency 2: [Name] (File: .vcxproj:Line Y)

Status: 🟡→🟢 (After user confirms)

#### External Libraries
- [ ] Library 1: [Name + Version] (File: .vcxproj:Line X)
- [ ] Library 2: [Name + Version] (File: .vcxproj:Line Y)

Status: 🟡→🟢 (After user confirms)
```

---

### Phase 3: Documentation (Verified Only)

```markdown
## Documentation Rules

### ✅ Include in Final Document
- Only 🟢 VERIFIED items
- Must have evidence + user confirmation
- Must have verifier name + date

### ❌ Exclude from Final Document
- 🟡 PENDING items → Move to "Verification Queue"
- 🔴 UNKNOWN items → Move to "Investigation Required"
- Speculative statements
- Domain knowledge without evidence

### Document Structure (Mandatory)
```markdown
# [Solution Name] Analysis Report

## Verification Status
📊 **Completion Rate**
- 🟢 VERIFIED: X items (Y%)
- 🟡 PENDING: A items (B%)
- 🔴 UNKNOWN: C items (D%)

⚠️ **Warning: Only Y% of analysis is verified**
**Last Update:** [Date]
**Verified By:** [User Name]

---

## Section 1: Verified Items (Final Documentation)

[Only 🟢 items appear here]

---

## Section 2: Verification Queue (Action Required)

[All 🟡 items requiring user confirmation]

**Next Actions:**
1. User must verify: [Item 1]
2. User must verify: [Item 2]

**Deadline:** [Date]
**Assigned To:** [User]

---

## Section 3: Investigation Required (Additional Work)

[All 🔴 items needing further research]

**Investigation Plan:**
1. Item 1: Method [Code review/Interview/Test]
2. Item 2: Method [Code review/Interview/Test]

**Priority:** [High/Medium/Low]
```

---

## AI STATEMENT RESTRICTIONS

### ❌ FORBIDDEN Expressions

| Forbidden | Reason |
|-----------|--------|
| "This uses..." | Unverified assertion |
| "The system employs..." | Speculative |
| "It implements..." | Lacks evidence |
| "Probably..." | Speculation |
| "It seems..." | Uncertain |
| "Generally..." | Domain knowledge |
| "Usually..." | Generic pattern |

### ✅ ALLOWED Expressions

| Allowed | Reason |
|---------|--------|
| "Found in file X:line Y" | Evidence-based |
| "Detected: [code snippet]" | Direct observation |
| "Verification required for..." | Honest limitation |
| "Evidence: [quote]" | Primary source |
| "Status: 🟡 PENDING" | Transparent |
| "UNKNOWN - no evidence" | Honest admission |

---

## ANALYSIS REPORT TEMPLATE

```markdown
# Solution Analysis Report: [SolutionName.sln]

## Executive Summary

**Analysis Date:** [YYYY-MM-DD]
**Analyst:** AI Assistant
**Verifier:** [User Name]
**Verification Date:** [YYYY-MM-DD]

**Completion Status:**
- 🟢 VERIFIED: X items (Y%)
- 🟡 PENDING: A items (B%)
- 🔴 UNKNOWN: C items (D%)

⚠️ **Critical Warning:**
- Only Y% of this analysis has been user-verified
- B% requires immediate user confirmation
- D% requires additional investigation

---

## 1. VERIFIED SOLUTION STRUCTURE 🟢

### 1.1 Solution File
**Status:** 🟢 VERIFIED
**Verifier:** [User] | **Date:** [YYYY-MM-DD]

**Evidence:**
```
File: Solution.sln:1-5
Microsoft Visual Studio Solution File, Format Version 12.00
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MainApp", "MainApp\MainApp.vcxproj"
...
```

**Confirmed Projects:** 5
1. MainApp.exe
2. Vision.dll
3. Hardware.dll
4. Common.dll
5. UnitTests.exe

---

### 1.2 Project Dependencies
**Status:** 🟢 VERIFIED
**Verifier:** [User] | **Date:** [YYYY-MM-DD]

**Dependency Graph:**
```
MainApp.exe
├── Vision.dll (Verified: Vision.vcxproj:45)
├── Hardware.dll (Verified: Vision.vcxproj:46)
└── Common.dll (Verified: Vision.vcxproj:47)

Vision.dll
└── Common.dll (Verified: Vision.vcxproj:89)

Hardware.dll
└── Common.dll (Verified: Hardware.vcxproj:67)
```

---

### 1.3 External Dependencies
**Status:** 🟢 VERIFIED
**Verifier:** [User] | **Date:** [YYYY-MM-DD]

| Library | Version | Project | Evidence |
|---------|---------|---------|----------|
| OpenCV | 4.5.5 | Vision.dll | Vision.vcxproj:67 |
| Boost | 1.78 | Common.dll | Common.vcxproj:45 |

---

## 2. PENDING VERIFICATION QUEUE 🟡

### 2.1 Threading Model
**Status:** 🟡 PENDING

**Evidence Found:**
```cpp
// MainDlg.cpp:156
AfxBeginThread(WorkerThreadProc, ...);
```

**Unconfirmed Items:**
- Number of worker threads
- Thread priority settings
- Thread synchronization mechanism

**Action Required:**
- [ ] User examine MainDlg.cpp:156-200
- [ ] Confirm thread count
- [ ] Verify synchronization objects

**Priority:** High
**Assigned To:** [User]
**Deadline:** [YYYY-MM-DD]

---

### 2.2 Vision Algorithm Details
**Status:** 🟡 PENDING

**Evidence Found:**
```cpp
// Vision.cpp:234
cv::Canny(src, dst, threshold1, threshold2);
```

**Unconfirmed Items:**
- threshold1 value
- threshold2 value
- Pre-processing steps

**Action Required:**
- [ ] User examine Vision.cpp:234
- [ ] Extract parameter values
- [ ] Document pre-processing pipeline

**Priority:** Medium
**Assigned To:** [User]
**Deadline:** [YYYY-MM-DD]

---

## 3. INVESTIGATION REQUIRED 🔴

### 3.1 PLC Communication Protocol
**Status:** 🔴 UNKNOWN

**Reason:** No direct evidence in code
**Search Performed:** 
- Searched for "PLC", "Protocol", "Communication"
- Examined Hardware.dll source files
- Found generic socket code only

**Investigation Options:**
1. **Developer Interview** (Recommended)
   - Question: What PLC protocol is used?
   - Estimated Time: 30 minutes

2. **Runtime Analysis**
   - Method: Packet capture during operation
   - Estimated Time: 2 hours

3. **External Documentation**
   - Search for: Design docs, vendor manuals
   - Estimated Time: 1 hour

**Priority:** High
**Business Impact:** Cannot replicate PLC communication
**Assigned To:** [User]
**Deadline:** [YYYY-MM-DD]

---

### 3.2 Configuration File Format
**Status:** 🔴 UNKNOWN

**Reason:** config.ini referenced but not found
**Evidence:**
```cpp
// Common.cpp:45
LoadConfig("config.ini");
```

**Investigation Options:**
1. **Runtime Inspection**
   - Run application and locate config.ini
   - Document all parameters

2. **Default Configuration**
   - Examine LoadConfig() implementation
   - Identify default values

**Priority:** Medium
**Assigned To:** [User]
**Deadline:** [YYYY-MM-DD]

---

## 4. NEXT ACTIONS

### Immediate (24 hours)
1. ✅ User verify Section 2.1 (Threading Model)
2. ✅ User verify Section 2.2 (Vision Algorithm)

### Short-term (1 week)
3. ✅ Investigate PLC protocol (Section 3.1)
4. ✅ Locate config.ini (Section 3.2)

### Verification Meeting
**Scheduled:** [YYYY-MM-DD HH:MM]
**Attendees:** AI + User
**Agenda:**
- Review pending items
- Approve verified items
- Plan investigations

---

## 5. QUALITY METRICS

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Verification Rate | >90% | Y% | ⚠️ Below target |
| Evidence Quality | Grade 1 | Mixed | ⚠️ Improvement needed |
| User Confirmation | 100% pending | 0% | ⚠️ Action required |
| Documentation Complete | 100% | Y% | 🔄 In progress |

---

## 6. RISK ASSESSMENT

### High Risk Items
- PLC Protocol (🔴 UNKNOWN) - Cannot replicate
- Thread Synchronization (🟡 PENDING) - May cause bugs

### Medium Risk Items
- Vision Parameters (🟡 PENDING) - May affect accuracy
- Config Format (🔴 UNKNOWN) - May prevent deployment

### Mitigation Plan
1. Prioritize high-risk investigations
2. Schedule verification meeting
3. Document all assumptions explicitly

---

**Report Status:** DRAFT - Awaiting User Verification
**Next Update:** [YYYY-MM-DD]
**Approved By:** [Pending]
```

---

## CHECKPOINT PROTOCOL

### Checkpoint 1: After Evidence Collection
**AI must ask:**
> "Evidence collection complete. Found X items.
> - 🟢 VERIFIED: 0 (requires your confirmation)
> - 🟡 PENDING: Y (requires verification)
> - 🔴 UNKNOWN: Z (requires investigation)
> 
> **Next Action:** Review verification queue in Section 2.
> Proceed with verification?"

**User must respond:** "Approved to proceed" or "Revise findings"

---

### Checkpoint 2: After Each Verification
**AI must ask:**
> "Item verified: [Item Name]
> - Evidence: [File:Line]
> - Your confirmation: [Details]
> - Status: 🟡→🟢
> 
> **Action:** Update documentation?
> **Remaining:** X items in verification queue"

**User must respond:** "Update" or "Reject"

---

### Checkpoint 3: Before Final Documentation
**AI must ask:**
> "Analysis complete. Quality check:
> - 🟢 VERIFIED: X items (Y%)
> - 🟡 PENDING: A items (B%)
> - 🔴 UNKNOWN: C items (D%)
> 
> ⚠️ Warning: Only Y% verified.
> 
> **Options:**
> 1. Finalize documentation (Y% complete)
> 2. Continue verification (increase Y%)
> 3. Revise and restart
> 
> Your decision?"

**User must respond:** Choose option 1, 2, or 3

---

## QUALITY GATES

### Gate 1: Minimum Verification Rate
**Requirement:** ≥70% 🟢 VERIFIED before final documentation
**If failed:** AI must halt and request more verification

### Gate 2: Critical Items
**Requirement:** All "High Priority" items must be 🟢 or 🔴 (no 🟡)
**If failed:** AI must list critical pending items

### Gate 3: Evidence Quality
**Requirement:** All 🟢 items must have Grade 1 or Grade 2 evidence
**If failed:** AI must upgrade evidence or downgrade status

### Gate 4: User Approval
**Requirement:** User explicit "Approved" statement
**If failed:** Documentation marked as DRAFT

---

## FAILURE RECOVERY

### If AI Makes Unverified Claims
**User action:**
```markdown
⚠️ PROTOCOL VIOLATION DETECTED

**Claim:** "[Quote AI statement]"
**Issue:** Lacks evidence / Speculative / Unverified
**Severity:** [High/Medium/Low]

**Required Correction:**
1. AI must retract statement
2. AI must reclassify as 🟡 or 🔴
3. AI must add to verification queue
4. AI must apologize and cite this protocol

**Status:** UNRESOLVED until corrected
```

**AI must respond:**
```markdown
✅ PROTOCOL VIOLATION ACKNOWLEDGED

**Retraction:** [Original statement] is retracted
**Reclassification:** Status changed to 🟡 PENDING
**Evidence:** [File:Line] or "No evidence - status 🔴"
**Added to:** Verification Queue / Investigation List

**Apology:** I apologize for the unverified claim. 
Per AI_VERIFICATION_PROTOCOL.md Section [X], 
all claims must have primary evidence and user confirmation.

**Corrective Action:** [Describe what will be done]
```

---

## PROTOCOL COMPLIANCE

### AI Self-Check Before Each Statement
```
[ ] Have primary evidence (File:Line)?
[ ] Evidence is Grade 1 or 2?
[ ] User has confirmed this item?
[ ] Using only ALLOWED expressions?
[ ] Avoiding FORBIDDEN expressions?
[ ] Status accurately reflects verification level?

If ANY checkbox is empty → Use 🟡 or 🔴, NOT 🟢
```

### User Audit Rights
User may challenge any 🟢 item:
- Request evidence
- Request verification record
- Downgrade to 🟡 if insufficient

AI must comply immediately without debate.

---

## REVISION HISTORY

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-03-05 | 1.0 | Initial protocol | AI Assistant |
| [TBD] | [TBD] | [TBD] | [TBD] |

---

**PROTOCOL STATUS:** ACTIVE
**MANDATORY FOR:** All solution/project analysis tasks
**SUPERSEDES:** Previous informal analysis methods
**NEXT REVIEW:** [YYYY-MM-DD]
