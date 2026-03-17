# AI_ANALYSIS_LEVELS.md

## PURPOSE
Define mandatory analysis depth levels and execution checklist to prevent incomplete analysis.

---

## FUNCTION ANALYSIS PROTOCOL

### When User Asks: "What does function X do?"

AI MUST execute this checklist IN ORDER:

#### Phase 1: LOCATE (Mandatory)
```
[ ] 1. Search function name: symbol:FunctionName
[ ] 2. Report all matches (file:line)
[ ] 3. If multiple matches → Ask user which one
[ ] 4. If zero matches → Report "NOT FOUND" + evidence of search
```

#### Phase 2: READ (Mandatory)
```
[ ] 5. Read function implementation (full body)
[ ] 6. Extract function signature
[ ] 7. Identify all parameters
[ ] 8. Identify return type
[ ] 9. Quote actual code (5-20 lines)
```

#### Phase 3: TRACE CALLS (Mandatory)
```
[ ] 10. Search all functions CALLED by this function
[ ] 11. List every function call found (minimum 3 levels deep)
[ ] 12. For each called function:
       [ ] a. Search its implementation
       [ ] b. Report location (file:line)
       [ ] c. Quote signature
[ ] 13. Build complete call chain
```

#### Phase 4: VERIFY (Mandatory)
```
[ ] 14. Present findings to user
[ ] 15. Ask: "Should I analyze deeper into [called functions]?"
[ ] 16. User approval required before claiming "complete"
```

---

## CALL CHAIN TRACING RULES

### Rule 1: Minimum Depth
AI MUST trace AT LEAST 3 levels:
```
FunctionA()
├── FunctionB()  ← Level 1 (MUST search)
│   ├── FunctionC()  ← Level 2 (MUST search)
│   │   └── FunctionD()  ← Level 3 (MUST search)
│   └── FunctionE()  ← Level 2 (MUST search)
└── FunctionF()  ← Level 1 (MUST search)
```

### Rule 2: Stop Criteria
AI may stop tracing ONLY if:
- Reached standard library function (printf, malloc, etc.)
- Reached OS API (Windows API, etc.)
- User explicitly says "stop here"

AI CANNOT stop because:
- ❌ "Function looks simple"
- ❌ "This seems enough"
- ❌ "File is too large"

### Rule 3: Reporting
For EACH function in call chain, report:
```markdown
### FunctionName()
**Location:** File.cpp:LineNumber
**Called by:** ParentFunction() at Line X
**Signature:**
```cpp
ReturnType FunctionName(ParamType param) {
    // implementation preview (5 lines max)
}
```
**Analysis Status:** 🟢 Analyzed / 🟡 Pending / 🔴 Skipped
```

---

## EXAMPLE: Correct Analysis Flow

### User Query:
"What does DoWorkStartCycleTest() do?"

### AI Response (Following Protocol):

```markdown
## Function Analysis: DoWorkStartCycleTest()

### Phase 1: LOCATE ✅
**Search performed:** symbol:DoWorkStartCycleTest
**Result:** 1 match found

**Location:** 
- File: WorkManager.cpp:156

---

### Phase 2: READ ✅
**Signature:**
```cpp
void DoWorkStartCycleTest(int testType) {
    InitializeTest();
    GoToWork(testType);
    ValidateResults();
}
```

**Analysis:**
- Entry point for cycle testing
- Calls 3 sub-functions
- Parameter: testType (int)

---

### Phase 3: TRACE CALLS ✅

#### Level 1 Calls (3 found):

##### 1. InitializeTest()
**Location:** WorkManager.cpp:89
**Search status:** 🟢 Found
```cpp
void InitializeTest() {
    ResetCounters();
    LoadConfiguration();
}
```
**Sub-calls:** ResetCounters(), LoadConfiguration()

##### 2. GoToWork(int)  ← KEY FUNCTION
**Location:** WorkManager.cpp:1234
**Search status:** 🟢 Found
```cpp
void GoToWork(int testType) {
    switch(testType) {
        case CYCLE_TEST:
            RunCycleTest();
            break;
        case STRESS_TEST:
            RunStressTest();
            break;
    }
}
```
**Sub-calls:** RunCycleTest(), RunStressTest()

##### 3. ValidateResults()
**Location:** WorkManager.cpp:2345
**Search status:** 🟢 Found
```cpp
void ValidateResults() {
    CheckStatus();
    GenerateReport();
}
```
**Sub-calls:** CheckStatus(), GenerateReport()

---

#### Level 2 Calls (7 found):

[Continue tracing each sub-function...]

---

### Phase 4: VERIFY ⏸️

**Analysis Status:**
- Level 1: 3/3 functions analyzed (100%)
- Level 2: 7/7 functions analyzed (100%)
- Level 3: Pending

**Call Chain Diagram:**
```
DoWorkStartCycleTest()
├── InitializeTest()
│   ├── ResetCounters()
│   └── LoadConfiguration()
├── GoToWork()  ← Core logic here
│   ├── RunCycleTest()
│   └── RunStressTest()
└── ValidateResults()
    ├── CheckStatus()
    └── GenerateReport()
