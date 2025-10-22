# Data Flow Diagrams

**Project:** Kharisma Abadi v2
**Focus:** How data flows through key system operations

---

## Create Car Wash Order - Sequence Diagram

```mermaid
sequenceDiagram
    actor User as Cashier
    participant UI as Frontend
    participant API as Backend API
    participant Handler as Order Handler
    participant Service as Order Service
    participant Pricing as Pricing Service
    participant Repo as Order Repository
    participant DB as Database

    User->>UI: Enter order details
    UI->>UI: Validate form
    UI->>UI: Store in Pinia state
    
    User->>UI: Click "Create Order"
    UI->>API: POST /api/v1/orders (JSON)
    
    API->>Handler: Route to CreateOrder
    Handler->>Handler: Parse request
    Handler->>Handler: Validate DTO
    Handler->>Service: createOrder(request)
    
    Service->>Pricing: calculatePrice(type, package, addOns)
    Pricing-->>Service: {basePrice, tax, total}
    
    Service->>Service: Apply discount rules
    Service->>Service: Validate business rules
    Service->>Repo: save(order)
    
    Repo->>DB: INSERT INTO orders
    DB-->>Repo: order_id (auto-increment)
    Repo-->>Service: saved order with ID
    
    Service-->>Handler: Order entity
    Handler->>Handler: Format response
    Handler-->>API: 201 Created + JSON
    
    API-->>UI: Success response
    UI->>UI: Update Pinia store
    UI->>UI: Show success toast
    UI-->>User: Display receipt
```

---

## Payment Processing - Sequence Diagram

```mermaid
sequenceDiagram
    actor User as Cashier
    participant UI as Frontend
    participant API as Backend API
    participant PaymentService as Payment Service
    participant OrderRepo as Order Repository
    participant PaymentRepo as Payment Repository
    participant DB as Database
    participant SMS as SMS Gateway

    User->>UI: Select completed order
    UI->>API: GET /api/v1/orders/{id}
    API-->>UI: Order details
    
    User->>UI: Click "Collect Payment"
    UI->>UI: Show payment form
    User->>UI: Enter amount, method
    
    UI->>API: POST /api/v1/payments
    
    API->>PaymentService: processPayment(orderId, amount, method)
    
    PaymentService->>OrderRepo: getOrder(orderId)
    OrderRepo->>DB: SELECT FROM orders WHERE id=?
    DB-->>OrderRepo: Order record
    OrderRepo-->>PaymentService: Order entity
    
    PaymentService->>PaymentService: Validate amount == order total
    PaymentService->>PaymentService: Update order status to PAID
    
    PaymentService->>PaymentRepo: savePayment(payment)
    PaymentRepo->>DB: INSERT INTO payments
    DB-->>PaymentRepo: payment_id
    PaymentRepo-->>PaymentService: saved payment
    
    PaymentService->>OrderRepo: updateStatus(orderId, PAID)
    OrderRepo->>DB: UPDATE orders SET status=PAID
    DB-->>OrderRepo: success
    
    PaymentService->>SMS: sendPaymentReceipt(order, payment)
    SMS-->>PaymentService: SMS sent
    
    PaymentService-->>API: success response
    API-->>UI: 201 Created + payment data
    
    UI->>UI: Update state
    UI-->>User: Show receipt + confirmation
```

---

## Report Generation - Data Aggregation

```mermaid
sequenceDiagram
    actor User as Manager
    participant UI as Frontend
    participant API as Backend API
    participant ReportService as Report Service
    participant OrderRepo as Order Repository
    participant PaymentRepo as Payment Repository
    participant DB as Database

    User->>UI: Request "Daily Sales Report"
    UI->>UI: Show date picker
    User->>UI: Select date range
    
    UI->>API: GET /api/v1/reports/sales?start=DATE&end=DATE
    
    API->>ReportService: generateDailySalesReport(startDate, endDate)
    
    ReportService->>OrderRepo: findByDateRange(start, end)
    OrderRepo->>DB: SELECT * FROM orders WHERE created_at BETWEEN ? AND ?
    DB-->>OrderRepo: Order records (1000+)
    OrderRepo-->>ReportService: []Order
    
    ReportService->>PaymentRepo: findByDateRange(start, end)
    PaymentRepo->>DB: SELECT * FROM payments WHERE created_at BETWEEN ? AND ?
    DB-->>PaymentRepo: Payment records
    PaymentRepo-->>ReportService: []Payment
    
    ReportService->>ReportService: Aggregate by service type
    ReportService->>ReportService: Sum totals
    ReportService->>ReportService: Calculate metrics
    ReportService->>ReportService: Build report structure
    
    ReportService-->>API: Report JSON
    API-->>UI: Report data
    
    UI->>UI: Render charts
    UI->>UI: Display summary
    UI-->>User: Daily sales report
    
    User->>UI: Click "Export PDF"
    UI->>API: GET /api/v1/reports/sales/export?start=DATE&end=DATE
    API->>ReportService: exportPDF(report)
    ReportService-->>API: PDF binary
    API-->>UI: File download
    UI-->>User: PDF saved
```

---

## Update Order Status - State Machine

```mermaid
stateDiagram-v2
    [*] --> Pending
    
    Pending --> InProgress: Handler starts service
    Pending --> Cancelled: User cancels
    
    InProgress --> QualityCheck: Service completes initial work
    InProgress --> Cancelled: User cancels
    
    QualityCheck --> Completed: Quality verified
    QualityCheck --> InProgress: Issues found, back to service
    
    Completed --> AwaitingPayment: Order ready for payment
    
    AwaitingPayment --> Paid: Payment received
    AwaitingPayment --> Cancelled: Order cancelled
    
    Paid --> Closed: Order archived
    
    Cancelled --> [*]
    Closed --> [*]
    
    note right of Pending
        Order created, waiting for service to start
    end note
    
    note right of InProgress
        Service staff actively working on order
    end note
    
    note right of QualityCheck
        Quality assurance review
    end note
    
    note right of Completed
        Service finished, awaiting payment
    end note
    
    note right of Paid
        Payment collected, ready to close
    end note
```

