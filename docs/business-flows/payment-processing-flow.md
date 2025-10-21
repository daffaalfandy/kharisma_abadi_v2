# Payment Processing Flow

**Status:** PARTIALLY IMPLEMENTED
**Gaps:** Payment method not tracked, no partial payment support, no accounts receivable
**Priority:** HIGH

---

## Current Payment Handling

### What Works
- Cashiers can collect payment (cash, bank transfer, e-wallet)
- Payment received before order completion
- Final_price stored in transaction

### What's Missing
- 🔴 No payment_method field tracked
- 🔴 No payment_status field
- 🔴 No partial payment support
- 🔴 No payment method validation
- 🔴 No payment timestamp
- 🔴 No accounts receivable tracking
- 🔴 No refund/reversal mechanism

---

## Proposed Payment Flow

```mermaid
flowchart TD
    Start([Order Complete\\nReady for Payment]) --> SelectMethod[Cashier selects\\npayment method]\n    \n    SelectMethod --> PaymentType{Payment\\nMethod?}\n    \n    PaymentType -->|Cash| CashPayment[Customer pays cash]\n    PaymentType -->|Transfer| TransferPayment[Customer transfers to\\nbusiness account]\n    PaymentType -->|E-Wallet| EWalletPayment[Customer pays via\\nOVO/GoPay/Dana]\n    PaymentType -->|Card| CardPayment[Customer pays with\\ndebit/credit card]\n    PaymentType -->|Invoice| InvoicePayment[Create monthly invoice]\n    \n    CashPayment --> VerifyAmount[Verify cash amount]\n    TransferPayment --> VerifyTransfer[Verify transfer received]\n    EWalletPayment --> VerifyWallet[Verify wallet payment]\n    CardPayment --> VerifyCard[Process card payment]\n    InvoicePayment --> CreateInvoice[Create invoice record]\n    \n    VerifyAmount --> PaymentOK{Payment\\nAmount\\nCorrect?}\n    VerifyTransfer --> PaymentOK\n    VerifyWallet --> PaymentOK\n    VerifyCard --> PaymentOK\n    CreateInvoice --> PaymentOK\n    \n    PaymentOK -->|No| RefundOrAdjust[Refund or adjust amount]\n    PaymentOK -->|Yes| RecordPayment[Record payment in database]\n    \n    RefundOrAdjust --> RecordPayment\n    \n    RecordPayment --> UpdateStatus[Set payment_status = PAID]\n    UpdateStatus --> PrintReceipt[Print receipt]\n    PrintReceipt --> UpdateCashDrawer[Update cash drawer\\nif cash payment]\n    UpdateCashDrawer --> UpdateIncome[Update dashboard income]\n    UpdateIncome --> End([Payment Complete])\n```

---

## Proposed Database Schema

### New Payment Table

```sql\nCREATE TABLE payments (\n  payment_id INT PRIMARY KEY AUTO_INCREMENT,\n  transaction_type ENUM('carwash', 'laundry', 'water') NOT NULL,\n  transaction_id INT NOT NULL,\n  amount BIGINT NOT NULL,\n  payment_method ENUM('CASH', 'TRANSFER', 'E_WALLET', 'CARD', 'CHECK') NOT NULL,\n  payment_status ENUM('PENDING', 'PAID', 'PARTIAL', 'REFUNDED', 'OVERDUE') DEFAULT 'PENDING',\n  paid_amount BIGINT DEFAULT 0,  -- For partial payments\n  payment_date DATETIME,  -- When payment received\n  due_date DATE,  -- For invoices\n  notes VARCHAR(255),\n  created_at DATETIME,\n  updated_at DATETIME,\n  INDEX idx_transaction (transaction_type, transaction_id),\n  INDEX idx_status (payment_status),\n  INDEX idx_date (payment_date)\n);\n```

### Updated Transaction Tables

