const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Seed data
const initialUserData = {
  id: "USR10001",
  name: "Demo User",
  email: "demo@jstack.co",
  phone: "+91 98765 43210",
  walletId: "WALLET10001",
  currency: "INR",
  maskedAccountNumber: "XXXX XXXX 4589"
};

const initialBalance = 25450.75;

const initialTransactions = [
  {
    id: "TXN10001",
    type: "DEBIT",
    amount: 1500.00,
    currency: "INR",
    beneficiaryName: "Rahul Sharma",
    mobileNumber: "9876543210",
    status: "SUCCESS",
    createdAt: "2026-10-20T10:30:00Z",
    remarks: "Payment for services"
  },
  {
    id: "TXN10002",
    type: "CREDIT",
    amount: 5000.00,
    currency: "INR",
    beneficiaryName: "Amit Kumar",
    mobileNumber: "9811223344",
    status: "SUCCESS",
    createdAt: "2026-10-19T14:15:00Z",
    remarks: "Freelance design payout"
  },
  {
    id: "TXN10003",
    type: "DEBIT",
    amount: 320.50,
    currency: "INR",
    beneficiaryName: "Swiggy Food",
    mobileNumber: "9876500001",
    status: "SUCCESS",
    createdAt: "2026-10-18T19:40:00Z",
    remarks: "Dinner order"
  },
  {
    id: "TXN10004",
    type: "DEBIT",
    amount: 2199.00,
    currency: "INR",
    beneficiaryName: "Amazon India",
    mobileNumber: "9876500002",
    status: "SUCCESS",
    createdAt: "2026-10-17T11:20:00Z",
    remarks: "Electronics purchase"
  },
  {
    id: "TXN10005",
    type: "CREDIT",
    amount: 15000.00,
    currency: "INR",
    beneficiaryName: "Salary Credit - jStack",
    mobileNumber: "9876500003",
    status: "SUCCESS",
    createdAt: "2026-10-15T09:00:00Z",
    remarks: "Monthly allowance"
  },
  {
    id: "TXN10006",
    type: "DEBIT",
    amount: 850.00,
    currency: "INR",
    beneficiaryName: "Priya Verma",
    mobileNumber: "9823456789",
    status: "SUCCESS",
    createdAt: "2026-10-14T16:10:00Z",
    remarks: "Movie tickets sharing"
  },
  {
    id: "TXN10007",
    type: "DEBIT",
    amount: 450.00,
    currency: "INR",
    beneficiaryName: "Uber Rides",
    mobileNumber: "9876500004",
    status: "SUCCESS",
    createdAt: "2026-10-13T08:35:00Z",
    remarks: "Commute to office"
  },
  {
    id: "TXN10008",
    type: "CREDIT",
    amount: 1200.00,
    currency: "INR",
    beneficiaryName: "Cashback Reward",
    mobileNumber: "9876500000",
    status: "SUCCESS",
    createdAt: "2026-10-12T13:00:00Z",
    remarks: "Festival promotion cashback"
  },
  {
    id: "TXN10009",
    type: "DEBIT",
    amount: 1999.00,
    currency: "INR",
    beneficiaryName: "Airtel Broadband",
    mobileNumber: "9898989898",
    status: "SUCCESS",
    createdAt: "2026-10-10T17:45:00Z",
    remarks: "Fiber bill payment"
  },
  {
    id: "TXN10010",
    type: "DEBIT",
    amount: 650.00,
    currency: "INR",
    beneficiaryName: "Zomato",
    mobileNumber: "9876500005",
    status: "SUCCESS",
    createdAt: "2026-10-09T20:15:00Z",
    remarks: "Team snacks"
  },
  {
    id: "TXN10011",
    type: "CREDIT",
    amount: 3500.00,
    currency: "INR",
    beneficiaryName: "Neha Gupta",
    mobileNumber: "9765432100",
    status: "SUCCESS",
    createdAt: "2026-10-08T12:00:00Z",
    remarks: "Split trip expenses"
  }
];

// In-memory state
let user = { ...initialUserData };
let availableBalance = initialBalance;
let transactions = JSON.parse(JSON.stringify(initialTransactions));
let transactionCounter = 10012;
const idempotencyStore = new Map();

// Helper error response
function sendError(res, status, message, errorCode) {
  return res.status(status).json({
    success: false,
    message,
    errorCode
  });
}

// Authentication middleware
function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return sendError(res, 401, 'Invalid or missing authentication token', 'AUTH_UNAUTHORIZED');
  }
  const token = authHeader.split(' ')[1];
  if (!token || token.trim() === '') {
    return sendError(res, 401, 'Invalid or missing authentication token', 'AUTH_UNAUTHORIZED');
  }
  // Accept mock token
  req.user = user;
  next();
}

// Routes

// 1. Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'jWallet Lite Mock API' });
});

// 2. Login
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return sendError(res, 400, 'Email and password are required', 'VALIDATION_ERROR');
  }

  if (email === 'demo@jstack.co' && password === 'Demo@123') {
    return res.status(200).json({
      success: true,
      data: {
        accessToken: "mock_access_token_123",
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        }
      }
    });
  }

  return sendError(res, 401, 'Invalid email or password', 'AUTH_INVALID_CREDENTIALS');
});

