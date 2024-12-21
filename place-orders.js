// Function to load locations (franchises)
async function loadLocations() {
    try {
        const response = await fetch('/api/franchises/test');
        const locations = await response.json();
        
        const locationSelect = document.querySelector('#location-select');
        locationSelect.innerHTML = '<option value="">Select a location...</option>';
        
        locations.forEach(location => {
            const option = document.createElement('option');
            option.value = location.id;
            option.textContent = `${location.city}, ${location.state}`;
            locationSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading locations:', error);
    }
}

// Function to load customers
async function loadCustomers() {
    try {
        const response = await fetch('/api/customers');
        const customers = await response.json();
        
        const customerSelect = document.querySelector('#customer-select');
        customerSelect.innerHTML = '<option value="">Select a customer...</option>';
        
        customers.forEach(customer => {
            const option = document.createElement('option');
            option.value = customer.user_id;
            option.textContent = `${customer.First_name} ${customer.Last_name}`;
            customerSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading customers:', error);
    }
}

// Function to load menu items
async function loadMenuItems() {
    try {
        const response = await fetch('/api/menu-items');
        const menuItems = await response.json();
        
        const menuItemsContainer = document.querySelector('#menu-items');
        menuItemsContainer.innerHTML = '';
        
        menuItems.forEach(item => {
            const itemDiv = document.createElement('div');
            itemDiv.className = 'menu-item';
            itemDiv.innerHTML = `
                <h3>${item.item_name}</h3>
                <p>Price: $${item.price}</p>
                <p>Type: ${item.type_of_menu_item}</p>
                <div class="quantity-controls">
                    <button class="decrease">-</button>
                    <span class="quantity">0</span>
                    <button class="increase">+</button>
                </div>
            `;
            
            // Add event listeners for quantity controls
            const decreaseBtn = itemDiv.querySelector('.decrease');
            const increaseBtn = itemDiv.querySelector('.increase');
            const quantitySpan = itemDiv.querySelector('.quantity');
            
            decreaseBtn.addEventListener('click', () => {
                let quantity = parseInt(quantitySpan.textContent);
                if (quantity > 0) {
                    quantity--;
                    quantitySpan.textContent = quantity;
                    updateOrderSummary(item, quantity);
                }
            });
            
            increaseBtn.addEventListener('click', () => {
                let quantity = parseInt(quantitySpan.textContent);
                quantity++;
                quantitySpan.textContent = quantity;
                updateOrderSummary(item, quantity);
            });
            
            menuItemsContainer.appendChild(itemDiv);
        });
    } catch (error) {
        console.error('Error loading menu items:', error);
    }
}

// Load everything when the page loads
document.addEventListener('DOMContentLoaded', () => {
    loadLocations();
    loadCustomers();
    loadMenuItems();
});