function toggleCreditCardInput() {
  const paymentMethod = document.getElementById('payment-method').value;
  const creditCardInput = document.getElementById('credit-card-number');
  creditCardInput.style.display = paymentMethod === 'credit' ? 'block' : 'none';
}

document.addEventListener('DOMContentLoaded', () => {
  const customersTableBody = document.getElementById('customers-body');
  const addCustomerBtn = document.getElementById('addCustomerBtn');
  const customerModal = document.getElementById('customerModal');
  const closeModalBtn = document.querySelector('.close-btn');
  const customerForm = document.getElementById('customerForm');

  // Fetch and display customers
  async function fetchCustomers() {
    try {
      const response = await fetch('/api/customers');
      const customers = await response.json();

      // Render customers to the table
      renderCustomers(customers);
    } catch (error) {
      console.error('Error fetching customers:', error);
    }
  }

  // Render customers function
  function renderCustomers(customers) {
    customersTableBody.innerHTML = customers
      .map(customer => `
        <tr>
          <td>${customer.user_id}</td>
          <td>${customer.First_name} ${customer.Last_name}</td>
          <td>${customer.username}</td>
          <td>${customer.email}</td>
          <td>${customer.phone_number}</td>
          <td>${customer.member ? 'Member' : 'Non-Member'}</td>
          <td>${customer.credit_card_number ? customer.credit_card_number : 'N/A'}</td>
          <td>
            <button onclick="deleteCustomer(${customer.user_id})">Delete</button>
          </td>
        </tr>
      `)
      .join('');
  }

  // Add customer
  customerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
  
    const paymentMethod = document.getElementById('payment-method').value;
    const creditCard = paymentMethod === 'credit' ? document.getElementById('credit-card-number').value : null;
  
    const customerData = {
      username: document.getElementById('username').value,
      email: document.getElementById('email').value,
      phone_number: document.getElementById('phone').value,
      first_name: document.getElementById('firstName').value,
      last_name: document.getElementById('lastName').value,
      member: document.getElementById('member').checked,
      location: document.getElementById('location').value,
      paymentMethod,
      creditCard,
    };
  
    // Validate Credit Card if payment method is credit
    if (paymentMethod === 'credit' && !creditCard) {
      alert('Please enter a credit card number.');
      return;
    }
  
    try {
      const response = await fetch('/api/customers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(customerData),
      });
  
      if (response.status === 400) {
        const errorData = await response.json();
        alert(`Failed to add customer: ${errorData.error}`);
        return; // Stop further execution 
      }
  
      if (!response.ok) {
        throw new Error('Failed to add customer');
      }
  
      const result = await response.json();
      alert(`Customer created successfully: ${result.message}`);
      customerModal.style.display = 'none';
      fetchCustomers(); // Refresh customer list
    } catch (error) {
      console.error('Error adding customer:', error);
      alert('Failed to add customer. Please try again.');
    }
  });
  

  // Delete customer
  window.deleteCustomer = async (id) => {
    try {
      const response = await fetch(`/api/customers/${id}`, { method: 'DELETE' });

      if (!response.ok) throw new Error('Failed to delete customer');

      fetchCustomers(); // Refresh customer list
    } catch (error) {
      console.error('Error deleting customer:', error);
    }
  };

  
  addCustomerBtn.addEventListener('click', () => {
    customerModal.style.display = 'block';
  });

  
  closeModalBtn.addEventListener('click', () => {
    customerModal.style.display = 'none';
  });

  // Initial fetch
  fetchCustomers();
});
