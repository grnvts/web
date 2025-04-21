import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import AdminOrderCard from '../../components/AdminOrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';

const AllOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const roles = useSelector((state) => state.roles);
  const history = useHistory();
  const { t } = useTranslation();

  // Проверяем, является ли пользователь администратором
  const isAdmin = roles?.includes('ROLE_ADMIN');

  useEffect(() => {
    if (!isAdmin) {
      history.push('/index'); // Перенаправляем на главную страницу
      return;
    }

    const fetchOrders = async () => {
      try {
        setLoading(true);
        const response = await OrderService.getAllOrders();
        setOrders(response.data);
      } catch (error) {
        AlertifyService.error(t('Failed to load orders'));
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [isAdmin, history, t]);

  if (loading) {
    return <div className="container">{t('Loading orders...')}</div>;
  }

  return (
    <div className="container">
      <h3>{t('All Orders')}</h3>
      {orders.length > 0 ? (
        orders.map((order) => (
          <div key={order.id} className="mb-3">
            <AdminOrderCard order={order} />
          </div>
        ))
      ) : (
        <p>{t('No orders found')}</p>
      )}
    </div>
  );
};

export default AllOrdersPage;