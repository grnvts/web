import React from 'react';
import OrderForm from '../../components/OrderForm';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';

const CreateOrderPage = () => {
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
      <OrderForm onSubmit={handleOrderSubmit} />
    </div>
  );
};

export default CreateOrderPage;