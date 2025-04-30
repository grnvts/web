import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import AdminOrderCard from '../../components/AdminOrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import './AllOrdersPage.css';

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
    return (
      <div className="orders-page">
        <div className="orders-container">
          <div className="loading-spinner">
            <i className="fas fa-spinner fa-spin"></i>
            <span>{t('Loading orders...')}</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="orders-page">
      <div className="orders-container">
        <div className="orders-header">
          <h1>{t('All Orders')}</h1>
          <p>{t('Manage and monitor all orders in the system')}</p>
        </div>
        <div className="orders-grid">
          {orders.length > 0 ? (
            orders.map((order) => (
              <AdminOrderCard key={order.id} order={order} />
            ))
          ) : (
            <div className="no-orders">
              <i className="fas fa-clipboard-list"></i>
              <p>{t('No orders found')}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AllOrdersPage;