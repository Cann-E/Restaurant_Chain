const express = require('express');
const router = express.Router();

router.get('/', async (req, res) => {
    try {
        const query = `
            SELECT
                f.id,
                f."City",
                f."State",
                f.address,
                f.zip,
                COUNT(o.id) as total_orders
            FROM franchise f
            LEFT JOIN orders o ON o."Franchise_id" = f.id
            GROUP BY f.id, f."City", f."State", f.address, f.zip
            ORDER BY f."City"
        `;
        const result = await req.pool.query(query);
        
        // Transform the data to ensure consistent property access
        const transformedData = result.rows.map(row => ({
            id: row.id,
            city: row["City"],
            state: row["State"],
            address: row.address,
            zip: row.zip,
            total_orders: Number(row.total_orders)
        }));
        
        res.json(transformedData);
    } catch (err) {
        console.error('Error fetching franchises:', err);
        res.status(500).json({ 
            error: 'Failed to fetch franchises',
            details: err.message 
        });
    }
});

module.exports = router;