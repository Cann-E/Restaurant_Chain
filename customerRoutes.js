const express = require('express');
const router = express.Router();

// Get all customers
router.get('/', async (req, res) => {
  try {
    const result = await req.pool.query(`
      SELECT user_id, username, email, phone_number, member, 
             "First_name", "Last_name"
      FROM customer
      ORDER BY "Last_name", "First_name"
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching customers:', error);
    res.status(500).json({ error: 'Failed to fetch customers' });
  }
});

// Get a specific customer by ID with their payment cards and orders
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    // Fetch customer details
    const customerResult = await req.pool.query(`
      SELECT user_id, username, email, phone_number, member, 
             "First_name", "Last_name"
      FROM customer 
      WHERE user_id = $1
    `, [id]);

    if (customerResult.rows.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }

    // Fetch customer's payment cards
    const paymentCardsResult = await req.pool.query(`
      SELECT id, card_num, date_exp, bank 
      FROM payment_cards 
      WHERE user_id = $1
    `, [id]);

    // Fetch customer's orders
    const ordersResult = await req.pool.query(`
      SELECT o.id, o.order_date, o.total_amount, o.status,
             f."City" as franchise_city, f."State" as franchise_state
      FROM orders o
      JOIN franchise f ON o."Franchise_id" = f.id
      WHERE o.id IN (
        SELECT order_id 
        FROM transactions 
        WHERE cust_id = $1
      )
      ORDER BY o.order_date DESC
    `, [id]);

    const customerData = {
      ...customerResult.rows[0],
      payment_cards: paymentCardsResult.rows,
      orders: ordersResult.rows,
    };

    res.status(200).json(customerData);
  } catch (error) {
    console.error('Error fetching customer details:', error);
    res.status(500).json({ error: 'Failed to fetch customer details' });
  }
});

// Create a new customer
router.post('/', async (req, res) => {
  const { username, email, phone_number, member, first_name, last_name, paymentMethod, creditCard } = req.body;

  try {
    // Validate email format
    const emailRegex = /^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    // Validate phone number format
    const phoneRegex = /^\+?[1-9]\d{1,19}$/;
    if (!phoneRegex.test(phone_number)) {
      return res.status(400).json({ error: 'Invalid phone number format' });
    }

    // Insert new customer with credit card handling
    const result = await req.pool.query(`
      INSERT INTO customer (username, email, phone_number, member, "First_name", "Last_name", credit_card_number)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING user_id, username, email, phone_number, member, "First_name", "Last_name", credit_card_number
    `, [
      username,
      email,
      phone_number,
      member,
      first_name,
      last_name,
      paymentMethod === 'credit' ? creditCard : null, // Add credit card only if paymentMethod is 'credit'
    ]);

    res.status(201).json({ message: 'Customer created successfully', customer: result.rows[0] });
  } catch (error) {
    console.error('Error creating customer:', error);

    // Handle unique constraint violation for email
    if (error.constraint === 'unique_email') {
      return res.status(400).json({ error: 'Email already exists' });
    }

    res.status(500).json({ error: 'Failed to create customer' });
  }
});


// Update a customer
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { username, email, phone_number, member, first_name, last_name } = req.body;

  try {
    // Validate email format
    const emailRegex = /^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    // Validate phone number format
    const phoneRegex = /^\+?[1-9]\d{1,19}$/;
    if (!phoneRegex.test(phone_number)) {
      return res.status(400).json({ error: 'Invalid phone number format' });
    }

    // Update customer
    const result = await req.pool.query(`
      UPDATE customer 
      SET username = $1, email = $2, phone_number = $3, 
          member = $4, "First_name" = $5, "Last_name" = $6
      WHERE user_id = $7
      RETURNING user_id, username, email, phone_number, member, "First_name", "Last_name"
    `, [username, email, phone_number, member, first_name, last_name, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }

    res.status(200).json({ message: 'Customer updated successfully', customer: result.rows[0] });
  } catch (error) {
    console.error('Error updating customer:', error);
    if (error.constraint === 'unique_email') {
      return res.status(400).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: 'Failed to update customer' });
  }
});

// Delete a customer
router.delete('/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await req.pool.query(`
      DELETE FROM customer 
      WHERE user_id = $1
      RETURNING user_id
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }

    res.status(200).json({ message: 'Customer deleted successfully' });
  } catch (error) {
    console.error('Error deleting customer:', error);
    res.status(500).json({ error: 'Failed to delete customer' });
  }
});

module.exports = router;
