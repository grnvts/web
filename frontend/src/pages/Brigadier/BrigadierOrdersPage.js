import React, { useState, useEffect } from 'react';
import AdminOrderCard from '../../components/AdminOrderCard'; // Используем карточку, как у администратора
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';

const BrigadierOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const { t } = useTranslation();

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        setLoading(true);
        const response = await OrderService.getMyOrdersForBrigadier(); // Получаем заказы бригадира
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
        orders.map((order) => (
          <div key={order.id} className="mb-3">
            <AdminOrderCard order={order} /> {/* Используем карточку администратора */}
          </div>
        ))
      ) : (
        <p>{t('No orders found')}</p>
      )}
    </div>
  );
};

export default BrigadierOrdersPage;