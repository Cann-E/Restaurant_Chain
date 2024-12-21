require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const path = require('path');

// Import routes
const menuRoutes = require('./menuRoutes');
const customerRoutes = require('./customerRoutes');
const franchiseRoutes = require('./franchiseRoutes'); //franchiseRoutes

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Attach the pool to the request object for use in routes
app.use((req, res, next) => {
  req.pool = pool;
  next();
});

// Middleware for JSON parsing
app.use(express.json());

// Serve static files from the "public" directory
app.use(express.static(path.join(__dirname, 'public')));

app.use('/api/franchises', franchiseRoutes);
app.get('/franchises.html', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'franchises.html'));
});

// Route handlers
app.use('/api/menu', menuRoutes);
app.use('/api/customers', customerRoutes);

// Static routes for frontend files
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'homepage.html'));
});
app.get('/dashboard.html', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});
app.get('/menu-items.html', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'menu-items.html'));
});
app.get('/transactions.html', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'transactions.html'));
});
app.get('/customers.html', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'customers.html'));
});

// API Routes

app.get('/api/franchises/test', async (req, res) => {
  try {
      const query = `
          SELECT 
              id,
              "City" as city,
              "State" as state,
              address,
              zip,
              (
                  SELECT COUNT(*)
                  FROM orders o
                  WHERE o."Franchise_id" = f.id
              ) as total_orders
          FROM franchise f
          ORDER BY "City"
      `;
      const result = await pool.query(query);
      res.json(result.rows);
  } catch (error) {
      console.error('Error fetching franchises:', error);
      res.status(500).json({ 
          error: 'Failed to fetch franchises',
          details: error.message 
      });
  }
});

// Fetch all customers
app.get('/api/customers', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT user_id, username, email, phone_number, member, "First_name", "Last_name"
      FROM customer
      ORDER BY "Last_name", "First_name"
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching customer details:', error);
    res.status(500).json({ error: 'Failed to fetch customer details' });
  }
});

// Add a new transaction
app.post('/api/transaction', async (req, res) => {
  const { cust_id, payment_id, cash, amount, order_id } = req.body;
  try {
    await pool.query('BEGIN');

    // Create transaction record
    await pool.query(
      `INSERT INTO transactions (payment_id, cash, amount, order_id, cust_id) 
       VALUES ($1, $2, $3, $4, $5)`,
      [payment_id, cash, amount, order_id, cust_id]
    );

    // Update order status
    await pool.query(
      `UPDATE orders SET status = 'completed' WHERE id = $1`,
      [order_id]
    );

    await pool.query('COMMIT');
    res.status(201).json({ message: 'Transaction completed successfully' });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Transaction error:', error);
    res.status(500).json({ error: 'Transaction failed', details: error.message });
  }
});

// Fetch all transactions
app.get('/api/transactions', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT t.transaction_id, t.payment_id, t.cash, t.amount, t.order_id, t.cust_id,
             t.created_at, c.username, c.email
      FROM transactions t
      JOIN customer c ON c.user_id = t.cust_id
      ORDER BY t.created_at DESC
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

// Fetch all orders
app.get('/api/orders', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT o.id as order_id, o.order_date, o.total_amount, o.status,
             f."City" as franchise_city, f."State" as franchise_state
      FROM orders o
      JOIN franchise f ON o."Franchise_id" = f.id
      ORDER BY o.order_date DESC
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// Fetch menu items with prices
app.get('/api/menu-items', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT mi.menu_item_id, mi.item_name, mi.type_of_menu_item, 
             mi.quantity, p.price
      FROM menu_item mi
      JOIN pricing p ON mi.menu_item_id = p.menu_item_id
      ORDER BY mi.type_of_menu_item, mi.item_name
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching menu items:', error);
    res.status(500).json({ error: 'Failed to fetch menu items' });
  }
});

// Add this to your index.js file

app.post('/api/orders', async (req, res) => {
  const { customer_id, franchise_id, menu_items, total_amount, payment_method } = req.body;

  console.log('Received order data:', {
    customer_id,
    franchise_id,
    menu_items,
    total_amount,
    payment_method
  });

  try {
    await pool.query('BEGIN');

    // Create order
    const orderResult = await pool.query(
      `INSERT INTO orders ("Franchise_id", total_amount, status)
       VALUES ($1, $2, 'pending')
       RETURNING id`,
      [franchise_id, total_amount]
    );
    const orderId = orderResult.rows[0].id;

    // Insert order items
    for (const item of menu_items) {
      await pool.query(
        'INSERT INTO order_items (order_id, menu_item_id, quantity) VALUES ($1, $2, $3)',
        [orderId, item.menu_item_id, item.quantity]
      );
    }

    let paymentId = null;
    if (payment_method === 'credit') {
      // For credit payments, first create a payment card record with a generated ID
      const cardResult = await pool.query(
        `INSERT INTO payment_cards (id, user_id, card_num, date_exp)
         VALUES (COALESCE((SELECT MAX(id) + 1 FROM payment_cards), 1), $1, $2, $3)
         RETURNING id`,
        [customer_id, '0000000000000000', '0000'] // Placeholder card details
      );

      // Then create a payment record
      const paymentResult = await pool.query(
        `INSERT INTO payments (payment_id, card_id, amount, cust_id)
         VALUES (COALESCE((SELECT MAX(payment_id) + 1 FROM payments), 1), $1, $2, $3)
         RETURNING payment_id`,
        [cardResult.rows[0].id, total_amount, customer_id]
      );
      
      paymentId = paymentResult.rows[0].payment_id;
    }

    // Create transaction
    await pool.query(
      `INSERT INTO transactions (order_id, cust_id, amount, cash, payment_id)
       VALUES ($1, $2, $3, $4, $5)`,
      [orderId, customer_id, total_amount, payment_method === 'cash', paymentId]
    );

    await pool.query('COMMIT');
    res.status(201).json({
      message: 'Order created successfully',
      orderId
    });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Error creating order:', error);
    res.status(500).json({
      error: 'Failed to create order',
      details: error.message,
      data: {
        received_menu_items: menu_items
      }
    });
  }
});
// Fetch menu categories
app.get('/api/menu-categories', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT DISTINCT type_of_menu_item
      FROM menu_item
      ORDER BY type_of_menu_item
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching menu categories:', error);
    res.status(500).json({ error: 'Failed to fetch menu categories' });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