```sql\nALTER TABLE carwash_transactions\nADD COLUMN payment_status ENUM('UNPAID', 'PARTIAL', 'PAID') DEFAULT 'UNPAID',\nADD COLUMN total_amount_due BIGINT NOT NULL DEFAULT final_price;\n\nALTER TABLE laundry_transactions\nADD COLUMN payment_status ENUM('UNPAID', 'PARTIAL', 'PAID') DEFAULT 'UNPAID',\nADD COLUMN total_amount_due BIGINT NOT NULL DEFAULT final_price;\n\nALTER TABLE drinking_water_transactions\nADD COLUMN payment_method ENUM('PREPAID', 'COD', 'INVOICE') DEFAULT 'COD',\nADD COLUMN payment_status ENUM('UNPAID', 'PARTIAL', 'PAID') DEFAULT 'UNPAID';\n```

---

## Payment Methods

### 1. Cash Payment

**Process:**
1. Customer provides cash
2. Cashier counts and verifies amount
3. Record payment as CASH
4. Update cash drawer
5. Give change if needed

**Tracking:**
- Amount received
- Timestamp
- Cashier who handled payment
- Change given

**Database:**
```sql\nINSERT INTO payments (\n    transaction_type, transaction_id,\n    amount, payment_method, payment_status, paid_amount,\n    payment_date, created_at\n) VALUES (\n    'carwash', 123,\n    50000, 'CASH', 'PAID', 50000,\n    NOW(), NOW()\n);\n```

**Cash Drawer Updates:**
```\nBefore: Rp 1,000,000\n+ Rp 50,000 (car wash payment)\n+ Rp 40,000 (laundry payment)\nAfter: Rp 1,090,000\n\nAt end of day: Count physical cash, reconcile with system\n```

---

### 2. Bank Transfer

**Process:**
1. Customer transfers to business account
2. Cashier verifies transfer receipt
3. Amount matches invoice
4. Record payment as TRANSFER
5. Note bank and timestamp

**Tracking:**
- Transfer amount
- Transfer timestamp
- Bank account used
- Transfer reference number

**Database:**
```sql\nINSERT INTO payments (\n    transaction_type, transaction_id,\n    amount, payment_method, payment_status, paid_amount,\n    payment_date, notes, created_at\n) VALUES (\n    'laundry', 456,\n    150000, 'TRANSFER', 'PAID', 150000,\n    NOW(), 'Transfer via BCA, Ref: 2025101212345', NOW()\n);\n```

**Reconciliation:**
- Daily bank statement review
- Match transfers to invoices
- Identify unmatched transfers
- Update pending payments when confirmed

---

### 3. E-Wallet Payment (OVO, GoPay, Dana)

**Process:**
1. Customer opens e-wallet app
2. Scans QR code or enters merchant ID
3. Confirms and submits payment
4. Cashier verifies payment notification
5. Record payment as E_WALLET

**Tracking:**
- E-wallet type (OVO, GoPay, Dana)
- Transaction ID from e-wallet provider
- Timestamp
- Status

**Database:**
```sql\nINSERT INTO payments (\n    transaction_type, transaction_id,\n    amount, payment_method, payment_status, paid_amount,\n    payment_date, notes, created_at\n) VALUES (\n    'carwash', 789,\n    75000, 'E_WALLET', 'PAID', 75000,\n    NOW(), 'GoPay Ref: TXN001234567890', NOW()\n);\n```

**Settlement:**
- Daily/weekly settlement from e-wallet provider
- Deduction of fees (typically 2-3%)
- Separate accounting for net vs gross

---

### 4. Credit/Debit Card

**Process:**
1. Customer provides card
2. POS terminal processes payment
3. Receipt printed from terminal
4. Record payment as CARD
5. Magnetic stripe or chip read (if terminal available)

**Tracking:**
- Card type (Visa, Mastercard, etc.)
- Last 4 digits
- Transaction reference
- Approval code

**Database:**
```sql\nINSERT INTO payments (\n    transaction_type, transaction_id,\n    amount, payment_method, payment_status, paid_amount,\n    payment_date, notes, created_at\n) VALUES (\n    'carwash', 321,\n    100000, 'CARD', 'PAID', 100000,\n    NOW(), 'Visa ****1234, Auth: ABC123456', NOW()\n);\n```