// 3. User Profile
app.get('/api/v1/users/profile', authMiddleware, (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      walletId: user.walletId,
      currency: user.currency,
      accountNumber: user.maskedAccountNumber
    }
  });
});

// 4. Wallet Balance
app.get('/api/v1/wallet/balance', authMiddleware, (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      walletId: user.walletId,
      currency: user.currency,
      availableBalance: parseFloat(availableBalance.toFixed(2)),
      maskedAccountNumber: user.maskedAccountNumber
    }
  });
});

// 5. Transaction History
app.get('/api/v1/transactions', authMiddleware, (req, res) => {
  let result = [...transactions];

  // Optional filter by type (CREDIT / DEBIT)
  if (req.query.type) {
    const filterType = req.query.type.toUpperCase();
    result = result.filter(t => t.type === filterType);
  }

  // Optional search by beneficiary name or transaction ID
  if (req.query.search) {
    const search = req.query.search.toLowerCase();
    result = result.filter(t => 
      t.beneficiaryName.toLowerCase().includes(search) || 
      t.id.toLowerCase().includes(search)
    );
  }

  // Sort descending by createdAt
  result.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  return res.status(200).json({
    success: true,
    data: result
  });
});

// 6. Transaction Details
app.get('/api/v1/transactions/:id', authMiddleware, (req, res) => {
  const { id } = req.params;
  const transaction = transactions.find(t => t.id === id);

  if (!transaction) {
    return sendError(res, 404, 'Transaction not found', 'TRANSACTION_NOT_FOUND');
  }

  return res.status(200).json({
    success: true,
    data: transaction
  });
});

// 7. Money Transfer
app.post('/api/v1/transactions/transfer', authMiddleware, (req, res) => {
  const { beneficiaryName, mobileNumber, amount, remarks } = req.body || {};
  const idempotencyKey = req.headers['idempotency-key'];

  // Check Idempotency Key
  if (idempotencyKey && idempotencyStore.has(idempotencyKey)) {
    const cached = idempotencyStore.get(idempotencyKey);
    console.log(`[IDEMPOTENCY] Replay response for key: ${idempotencyKey}`);
    return res.status(cached.statusCode).json(cached.body);
  }

  // Validation: empty mandatory fields
  if (!beneficiaryName || typeof beneficiaryName !== 'string' || beneficiaryName.trim().length === 0) {
    return sendError(res, 400, 'Beneficiary name is required', 'VALIDATION_ERROR');
  }

  // Validation: 10-digit mobile number
  const mobileClean = String(mobileNumber || '').trim();
  const mobileRegex = /^[6-9]\d{9}$/;
  if (!mobileRegex.test(mobileClean)) {
    return sendError(res, 400, 'Invalid beneficiary mobile number. Must be a 10-digit mobile number.', 'INVALID_MOBILE');
  }

  // Validation: amount > 0
  const parsedAmount = parseFloat(amount);
  if (isNaN(parsedAmount) || parsedAmount <= 0) {
    return sendError(res, 400, 'Transfer amount must be greater than zero', 'INVALID_AMOUNT');
  }

  // Business Rule: Check wallet balance
  if (parsedAmount > availableBalance) {
    const errorResponse = {
      statusCode: 409,
      body: {
        success: false,
        message: 'Insufficient wallet balance',
        errorCode: 'INSUFFICIENT_FUNDS'
      }
    };
    if (idempotencyKey) {
      idempotencyStore.set(idempotencyKey, errorResponse);
    }
    return sendError(res, 409, 'Insufficient wallet balance', 'INSUFFICIENT_FUNDS');
  }

  // Deduct balance
  availableBalance = parseFloat((availableBalance - parsedAmount).toFixed(2));

  // Generate unique transaction ID
  const txnId = `TXN${transactionCounter++}`;
  const newTransaction = {
    id: txnId,
    type: "DEBIT",
    amount: parsedAmount,
    currency: user.currency,
    beneficiaryName: beneficiaryName.trim(),
    mobileNumber: mobileClean,
    status: "SUCCESS",
    createdAt: new Date().toISOString(),
    remarks: remarks ? remarks.trim() : "Money Transfer"
  };

  transactions.unshift(newTransaction);

  const responseBody = {
    success: true,
    data: {
      transactionId: txnId,
      status: "SUCCESS",
      amount: parsedAmount,
      currency: user.currency,
      availableBalance: availableBalance,
      beneficiaryName: newTransaction.beneficiaryName,
      createdAt: newTransaction.createdAt
    }
  };

  if (idempotencyKey) {
    idempotencyStore.set(idempotencyKey, {
      statusCode: 200,
      body: responseBody
    });
  }

  return res.status(200).json(responseBody);
});

// 8. Reset state (utility)
app.post('/api/v1/wallet/reset', (req, res) => {
  availableBalance = initialBalance;
  transactions = JSON.parse(JSON.stringify(initialTransactions));
  idempotencyStore.clear();
  return res.status(200).json({
    success: true,
    message: 'Wallet reset successfully to initial state',
    availableBalance
  });
});

// Fallback 404
app.use((req, res) => {
  sendError(res, 404, 'Endpoint not found', 'NOT_FOUND');
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err);
  sendError(res, 500, 'Internal server error', 'SERVER_ERROR');
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`===============================================`);
  console.log(` jWallet Lite Mock REST API is running!`);
  console.log(` Base URL: http://localhost:${PORT}`);
  console.log(`===============================================`);
});
