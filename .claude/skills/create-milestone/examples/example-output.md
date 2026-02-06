# Example Output: Create Milestone

## Full Session Example

```
create-milestone m5 --from-roadmap
```

---

### Initialize

```
═══════════════════════════════════════════════
Creating Milestone: m5
═══════════════════════════════════════════════

📂 Loading context...
✓ Roadmap: docs/01-roadmap/roadmap.md
✓ Found: M5 - Detection Ingest Pipeline

📋 Roadmap Context:
  Title: Detection Ingest Pipeline
  Scope: Real-time ingestion, validation, storage
  Dependencies: M4 (Risk Assessment)

✓ Created: docs/03-build-notes/milestones/m5/
```

---

### Epic Interview

```
═══════════════════════════════════════════════
Phase 1: Epic Definition
═══════════════════════════════════════════════

The roadmap describes M5 as "Detection Ingest Pipeline" 
for ingesting detection data from sensors and feeds.

? What is the primary problem this milestone solves?
```

**User:** Real-time detection data from field sensors needs to be ingested, validated, and stored efficiently for downstream risk analysis.

```
? Who are the primary users of this capability?
```

**User:** Internal risk analysis services and the monitoring dashboard.

```
? What does success look like? (specific metrics if possible)
```

**User:** 1000 events/sec throughput, <100ms p99 latency, 99.9% uptime.

```
? What is explicitly OUT of scope for this milestone?
```

**User:** Complex event processing, alerting, and historical data migration.

```
✓ Generating 00-epic.md...
✓ Created: docs/03-build-notes/milestones/m5/00-epic.md
```

---

### Specification Interview

```
═══════════════════════════════════════════════
Phase 2: Technical Specification
═══════════════════════════════════════════════

? What is the high-level architecture for the ingest pipeline?
```

**User:** HTTP endpoint receives events, validates against schema, queues to Kafka, consumer writes to TimescaleDB.

```
? What data models or schemas are needed?
```

**User:** DetectionEvent with timestamp, location, sensor_id, detection_type, confidence, and raw_payload.

```
? What are the key technical tradeoffs you've considered?
```

**User:** Sync vs async validation - going with async for throughput. Schema-first vs schema-on-read - going with strict schema validation upfront.

```
? Any specific technology choices already decided?
```

**User:** TimescaleDB for storage (already in stack), Kafka for queuing (new).

```
✓ Generating 00-SPECIFICATION.md...
✓ Created: docs/03-build-notes/milestones/m5/00-SPECIFICATION.md
```

---

### Issue Breakdown Interview

```
═══════════════════════════════════════════════
Phase 3: Issue Breakdown
═══════════════════════════════════════════════

Based on the specification, I propose these issues:

1. Add ingest HTTP endpoint
2. Add DetectionEvent schema and validation
3. Add Kafka producer integration
4. Add TimescaleDB schema and migrations
5. Add Kafka consumer and storage service
6. Add health check and metrics endpoints
7. Add integration tests

? Does this breakdown look right? Any additions or changes?
```

**User:** Add "Add rate limiting middleware" after the endpoint. Otherwise good.

```
? What is the right granularity? Should any be split or combined?
```

**User:** #5 (consumer + storage) could be split. Let's make it two issues.

```
Updated breakdown:
1. Add ingest HTTP endpoint
2. Add rate limiting middleware
3. Add DetectionEvent schema and validation
4. Add Kafka producer integration
5. Add TimescaleDB schema and migrations
6. Add Kafka consumer service
7. Add storage service
8. Add health check and metrics endpoints
9. Add integration tests

? Confirm this breakdown? yes | no
```

**User:** yes

```
Generating issue specs...

Issue #01: Add ingest HTTP endpoint
? What are the key acceptance criteria?
```

**User:** POST /api/v0/detections, accepts JSON, returns 202, validates content-type.

```
✓ Created: 01-ingest-endpoint.md

Issue #02: Add rate limiting middleware
? What are the rate limits?
```

**User:** 1000 req/sec per API key, 10000 req/sec global.

```
✓ Created: 02-rate-limiting.md

...

✓ Created: 09-integration-tests.md

✓ Generated 9 issue specs
```

---

### Implementation Plan Interview

```
═══════════════════════════════════════════════
Phase 4: Implementation Plan
═══════════════════════════════════════════════

? How should issues be grouped into phases?
```

**User:** Phase 1: endpoint + rate limiting + schema. Phase 2: Kafka producer + TimescaleDB. Phase 3: Consumer + storage + metrics. Phase 4: Integration tests.