**Note:** Current system may not have card processor integration.

---

### 5. Invoice (Monthly Billing)

**Process:**
1. Water delivery subscription customer
2. Multiple deliveries during month
3. Create invoice at month-end
4. Send to customer
5. Payment due within 30 days

**Tracking:**
- Invoice number
- Invoice date
- Due date
- Line items (deliveries)
- Total amount

**Database:**
```sql\nINSERT INTO payments (\n    transaction_type, transaction_id,\n    amount, payment_method, payment_status, paid_amount,\n    payment_date, due_date, notes, created_at\n) VALUES (\n    'water', NULL,  -- Multiple transactions\n    2000000, 'INVOICE', 'PENDING', 0,\n    NULL, '2025-11-22', 'Invoice INV-2025-10-456', NOW()\n);\n```

**Invoice Items:**
- Delivery 1: Oct 1, 2 gallons, Rp 40,000\n- Delivery 2: Oct 8, 2 gallons, Rp 40,000\n- Delivery 3: Oct 15, 2 gallons, Rp 40,000\n- ... (up to 4-5 deliveries)\n- **Total:** Rp 2,000,000 (approx)

---

## Partial Payment Support

### Scenario: Laundry with Deposit

**Current System:**
- Full payment or no payment
- Cannot record partial payment

**Proposed System:**
```python\n# Customer brings laundry, requests to pay half now, half at pickup\ndeposit = 75000  # 50% of Rp 150,000\n\npayment_1 = {\n    'transaction_id': 456,\n    'amount': 150000,\n    'payment_method': 'CASH',\n    'payment_status': 'PARTIAL',\n    'paid_amount': 75000,\n    'remaining': 75000,\n    'payment_date': NOW()\n}\n\n# At pickup:\npayment_2 = {\n    'transaction_id': 456,\n    'amount': 75000,\n    'payment_method': 'CASH',\n    'payment_status': 'PAID',\n    'paid_amount': 75000,\n    'remaining': 0,\n    'payment_date': NOW()\n}\n```

**Database:**
```sql\n-- Record first payment\nUPDATE carwash_transactions\nSET payment_status = 'PARTIAL', total_amount_paid = 75000\nWHERE carwash_transaction_id = 456;\n\n-- At second payment\nUPDATE carwash_transactions\nSET payment_status = 'PAID', total_amount_paid = 150000\nWHERE carwash_transaction_id = 456;\n```

---

## Accounts Receivable Tracking

### Invoice Aging Report

```\nInvoice   Customer          Amount    Days Due    Status\n--------  -----------       ---------  ----------  --------\nINV-001   PT Maju Jaya      2,000,000     5       Current\nINV-002   Budi Hartono      150,000       35      OVERDUE (5 days)\nINV-003   Rina Putri        200,000       60      OVERDUE (30 days)\nINV-004   PT Jaya Sentosa   5,000,000     90      OVERDUE (60 days!)\n\nTotal Outstanding: Rp 7,350,000\nTotal Overdue: Rp 5,350,000\n```

**Query:**
```sql\nSELECT \n    p.payment_id,\n    p.amount,\n    DATEDIFF(CURDATE(), p.due_date) as days_overdue,\n    CASE \n        WHEN p.payment_status = 'PAID' THEN 'Paid'\n        WHEN DATEDIFF(CURDATE(), p.due_date) > 0 THEN 'Overdue'\n        ELSE 'Current'\n    END as status\nFROM payments p\nWHERE p.payment_method = 'INVOICE'\nAND p.payment_status IN ('PENDING', 'PARTIAL')\nORDER BY p.due_date ASC;\n```

---

## Refund Processing

### Refund Scenarios

