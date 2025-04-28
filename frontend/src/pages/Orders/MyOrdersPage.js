import React, { useState, useEffect } from 'react';
import CompactOrderCard from '../../components/CompactOrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';

const MyOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const { t } = useTranslation();

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        setLoading(true);
        const response = await OrderService.getMyOrders(); // Получаем только заказы текущего пользователя
        setOrders(response.data);
      } catch (error) {
        AlertifyService.error(t('Failed to load orders'));
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [t]);

  if (loading) {
    return <div className="container">{t('Loading orders...')}</div>;
  }

  return (
    <div className="container">
      <h3>{t('My Orders')}</h3>
      {orders.length > 0 ? (
        <div className="row">
          {orders.map((order) => (
            <div className="col-md-4" key={order.id}>
              <CompactOrderCard order={order} />
            </div>
          ))}
        </div>
      ) : (
        <p>{t('No orders found')}</p>
      )}
    </div>
  );
};

export default MyOrdersPage;