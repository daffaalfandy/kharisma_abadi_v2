# Reference Documentation

This project is a complete rebuild of the Kharisma Abadi application.

## Important: Read This First

All analysis and planning documentation has been completed in a separate analysis project and copied to this project's `docs/` directory.

### Key Documents to Reference

**Must Read Before Starting:**
1. **`docs/planning/PRD.md`** - Product Requirements Document (BMAD method)
   - Contains all requirements, goals, and success criteria
   - Defines technology stack and approach
   - Lists all functional and non-functional requirements

2. **`docs/technical/TECHNICAL-SPEC.md`** - Technical Specification
   - System architecture design
   - Technology stack details
   - Database schema design
   - API design patterns
   - Security specifications
   - Testing strategy

**Business Logic Reference:**
3. **`docs/business-logic/business-rules-catalog.md`** - All business rules
4. **`docs/business-flows/README.md`** - Business process flows
5. **`docs/planning/user-stories.md`** - User stories with acceptance criteria

**Current System Analysis:**
6. **`docs/analysis/current-app-analysis.md`** - Current system overview
7. **`docs/database/schema-documentation.md`** - Database schema
8. **`docs/api/endpoints-catalog.md`** - Existing API endpoints

## Project Context

**Old Application:**
- Location: `~/personal/kharisma_abadi/`
- Backend: Flask (Python)
- Frontend: Next.js
- Database: MariaDB (3+ years of production data)

**New Application (This Project):**
- Technology: [As per TECHNICAL-SPEC.md]
- Architecture: Clean Architecture / DDD
- Goal: Maintainable, scalable, modern codebase
- Data Migration: Preserve all existing data

## Development Phases Complete

- ✅ Phase 1: Analysis & Discovery
- ✅ Phase 2: Planning & Documentation
- 🔄 Phase 3+: Implementation (Current)

## Original Project Location

The original application and analysis results are at:
`/Users/remotemac/personal/kharisma_abadi/`

The SQL backup for reference:
`/Users/remotemac/personal/kharisma_abadi/db-backup-scripts/backups/kharisma_db.sql`

## How to Use This Project

1. Read PRD.md and TECHNICAL-SPEC.md first
2. Follow the architecture patterns defined in technical specs
3. Refer to business-rules-catalog.md for all business logic
4. Use user-stories.md for sprint planning
5. Check business-flows/ for workflow diagrams

## Documentation Structure

```
docs/
├── analysis/           # Current system analysis
├── api/               # API documentation
├── business-flows/    # Workflow diagrams
├── business-logic/    # Business rules
├── database/          # Database schema
├── planning/          # PRD, user stories
└── technical/         # Technical specifications
```

## Next Steps

1. Read all documentation in the order listed above
2. Set up development environment (Phase 4)
3. Implement features according to user stories
4. Follow architecture patterns from TECHNICAL-SPEC.md
5. Write tests for all features
6. Deploy and migrate data
```