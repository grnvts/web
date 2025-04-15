import React, { useState, useEffect } from 'react';
import OrderCard from '../../components/OrderCard';
import OrderService from '../../services/OrderService';
import { useParams } from 'react-router-dom';
import AlertifyService from '../../services/AlertifyService';

const OrderDetailPage = () => {
  const { orderId } = useParams();
  const [order, setOrder] = useState(null);

  useEffect(() => {
    const fetchOrder = async () => {
      try {
        const response = await OrderService.getOrderById(orderId);
        setOrder(response.data);
      } catch (error) {
        AlertifyService.error('Failed to load order details');
      }
    };

    fetchOrder();
  }, [orderId]);

  return (
    <div className="container">
      {order ? <OrderCard order={order} /> : <p>Loading...</p>}
    </div>
  );
};

export default OrderDetailPage;