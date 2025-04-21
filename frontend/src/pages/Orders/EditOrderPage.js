import React, { useState, useEffect } from 'react';
import AdminOrderForm from '../../components/AdminOrderForm';
import OrderCard from '../../components/OrderCard';

import OrderService from '../../Services/OrderService';
import { useParams, useHistory } from 'react-router-dom';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';

const EditOrderPage = () => {
  const { orderId } = useParams();
  const history = useHistory();
  const [order, setOrder] = useState(null);
  const { t } = useTranslation();

  useEffect(() => {
    const fetchOrder = async () => {
      try {
        const response = await OrderService.getOrderById(orderId);
        setOrder(response.data);
      } catch (error) {
        AlertifyService.error(t('Failed to load order details'));
      }
    };

    fetchOrder();
  }, [orderId, t]);

  const handleOrderSubmit = async (updatedOrder) => {
    try {
      await OrderService.updateOrder(orderId, updatedOrder);
      AlertifyService.success(t('Order updated successfully'));
      history.push(`/orders/${orderId}`);
    } catch (error) {
      AlertifyService.error(t('Failed to update order'));
    }
  };

  return (
    <div className="container">
      <h3>{t('Edit Order')}</h3>
      {order ? (
        <AdminOrderForm onSubmit={handleOrderSubmit} initialData={order} />
      ) : (
        <p>{t('Loading...')}</p>
      )}
    </div>
  );
};

export default EditOrderPage;