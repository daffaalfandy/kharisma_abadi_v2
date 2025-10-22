# Contributing to Kharisma Abadi V2

Thank you for your interest in contributing to Kharisma Abadi V2! This document provides guidelines and instructions for contributing to the project.

## 📖 Getting Started

### Prerequisites

Read the following documentation before starting:
1. [REFERENCE.md](./REFERENCE.md) - Complete documentation index
2. [docs/planning/PRD.md](./docs/planning/PRD.md) - Product requirements
3. [docs/technical/TECHNICAL-SPEC.md](./docs/technical/TECHNICAL-SPEC.md) - Technical architecture
4. [docs/architecture/](./docs/architecture/) - System design and diagrams

### Development Setup

Follow the Quick Start guide in [README.md](./README.md#-quick-start):

```bash
# Clone repository
git clone <repository-url>
cd kharisma-abadi-v2

# Setup
make setup
make dev
```

## 🎯 Development Workflow

### 1. Pick a Task

Tasks are organized in `docs/planning/product-backlog.md`:

- Each task has a user story ID (US-XXX)
- Read the user story title and description
- Check acceptance criteria
- Verify related technical specifications

Example user stories:
- **US-001:** Admin user creation
- **US-004:** Car wash order creation
- **US-010:** Payment processing
- **US-015:** Customer management

### 2. Create Feature Branch

Use descriptive branch names following this pattern:

```bash
# Feature branch
git checkout -b feature/US-XXX-short-description

# Examples:
git checkout -b feature/US-004-car-wash-orders
git checkout -b feature/US-010-payment-processing
git checkout -b feature/US-015-customer-management
```

**Branch naming conventions:**
- `feature/US-XXX-*` - New features
- `fix/BUG-XXX-*` - Bug fixes
- `refactor/REF-XXX-*` - Code refactoring
- `docs/DOC-XXX-*` - Documentation

### 3. Follow Architecture Patterns

The project uses **Clean Architecture** with clear separation:

**Backend (Go + Fiber):**
```
handlers/        → HTTP request/response handling
services/        → Business logic and validations
repositories/    → Data access (GORM queries)
models/          → Domain entities
middleware/      → HTTP middleware (auth, validation)
```

**Frontend (Next.js + TypeScript):**
```
app/             → Next.js App Router pages
components/      → React components (reusable)
services/        → API client functions
hooks/           → Custom React hooks
stores/          → Zustand state management
types/           → TypeScript interfaces
utils/           → Utility functions
```

### 4. Write Tests

#### Backend (Go)

Write tests in `backend/tests/` directory:

```go
// Example: handlers_test.go
package tests

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

func TestCreateOrder(t *testing.T) {
	// Arrange
	setupTestDB()
	req := &CreateOrderRequest{
		CustomerID: 1,
		ServiceType: "car_wash",
		TotalAmount: 50000,
	}
	
	// Act
	handler := NewOrderHandler(db)
	result, err := handler.CreateOrder(req)
	
	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "car_wash", result.ServiceType)
}
```

Run tests:
```bash
cd backend
go test -v ./...              # Verbose output
go test -cover ./...          # With coverage
go test -race ./...           # Race condition detection
```

#### Frontend (TypeScript + Jest)

Write tests in `frontend/__tests__/` directory:

```typescript
// Example: OrderForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import OrderForm from '@/components/OrderForm';

describe('OrderForm', () => {
  it('should submit order successfully', async () => {
    // Arrange
    const mockSubmit = jest.fn();
    render(<OrderForm onSubmit={mockSubmit} />);
    
    // Act
    const input = screen.getByLabelText('Service Type');
    await userEvent.selectOption(input, 'car_wash');
    
    const submitBtn = screen.getByRole('button', { name: /submit/i });
    await userEvent.click(submitBtn);
    
    // Assert
    await waitFor(() => {
      expect(mockSubmit).toHaveBeenCalled();
    });
  });
});
```

Run tests:
```bash
cd frontend
npm test                      # Watch mode
npm run test:coverage         # With coverage report
npm run test:e2e             # Playwright E2E tests
```

**Coverage Requirements:**
- Minimum 80% for critical business logic
- 70% for utility functions
- 60% for UI components

### 5. Code Quality Standards

#### Backend (Go)

**Formatting:**
```bash
go fmt ./...          # Format code
goimports -w .        # Organize imports
```

**Linting:**
```bash
go vet ./...          # Vet for common issues
golangci-lint run    # Comprehensive linting
```

**Code style guide:**
- Follow [Effective Go](https://golang.org/doc/effective_go)
- Use meaningful variable names
- Keep functions small and focused
- Error handling: explicit error checking
- Comments for exported functions/types
- Max line length: 100 characters

**Example:**
```go
// CreateOrder creates a new order with validation
func (s *OrderService) CreateOrder(ctx context.Context, req *CreateOrderRequest) (*Order, error) {
	// Validate input
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("invalid request: %w", err)
	}
	
	// Create order entity
	order := &Order{
		CustomerID: req.CustomerID,
		ServiceType: req.ServiceType,
		TotalAmount: req.TotalAmount,
	}
	
	// Save to database
	if err := s.repo.Save(ctx, order); err != nil {
		return nil, fmt.Errorf("failed to save order: %w", err)
	}
	
	return order, nil
}
```

#### Frontend (TypeScript)

**Formatting:**
```bash
cd frontend
npm run format      # Prettier auto-format
```

**Linting:**
```bash
npm run lint        # ESLint check
npm run lint:fix    # Auto-fix issues
```

**Code style guide:**
- Use TypeScript strict mode
- Functional components + hooks only
- Props interface for all components
- Custom hooks for reusable logic
- Type safety: no `any` types
- JSDoc comments for complex functions
- Max line length: 100 characters

**Example:**
```typescript
interface OrderFormProps {
  onSubmit: (data: CreateOrderRequest) => Promise<void>;
  isLoading?: boolean;
}

/**
 * Form for creating new car wash orders
 * Handles validation and submission
 */
export function OrderForm({ onSubmit, isLoading = false }: OrderFormProps) {
  const [error, setError] = useState<string | null>(null);
  
  const handleSubmit = async (data: CreateOrderRequest) => {
    try {
      await onSubmit(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
    </form>
  );
}
```

### 6. Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style (formatting, missing semicolons, etc)
- `refactor:` - Code restructuring without feature changes
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `chore:` - Build, dependencies, tooling

**Examples:**
```bash
# Feature
git commit -m "feat(orders): Add car wash order creation (US-004)"

# Bug fix
git commit -m "fix(payments): Correct decimal precision in amount calculation"

# Documentation
git commit -m "docs(api): Update order endpoints documentation"

# Test
git commit -m "test(services): Add unit tests for pricing service"

# Refactoring with body
git commit -m "refactor(repositories): Simplify customer queries

- Consolidate duplicate query logic
- Improve query performance with indexes
- Update related tests"
```

### 7. Before Committing

Run these checks locally:

```bash
# Backend
cd backend
go fmt ./...
golangci-lint run
go test -v ./... -cover

# Frontend
cd frontend
npm run format
npm run lint
npm run test:coverage

# Both
make lint
make format
```

### 8. Submit Pull Request

#### Create PR with Template

Use the GitHub PR template (`.github/PULL_REQUEST_TEMPLATE.md`):

```markdown
## Description
Brief summary of changes

## Related Issue/User Story
- Implements US-XXX: [User Story Title]
- Fixes #123

## Type of Change
- [x] New feature
- [ ] Bug fix
- [ ] Breaking change

## Changes Made
- Added order creation endpoint
- Implemented order validation
- Added unit tests

## Testing
- [x] Unit tests added (90% coverage)
- [x] Integration tests added
- [x] Manual testing completed

**Test Plan:**
1. Create new order with valid data
2. Verify order saved to database
3. Verify response contains order_id

## Checklist
- [x] Code follows style guidelines
- [x] Self-review completed
- [x] Tests added and passing
- [x] Documentation updated
```

#### PR Requirements

Before merging, ensure:
- ✅ All tests passing (unit, integration, E2E)
- ✅ Code coverage >80% (critical paths)
- ✅ Linting passes without errors
- ✅ Documentation updated
- ✅ No breaking changes (or documented)
- ✅ At least 1 peer review approval
- ✅ Conventional commit messages

## 🗂️ Project Structure Guidelines

### Backend (Go) Structure

```
backend/
├── app/
│   ├── handlers/           # HTTP handlers (controllers)
│   │   ├── order_handler.go
│   │   ├── customer_handler.go
│   │   └── payment_handler.go
│   ├── services/           # Business logic
│   │   ├── order_service.go
│   │   ├── pricing_service.go
│   │   └── payment_service.go
│   ├── repositories/       # Data access
│   │   ├── order_repo.go
│   │   ├── customer_repo.go
│   │   └── payment_repo.go
│   ├── models/             # Domain entities
│   │   ├── order.go
│   │   ├── customer.go
│   │   └── payment.go
│   ├── middleware/         # HTTP middleware
│   │   ├── auth.go
│   │   └── validation.go
│   ├── migrations/         # Database migrations
│   │   └── *.sql
│   ├── config/             # Configuration
│   │   └── config.go
│   └── main.go             # Entry point
└── tests/
    ├── handlers_test.go
    ├── services_test.go
    └── repositories_test.go
```

### Frontend (Next.js) Structure

```
frontend/src/
├── app/                    # Next.js App Router
│   ├── layout.tsx
│   ├── page.tsx
│   ├── dashboard/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── orders/
│   │       └── page.tsx
│   └── api/               # API routes (if needed)
├── components/            # React components
│   ├── ui/               # shadcn/ui components
│   ├── layout/           # Layout components
│   └── features/         # Feature components
├── services/             # API client
│   ├── orders.service.ts
│   └── customers.service.ts
├── hooks/                # Custom hooks
│   ├── useOrders.ts
│   └── useAuth.ts
├── stores/               # Zustand stores
│   ├── authStore.ts
│   └── orderStore.ts
├── types/                # TypeScript types
│   └── index.ts
└── utils/                # Utilities
    └── helpers.ts
```

## 📋 Checklist Before Merging

- [ ] Feature branch created from `main`
- [ ] Code follows style guidelines
- [ ] Self-review of code completed
- [ ] Tests written (unit + integration)
- [ ] Test coverage >80%
- [ ] All tests passing locally
- [ ] Linting passes (`make lint`)
- [ ] Code formatted (`make format`)
- [ ] Commit messages follow conventions
- [ ] PR description complete
- [ ] Documentation updated
- [ ] Related issues linked
- [ ] No merge conflicts
- [ ] At least 1 approval from team
- [ ] Squash commits before merge (if requested)

## 🚀 After Merge

1. **Monitor CI/CD:** Watch for test failures
2. **Deploy to Staging:** Manual deployment to test environment
3. **Run Integration Tests:** Full system testing
4. **Code Review Feedback:** Address any comments
5. **Documentation:** Update CHANGELOG if needed

## ❓ Questions?

- Check [REFERENCE.md](./REFERENCE.md) for documentation index
- Review existing similar code
- Ask in team discussions/standup
- Create an issue on GitHub for blockers

## 📚 Learning Resources

- [Golang Best Practices](https://golang.org/doc/effective_go)
- [Next.js Documentation](https://nextjs.org/docs)
- [React Hooks Guide](https://react.dev/reference/react)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GORM Documentation](https://gorm.io/docs/)

---

**Thank you for contributing to Kharisma Abadi V2!** 🎉