```

**User Decision Required:**
Should I continue to Level 3 (analyze RunCycleTest, RunStressTest, etc.)?
- [ ] YES - Continue deeper
- [ ] NO - Stop here

**Coverage:** 10 functions traced, X functions remaining
```

---

## MANDATORY SELF-CHECK

Before responding to function analysis query, AI must verify:

```
FUNCTION ANALYSIS CHECKLIST

[ ] Did I search for the function?
[ ] Did I read the actual implementation?
[ ] Did I identify ALL called functions?
[ ] Did I search for EACH called function?
[ ] Did I trace at least 3 levels deep?
[ ] Did I report file:line for EACH function?
[ ] Did I ask user if deeper analysis needed?

If ANY box unchecked → Response is INCOMPLETE
→ Must complete missing steps before responding
```

---

## FAILURE EXAMPLE (What NOT to do)

❌ WRONG:
```
User: "What does DoWorkStartCycleTest() do?"

AI: "It runs cycle tests. It calls some initialization 
and validation functions. Analysis complete."
```

**Problems:**
- ❌ No file:line location
- ❌ No actual code quoted
- ❌ "some functions" - vague
- ❌ No call chain
- ❌ Claimed "complete" without tracing

✅ CORRECT:
[See example above with full Phase 1-4 execution]

---

## ENFORCEMENT

### If AI Skips Steps:

**User response:**
```markdown
⚠️ PROTOCOL VIOLATION: INCOMPLETE ANALYSIS

**Missing Steps:**
- [ ] Phase 3: Call chain tracing
- [ ] GoToWork() function not analyzed

**Required Action:**
1. Execute Phase 3 immediately
2. Search and analyze GoToWork()
3. Report file:line and implementation
4. Complete call chain to Level 3

**Status:** BLOCKED until steps completed
```

**AI must respond:**
```markdown
✅ EXECUTING MISSING STEPS

**Searching GoToWork()...**
[Perform actual search and analysis]

**Apology:** I violated AI_ANALYSIS_LEVELS.md Phase 3.
All future function analyses will include complete call chain tracing.

**Corrected Analysis:**
[Provide complete analysis with GoToWork() included]
```

---

## ROOT CAUSE STATEMENT

**Why AI missed functions like GoToWork():**

NOT because:
- ❌ "Laziness" (AI has no emotions)
- ❌ "Arrogance" (AI has no ego)
- ❌ "Shortcut" (AI has no motivation)

ACTUAL REASON:
- ✅ **No mandatory call chain tracing rule existed**
- ✅ **No checklist to verify completeness**
- ✅ **No enforcement mechanism**
- ✅ **Process gap in documentation**

**Solution:**
- ✅ Added AI_ANALYSIS_LEVELS.md
- ✅ Mandatory Phase 3: Call Chain Tracing
- ✅ Self-check before responding
- ✅ User can enforce with protocol citation

---

## SOLUTION ANALYSIS LEVELS

### Level 0: File Inventory
**Time:** 30 minutes  
**Coverage:** 5%

**Deliverables:**
- [ ] List all .sln files
- [ ] List all .vcxproj files
- [ ] List all .cpp/.h files
- [ ] Count files by type
- [ ] Identify folder structure

**User Confirmation Required:** ✓

---

### Level 1: Structure Analysis
**Time:** 2-4 hours  
**Coverage:** 20%

