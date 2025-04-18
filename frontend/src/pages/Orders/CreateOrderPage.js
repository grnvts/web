import React, { useState, useEffect } from 'react';
import OrderForm from '../../components/OrderForm';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';

const CreateOrderPage = () => {
  const [buildings, setBuildings] = useState([]);

  useEffect(() => {
    const fetchBuildings = async () => {
      try {
        const response = await OrderService.getBuildings();
        setBuildings(response.data);
      } catch (error) {
        AlertifyService.error('Failed to load buildings');
      }
    };

    fetchBuildings();
  }, []);

  const handleOrderSubmit = async (orderData) => {
    try {
      await OrderService.createOrder(orderData);
      AlertifyService.success('Order created successfully');
    } catch (error) {
      AlertifyService.error('Failed to create order');
    }
  };

  return (
    <div className="container">
      <h3>Create Order</h3>
      <OrderForm onSubmit={handleOrderSubmit} buildings={buildings} />
    </div>
  );
};

export default CreateOrderPage;