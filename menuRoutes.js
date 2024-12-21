const express = require('express');
const router = express.Router();

// GET all menu items with prices
router.get('/menu-items', async (req, res) => {
  try {
    const result = await req.pool.query(`
      SELECT mi.menu_item_id, mi.item_name, mi.type_of_menu_item, 
             mi.quantity, p.price
      FROM menu_item mi
      JOIN pricing p ON mi.menu_item_id = p.menu_item_id
      ORDER BY mi.type_of_menu_item, mi.item_name
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching menu items:', error);
    res.status(500).json({ error: 'Failed to fetch menu items' });
  }
});



// POST a new menu item with price
router.post('/menu-items', async (req, res) => {
  const { item_name, type_of_menu_item, quantity, price } = req.body;
  
  try {
    await req.pool.query('BEGIN');

    // Insert into menu_item first
    const menuItemResult = await req.pool.query(
      'INSERT INTO menu_item (item_name, type_of_menu_item, quantity) VALUES ($1, $2, $3) RETURNING menu_item_id',
      [item_name, type_of_menu_item, quantity]
    );

    // Insert the price into pricing table
    await req.pool.query(
      'INSERT INTO pricing (menu_item_id, price) VALUES ($1, $2)',
      [menuItemResult.rows[0].menu_item_id, price]
    );

    // Fetch the complete item with price
    const finalResult = await req.pool.query(`
      SELECT mi.menu_item_id, mi.item_name, mi.type_of_menu_item, 
             mi.quantity, p.price
      FROM menu_item mi
      JOIN pricing p ON mi.menu_item_id = p.menu_item_id
      WHERE mi.menu_item_id = $1
    `, [menuItemResult.rows[0].menu_item_id]);

    await req.pool.query('COMMIT');
    res.status(201).json(finalResult.rows[0]);
  } catch (error) {
    await req.pool.query('ROLLBACK');
    console.error('Error adding menu item:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// PUT to update a menu item and its price
router.put('/menu-items/:id', async (req, res) => {
  const { id } = req.params;
  const { item_name, type_of_menu_item, quantity, price } = req.body;

  try {
    await req.pool.query('BEGIN');

    // Update menu_item table
    const menuItemResult = await req.pool.query(
      'UPDATE menu_item SET item_name = $1, type_of_menu_item = $2, quantity = $3 WHERE menu_item_id = $4 RETURNING *',
      [item_name, type_of_menu_item, quantity, id]
    );

    if (menuItemResult.rows.length === 0) {
      await req.pool.query('ROLLBACK');
      return res.status(404).json({ error: 'Menu item not found' });
    }

    // Update price in pricing table
    await req.pool.query(
      'UPDATE pricing SET price = $1 WHERE menu_item_id = $2',
      [price, id]
    );

    // Fetch updated item with price
    const finalResult = await req.pool.query(`
      SELECT mi.menu_item_id, mi.item_name, mi.type_of_menu_item, 
             mi.quantity, p.price
      FROM menu_item mi
      JOIN pricing p ON mi.menu_item_id = p.menu_item_id
      WHERE mi.menu_item_id = $1
    `, [id]);

    await req.pool.query('COMMIT');
    res.json(finalResult.rows[0]);
  } catch (error) {
    await req.pool.query('ROLLBACK');
    console.error('Error updating menu item:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// DELETE a menu item and its price
router.delete('/menu-items/:id', async (req, res) => {
  const { id } = req.params;
  
  try {
    await req.pool.query('BEGIN');

    // Delete from pricing first (due to foreign key constraint)
    await req.pool.query(
      'DELETE FROM pricing WHERE menu_item_id = $1',
      [id]
    );

    // Then delete from menu_item
    const result = await req.pool.query(
      'DELETE FROM menu_item WHERE menu_item_id = $1 RETURNING *',
      [id]
    );

    if (result.rows.length === 0) {
      await req.pool.query('ROLLBACK');
      return res.status(404).json({ error: 'Menu item not found' });
    }

    await req.pool.query('COMMIT');
    res.json({ message: 'Menu item deleted', item: result.rows[0] });
  } catch (error) {
    await req.pool.query('ROLLBACK');
    console.error('Error deleting menu item:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});



// New route to get menu items by category
router.get('/menu-items/category/:category', async (req, res) => {
  const { category } = req.params;
  
  try {
    const result = await req.pool.query(`
      SELECT mi.menu_item_id, mi.item_name, mi.type_of_menu_item, 
             mi.quantity, p.price
      FROM menu_item mi
      JOIN pricing p ON mi.menu_item_id = p.menu_item_id
      WHERE mi.type_of_menu_item = $1
      ORDER BY mi.item_name
    `, [category]);
    
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching menu items by category:', error);
    res.status(500).json({ error: 'Failed to fetch menu items' });
  }
});

module.exports = router;