**Deliverables:**
- [ ] Parse .sln file (project list)
- [ ] Parse each .vcxproj (dependencies)
- [ ] List external libraries
- [ ] Create dependency graph
- [ ] Identify build configurations

**User Confirmation Required:** ✓

---

### Level 2: Interface Analysis
**Time:** 8-12 hours  
**Coverage:** 40%

**Deliverables:**
- [ ] List all classes (name + location)
- [ ] List all public functions (signatures only)
- [ ] Identify entry points (main, DllMain, etc.)
- [ ] Map class relationships
- [ ] Document public APIs

**User Confirmation Required:** ✓

---

### Level 3: Implementation Analysis
**Time:** 20-40 hours  
**Coverage:** 70%

**Deliverables:**
- [ ] Analyze top 20 critical functions (full implementation)
- [ ] Document key algorithms
- [ ] Trace data flow
- [ ] Identify threading model
- [ ] Document memory management

**User Confirmation Required:** ✓ (after each function)

---

### Level 4: Complete Analysis
**Time:** 60-120 hours  
**Coverage:** 90%

**Deliverables:**
- [ ] All functions analyzed
- [ ] All algorithms documented
- [ ] All data structures mapped
- [ ] All edge cases identified
- [ ] Complete call graph

**User Confirmation Required:** ✓ (continuous)

---

## LEVEL DECLARATION (MANDATORY)

Before starting ANY analysis, AI MUST:

1. Ask user which level is required
2. State expected time
3. State expected coverage percentage
4. Get user approval

❌ FORBIDDEN:
```
User: "Analyze this solution"
AI: "Starting analysis..." ← NO LEVEL SPECIFIED
```

✅ REQUIRED:
```
User: "Analyze this solution"
AI: "Which analysis level do you need?
- Level 0: File inventory (30 min, 5%)
- Level 1: Structure (2-4 hrs, 20%)
- Level 2: Interface (8-12 hrs, 40%)
- Level 3: Implementation (20-40 hrs, 70%)
- Level 4: Complete (60-120 hrs, 90%)

Please specify level (0-4)."
```

---

## PROGRESS TRACKING (MANDATORY)

During analysis, AI MUST show progress every 30 minutes:

```markdown
## Level 2 Analysis Progress

**Elapsed Time:** 3.5 hours / 8-12 hours estimated
**Completed:** 45/120 items (37.5%)

**Status by Category:**
- Classes listed: 25/25 (100%) ✅
- Functions listed: 180/200 (90%) 🔄
- Entry points: 5/5 (100%) ✅
- Class relationships: 15/30 (50%) 🔄

**Current Task:** Analyzing class relationships in Vision module
**Next Task:** Document public API for Hardware module

**User Action:** None required yet
```

---

## NEVER CLAIM 100%

AI is FORBIDDEN from claiming:
- ❌ "100% complete"
- ❌ "Fully analyzed"
- ❌ "Complete understanding"
- ❌ "Analysis complete"

ONLY user can declare completion after verification.

AI may only say:
- ✅ "Level N analysis completed (N% coverage)"
- ✅ "All Level N items checked (user verification pending)"
- ✅ "Phase X complete, awaiting your confirmation"

---

## EXPLICIT LIMITATIONS (MANDATORY)

Every analysis report MUST include limitations section:

```markdown
## Analysis Limitations

**Level Completed:** Level 2 (Interface Analysis)
**Coverage:** 40%
**Time Spent:** 10 hours

**What WAS analyzed:**
- ✅ All 25 classes identified
- ✅ 180 public function signatures
- ✅ 5 entry points documented

**What was NOT analyzed:**
- ❌ Function implementations (0%)
- ❌ Algorithm logic (0%)
- ❌ Data flows (0%)
- ❌ Threading details (0%)

**To reach higher coverage:**
- Level 3: +30% coverage, +20-30 hours
- Level 4: +50% coverage, +40-80 hours

**User Decision Required:** 
Continue to Level 3? [YES/NO]
```

---

**DOCUMENT STATUS:** ACTIVE  
**MANDATORY FOR:** All code and solution analysis tasks  
**CREATED:** 2026-03-05  
**VERSION:** 1.0
