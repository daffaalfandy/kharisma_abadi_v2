# Kharisma Abadi V2

Modern, maintainable rebuild of the Kharisma Abadi multi-service cashier system.

## About

Kharisma Abadi is a business offering multiple services:
- Car Wash Service
- Laundry Service
- Carpet Washing Service
- Drinking Water Delivery Service

This is a complete rebuild of the existing application with focus on:
- **Maintainability** - Clean architecture, clear patterns
- **Scalability** - Handle business growth
- **Type Safety** - TypeScript/Pydantic throughout
- **Testing** - Comprehensive test coverage
- **Documentation** - Self-documenting code

## Documentation

**Start Here:**
1. Read `REFERENCE.md` - Documentation index and project context
2. Read `docs/planning/PRD.md` - Product requirements
3. Read `docs/technical/TECHNICAL-SPEC.md` - Technical specifications

**All Documentation:**
- `docs/planning/` - Requirements, user stories, sprint plans
- `docs/technical/` - Architecture, API specs, database design
- `docs/business-logic/` - Business rules and workflows
- `docs/business-flows/` - Process diagrams
- `docs/analysis/` - Current system analysis
- `docs/database/` - Database schema documentation
- `docs/api/` - API endpoint documentation

## Technology Stack

See `docs/technical/TECHNICAL-SPEC.md` for detailed stack.

**Backend:** FastAPI (Python) or NestJS (TypeScript)
**Frontend:** Next.js 14+ with TypeScript
**Database:** MariaDB
**Testing:** Pytest/Jest
**DevOps:** Docker, GitHub Actions

## Development

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for frontend)
- Python 3.11+ (for backend if using FastAPI)

### Getting Started

```bash
# Clone the repository
git clone [repo-url]
cd kharisma-abadi-v2

# Follow setup instructions in docs/technical/TECHNICAL-SPEC.md
```

### Project Structure

```
├── backend/         # Backend application
├── frontend/        # Frontend application
├── docs/           # All documentation
├── .claude/        # Claude Code skills
└── docker-compose.yml
```

## Contributing

1. Read documentation first (REFERENCE.md, PRD.md, TECHNICAL-SPEC.md)
2. Pick a user story from `docs/planning/product-backlog.md`
3. Follow architecture patterns in `docs/technical/TECHNICAL-SPEC.md`
4. Write tests for all features
5. Update documentation if needed

## License

[Your License]

## Contact

[Your Contact Info]
```

---

## How to Use the New Project with Claude

### First Time Setup

1. **Create and set up the new project directory** (as shown above)

2. **Activate the new project with Claude:**

```bash
cd ~/personal/kharisma-abadi-v2
claude
```

3. **Tell Claude to onboard:**

```
Please run the project-onboarding skill to understand this project's context and documentation.
```

Or manually instruct:

```
I've set up a new project for rebuilding the Kharisma Abadi application.

IMPORTANT: Before doing anything, please read these files in order:
1. REFERENCE.md - Project context
2. docs/planning/PRD.md - All requirements
3. docs/technical/TECHNICAL-SPEC.md - Architecture and design

All analysis and planning is complete. Your job is to implement according to these specifications.
```

### When Implementing Features

**Good prompts:**

```
Implement user story US-004 (Create Car Wash Order) according to:
- Specifications in docs/planning/user-stories.md
- Business rules in docs/business-logic/business-rules-catalog.md
- Architecture patterns in docs/technical/TECHNICAL-SPEC.md
```

```
Set up the backend project structure according to docs/technical/TECHNICAL-SPEC.md section 2.1
```

```
Create the database models for the car wash service based on:
- Schema in docs/database/schema-documentation.md
- Design in docs/technical/TECHNICAL-SPEC.md section 3
```

### Claude Will Automatically

- Reference the documentation in `docs/`
- Follow architecture patterns from TECHNICAL-SPEC.md
- Implement business rules from business-rules-catalog.md
- Use user stories for feature implementation
- Follow the tech stack defined in PRD.md

---

## Skills Distribution

### Keep in Old Project (`kharisma_abadi/`)

**Phase 1 & 2 Skills (Analysis & Planning):**
- ✅ analyze-current-app.md
- ✅ database-schema-extractor.md
- ✅ api-endpoint-mapper.md
- ✅ business-logic-analyzer.md
- ✅ business-flow-creator.md
- ✅ prd-generator.md
- ✅ technical-spec-writer.md
- ✅ user-story-generator.md

These generate documentation that you'll copy to the new project.

### Create in New Project (`kharisma-abadi-v2/`)

**Onboarding:**
- project-onboarding.md (created in Step 6)

**Phase 3: Architecture & Design**
- tech-stack-recommender.md
- api-design-generator.md
- database-migration-planner.md
- architecture-diagram-creator.md

**Phase 4: Development Setup**
- repo-initializer.md
- docker-setup-creator.md
- env-config-generator.md
- ci-cd-pipeline-creator.md

**Phase 5+: Implementation, Testing, Deployment**
- (Continue with remaining skills)

---

## Summary Checklist

When transitioning from analysis to implementation:

- [ ] Create new project directory (`kharisma-abadi-v2/`)
- [ ] Copy `docs/` directory from old project
- [ ] Create `REFERENCE.md` with documentation index
- [ ] Create `.claude/memory/project-overview.md`
- [ ] Create `.claude/skills/project-onboarding.md`
- [ ] Create `README.md`
- [ ] Initialize git repository
- [ ] Create `.gitignore`
- [ ] Activate project with Claude
- [ ] Run project-onboarding skill
- [ ] Start implementing Phase 3+ skills
- [ ] Begin development following specifications

---

## Reference: Old Project Location

**Old Project:** `/Users/remotemac/personal/kharisma_abadi/`
- Contains: Old codebase, analysis skills, generated documentation
- SQL Backup: `./db-backup-scripts/backups/kharisma_db.sql`
- Skills: Phase 1 & 2 (8 skills)

**New Project:** `/Users/remotemac/personal/kharisma-abadi-v2/`
- Contains: New codebase, development skills, copied documentation
- Skills: Phase 3+ (30 skills to create)
- References: All docs from old project in `docs/` directory

---

## Questions?

If Claude seems to not have context:
1. Point it to `REFERENCE.md`
2. Ask it to read `docs/planning/PRD.md`
3. Run the `project-onboarding` skill
4. Explicitly reference documentation files in your prompts

The key is that **all specifications are already written** in the `docs/` directory. Claude just needs to read them and implement accordingly.