```
? What is the milestone branch name?
```

**User:** milestone/m5-detection-ingest

```
? Any scope tags for sensitive code detection?
```

**User:** detection, ingest

```
✓ Generating IMPLEMENTATION_PLAN.md...
✓ Created: docs/03-build-notes/milestones/m5/IMPLEMENTATION_PLAN.md
```

---

### GitHub Issues

```
═══════════════════════════════════════════════
Phase 5: GitHub Issues
═══════════════════════════════════════════════

Create GitHub issues for each spec?

yes | no | later
```

**User:** yes

```
Creating GitHub issues...

✓ #301: Add ingest HTTP endpoint
✓ #302: Add rate limiting middleware
✓ #303: Add DetectionEvent schema and validation
✓ #304: Add Kafka producer integration
✓ #305: Add TimescaleDB schema and migrations
✓ #306: Add Kafka consumer service
✓ #307: Add storage service
✓ #308: Add health check and metrics endpoints
✓ #309: Add integration tests

✓ Updated issue specs with github_issue numbers
✓ Created milestone: M5 - Detection Ingest Pipeline
```

---

### Summary

```
═══════════════════════════════════════════════
✓ Milestone M5 Created
═══════════════════════════════════════════════

Artifacts:
  ✓ docs/03-build-notes/milestones/m5/00-epic.md
  ✓ docs/03-build-notes/milestones/m5/00-SPECIFICATION.md
  ✓ docs/03-build-notes/milestones/m5/01-ingest-endpoint.md
  ✓ docs/03-build-notes/milestones/m5/02-rate-limiting.md
  ✓ docs/03-build-notes/milestones/m5/03-schema-validation.md
  ✓ docs/03-build-notes/milestones/m5/04-kafka-producer.md
  ✓ docs/03-build-notes/milestones/m5/05-timescaledb-schema.md
  ✓ docs/03-build-notes/milestones/m5/06-kafka-consumer.md
  ✓ docs/03-build-notes/milestones/m5/07-storage-service.md
  ✓ docs/03-build-notes/milestones/m5/08-health-metrics.md
  ✓ docs/03-build-notes/milestones/m5/09-integration-tests.md
  ✓ docs/03-build-notes/milestones/m5/IMPLEMENTATION_PLAN.md

GitHub: 9 issues created (#301-#309)
Phases: 4
Estimated issues: 9

Next Steps:
1. Review generated specs:
   cat docs/03-build-notes/milestones/m5/IMPLEMENTATION_PLAN.md

2. Create milestone branch:
   git checkout -b milestone/m5-detection-ingest main
   git push origin milestone/m5-detection-ingest

3. Run milestone:
   run-milestone m5
```

---

## Quick Mode Example

```
create-milestone m6 --quick
```

```
═══════════════════════════════════════════════
Creating Milestone: m6 (Quick Mode)
═══════════════════════════════════════════════

📂 Loading roadmap...
✓ Found: M6 - Fusion Engine

📋 Extracted scope:
  - Combine detection and weather data
  - Risk calculation engine
  - Caching layer

Proposed breakdown:
  1. Add fusion data models
  2. Add weather data integration
  3. Add detection data integration
  4. Add risk calculation engine
  5. Add caching layer
  6. Add fusion API endpoints

? Proceed with this breakdown? yes | no | customize
```

**User:** yes

```
Generating with defaults...

✓ 00-epic.md (from roadmap description)
✓ 00-SPECIFICATION.md (skeleton)
✓ 6 issue specs (basic structure)
✓ IMPLEMENTATION_PLAN.md (2 phases)

═══════════════════════════════════════════════
✓ Milestone M6 Created (Quick Mode)
═══════════════════════════════════════════════

Note: Generated specs use defaults. Review and refine:
  - Add detailed acceptance criteria
  - Expand implementation notes
  - Verify phase organization

Edit specs in: docs/03-build-notes/milestones/m6/
```

---

## Refine Existing Example

```
create-milestone m5
```

```
⚠️ Milestone folder exists

Found:
  ✓ 00-epic.md
  ✓ 00-SPECIFICATION.md
  ✗ Issue specs (0 found)
  ✗ IMPLEMENTATION_PLAN.md

refine | overwrite | abort
```

**User:** refine

```
Loading existing artifacts...
✓ Loaded epic (goals, success criteria)
✓ Loaded specification (architecture)

Continuing from issue breakdown...

Based on the specification, I propose these issues:
...
```
