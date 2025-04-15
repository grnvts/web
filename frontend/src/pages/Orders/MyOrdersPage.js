import React, { useState, useEffect } from 'react';
import OrderCard from '../../components/OrderCard';
import OrderService from '../../services/OrderService';
import AlertifyService from '../../services/AlertifyService';

const MyOrdersPage = () => {
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        const response = await OrderService.getMyOrders();
        setOrders(response.data);
      } catch (error) {
        AlertifyService.error('Failed to load orders');
      }
    };

    fetchOrders();
  }, []);

  return (
    <div className="container">
      <h3>My Orders</h3>
      {orders.map((order) => (
        <OrderCard key={order.id} order={order} />
      ))}
    </div>
  );
};

export default MyOrdersPage;