---

## Data Transformation: Legacy to New Schema

```mermaid
graph LR
    subgraph "Legacy System"
        L_Emp[employees table<br/>100 records]
        L_CW_Cust[carwash_customers<br/>5000 records]
        L_Laun_Cust[laundry_customers<br/>4000 records]
        L_Water_Cust[water_customers<br/>3000 records]
        L_CW_Trans[carwash_transactions<br/>15000 records]
        L_Laun_Items[laundry_items<br/>12000 records]
        L_Water_Trans[water_transactions<br/>8000 records]
    end

    subgraph "Transformation"
        T1["employees → users<br/>(add roles, hash passwords)"]
        T2["carwash_cust + laun_cust +<br/>water_cust → customers<br/>(deduplicate by phone)"]
        T3["all transactions →<br/>orders (generate order_numbers)"]
        T4["orders → payments<br/>(create from completed)"]
    end

    subgraph "New System"
        N_Users[users<br/>100 records]
        N_Customers[customers<br/>10000 records<br/>deduplicated]
        N_Orders[orders<br/>35000 records]
        N_Payments[payments<br/>25000 records]
    end

    L_Emp --> T1 --> N_Users
    L_CW_Cust --> T2 --> N_Customers
    L_Laun_Cust --> T2 --> N_Customers
    L_Water_Cust --> T2 --> N_Customers
    L_CW_Trans --> T3 --> N_Orders
    L_Laun_Items --> T3 --> N_Orders
    L_Water_Trans --> T3 --> N_Orders
    N_Orders --> T4 --> N_Payments

    style T1 fill:#ffeb3b
    style T2 fill:#ffeb3b
    style T3 fill:#ffeb3b
    style T4 fill:#ffeb3b
```

---

## Notification Flow

```mermaid
graph TB
    subgraph "Event Triggers"
        E1[Order Created]
        E2[Order Completed]
        E3[Payment Received]
        E4[Service Issue]
    end

    subgraph "Notification Service"
        NS["Notification Service<br/>(Async goroutines)"]
    end

    subgraph "Message Formatting"
        MF["Format message<br/>templates"]
    end

    subgraph "Delivery Channels"
        SMS[SMS Gateway]
        Email[Email Service]
        Push[Push Notifications]
    end

    E1 --> NS
    E2 --> NS
    E3 --> NS
    E4 --> NS

    NS --> MF
    MF --> SMS
    MF --> Email
    MF --> Push

    SMS --> C["Customer Phone<br/>Receives SMS"]
    Email --> E["Customer Email<br/>Receives Email"]
    Push --> P["Mobile App<br/>Receives Push"]

    style NS fill:#4caf50,color:#fff
    style SMS fill:#2196f3,color:#fff
    style Email fill:#2196f3,color:#fff
    style Push fill:#2196f3,color:#fff
```

---

## API Request/Response Flow

```mermaid
graph TB
    subgraph "Client"
        A["JavaScript/Axios<br/>HTTP Request"]
    end

    subgraph "Network"
        B["HTTPS/TLS<br/>Port 443"]
    end

    subgraph "Server Stack"
        C["Fiber Router"]
        D["Middleware<br/>Auth, Validation"]
        E["Handler"]
        F["Service"]
        G["Repository"]
        H["Database"]
    end

    A -->|"POST /api/v1/orders<br/>Headers + Body"| B
    B --> C
    C --> D
    D -->|"Valid request<br/>with user context"| E
    E -->|"Call business logic"| F
    F -->|"Fetch/Save data"| G
    G -->|"SQL queries"| H
    H -->|"Database response"| G
    G -->|"Domain entities"| F
    F -->|"Result"| E
    E -->|"Format response"| C
    C -->|"201 Created"| B
    B -->|"JSON response<br/>Headers"| A

    style B fill:#4caf50,color:#fff
    style H fill:#f44336,color:#fff
```

---

## Cache Strategy

```mermaid
graph TB
    A["Request<br/>GET /api/v1/customers/1"]
    B["Check Redis Cache"]
    C{Found in<br/>Cache?}
    D["Return cached data<br/>Fast response"]
    E["Query database<br/>Slower"]
    F["Store in cache<br/>TTL: 1 hour"]
    G["Return data"]

    A --> B
    B --> C
    C -->|Yes| D
    C -->|No| E
    E --> F
    F --> G
    D --> G

    style D fill:#4caf50,color:#fff
    style E fill:#ff9800,color:#fff
```

---

## Error Handling Flow

```mermaid
graph TB
    A["Service Error<br/>occurs"]
    B["Create error<br/>with context"]
    C{"Error Type?"}
    D["Validation Error<br/>400 Bad Request"]
    E["Not Found<br/>404 Not Found"]
    F["Server Error<br/>500 Internal Error"]
    G["Log error details"]
    H["Alert monitoring"]
    I["Return error response"]
    J["Client receives error"]

    A --> B
    B --> C
    C -->|Input error| D
    C -->|Resource missing| E
    C -->|Unexpected error| F
    D --> G
    E --> G
    F --> G
    G --> H
    H --> I
    I --> J

    style G fill:#ffeb3b
    style H fill:#f44336,color:#fff
```

---

**These data flow diagrams illustrate how data moves through the Kharisma Abadi system for key operations.**