**Reason 1: Customer Dissatisfied with Service**
```\nTransaction: Carpet washing - Rp 600,000\nIssue: Stain not fully removed\nResolution: Full refund\n\nRefund Process:\n1. Document issue with photos\n2. Manager approves refund\n3. Record refund in payments table\n4. Update transaction payment_status = 'REFUNDED'\n5. Reverse income in dashboard\n6. Return cash or credit to customer\n```

**Reason 2: Overcharge**
```\nTransaction: Car wash - Charged Rp 75,000, should be Rp 50,000\nRefund amount: Rp 25,000\n\nPayment Status: Partial refund\n```

**Reason 3: Cancelled Order**
```\nTransaction: Laundry ordered, not picked up, customer cancels\nRefund: Full amount\nRefund Status: Cancelled order\n```

**Database:**
```sql\nINSERT INTO payments (\n    transaction_type, transaction_id,\n    amount, payment_method, payment_status, paid_amount,\n    payment_date, notes, created_at\n) VALUES (\n    'carwash', 123,\n    -50000,  -- Negative amount for refund\n    'CASH',\n    'PAID',\n    -50000,\n    NOW(),\n    'Refund - Customer dissatisfied with service quality',\n    NOW()\n);\n```

---

## Cash Drawer Management

### Opening Balance

```\nDate: 2025-10-22\nOpening Time: 08:00 AM\nOpening Balance: Rp 500,000 (starting float)\n```

### Transactions During Day

```\n08:15  +Rp 50,000   Car wash payment\n08:45  +Rp 40,000   Laundry deposit\n09:30  -Rp 10,000   Petty cash for supplies\n10:00  +Rp 75,000   Water delivery payment\n...\nDay Total: +Rp 347,000\n```

### Closing Balance

```\nClosing Time: 05:00 PM\nExpected Balance: Rp 500,000 + Rp 347,000 = Rp 847,000\nPhysical Count: Rp 847,000\nDifference: Rp 0 (matches)\nStatus: ✅ Balanced\n```

### Variance Handling

```\nExpected: Rp 847,000\nPhysical Count: Rp 846,500\nVariance: Rp 500 (missing)\n\nInvestigation:\n- Check receipt accuracy\n- Recount physical cash\n- Check for data entry errors\n- Document variance in reconciliation report\n\nIf variance > Rp 10,000:\n- Escalate to manager\n- Investigate more thoroughly\n- May indicate errors or theft\n```

---

## Missing Functionality to Implement

### Priority 1: Critical
1. Payment method tracking (CASH, TRANSFER, E_WALLET, CARD, INVOICE)
2. Payment status tracking (PENDING, PARTIAL, PAID, OVERDUE, REFUNDED)
3. Payment timestamp
4. Partial payment support
5. Refund mechanism

### Priority 2: Important
6. Accounts receivable aging reports
7. Cash drawer reconciliation
8. Invoice generation for monthly billing
9. Payment reminders for overdue invoices
10. Audit trail of payment changes

### Priority 3: Nice to Have
11. Payment gateway integration (credit card processing)
12. Automated payment notifications (SMS/email)
13. Payment history per customer
14. Multi-currency support
15. Foreign exchange tracking

---

## Implementation Roadmap

**Phase 1 (Week 1):** Add payment tracking fields
- Add payment table
- Add payment_status to transaction tables
- Create payment recording API endpoints

**Phase 2 (Week 2):** Implement partial payments
- Update payment processing logic
- Add remaining balance calculation
- Handle multiple payment records per transaction

**Phase 3 (Week 3):** Add reporting
- A/R aging reports
- Cash drawer reconciliation
- Payment method analysis

**Phase 4 (Week 4):** Integration
- Connect dashboard to payment data
- Add payment reminders
- Implement refund workflow

---

## Conclusion

Current payment handling is **MINIMAL** - only records that payment was made. Missing sophisticated features needed for:
- Financial management
- Accounts receivable
- Refund handling
- Cash reconciliation
- Multi-method support

---

**Priority:** HIGH - Implement in Phase 2 of redesign
**Estimated Effort:** 3-4 weeks
**Related:** authentication-flow.md, reporting-flow.md
