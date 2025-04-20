import React, { useState, useEffect } from 'react';
import OrderCard from '../../components/OrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';

const MyOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
      const fetchOrders = async () => {
          try {
              setLoading(true);
              const response = await OrderService.getMyOrders();
              setOrders(response.data);
          } catch (error) {
              AlertifyService.error('Failed to load orders');
          } finally {
              setLoading(false);
          }
      };

      fetchOrders();
  }, []);

  if (loading) {
      return <div className="container">Loading orders...</div>;
  }

  return (
      <div className="container">
          <h3>My Orders</h3>
          {orders.length > 0 ? (
              orders.map((order) => <OrderCard key={order.id} order={order} />)
          ) : (
              <p>No orders found</p>
          )}
      </div>
  );
};  

export default MyOrdersPage;