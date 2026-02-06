# Interview Skill

This Claude skill conducts in-depth interviews to surface non-obvious concerns, edge cases, and tradeoffs for features, specs, or ideas.

## Quick Start

To use this skill, simply ask Claude:

```
interview docs/03-build-notes/m3/01-tenant-principal-models.md
```

or

```
interview "user authentication flow"
```

or

```
interview
```

(and Claude will ask what you want to discuss)

The skill will:
1. Read the spec/topic (if provided)
2. Interview you systematically about all relevant areas
3. Surface edge cases and tradeoffs
4. Synthesize findings
5. Offer to create or update issue specs

## Skill Structure

```
.claude/skills/interview/
├── SKILL.md              # Main skill definition
└── README.md             # This file
```

## Key Features

- **Systematic Coverage**: Probes technical, operational, security, performance, and maintainability concerns
- **Deep Exploration**: Goes beyond surface-level questions to uncover edge cases and tradeoffs
- **Workflow Integration**: Understands issue spec format and milestone structure
- **Actionable Output**: Can create or update issue specs with refined requirements

## Interview Areas

The skill systematically explores:

- **Technical Implementation**: Architecture, data models, APIs, dependencies
- **UI/UX Considerations**: User flows, error states, accessibility, edge cases
- **Operational Concerns**: Monitoring, debugging, rollback, logging, alerting
- **Security and Privacy**: Auth, data protection, validation, compliance
- **Performance and Scalability**: Targets, caching, optimization, resource constraints
- **Maintainability and Extensibility**: Code structure, testing, documentation, future needs

## Integration

This skill integrates with:
- Issue spec files in `docs/03-build-notes/<milestone>/`
- Implementation plans for milestone structure
- Workflow guides for conventions
- GitHub issue format (YAML frontmatter)

## Use Cases

- **Before creating issue specs**: Interview about a new feature to refine requirements
- **Refining existing specs**: Interview about an existing issue spec that needs clarification
- **Exploring ideas**: Interview about a concept before formalizing it
- **Epic planning**: Interview about milestone scope and dependencies

## See Also

- [Implementation Workflow](../../../docs/guides/implementation-workflow.md)
- [Development Cadence](../../../docs/guides/dev-cadence.md)
- [Build Notes README](../../../docs/03-build-notes/README.md) - Issue spec format



