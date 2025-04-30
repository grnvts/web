import React, { useState, useEffect } from 'react';
import CompactOrderCard from '../../components/CompactOrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import './MyOrdersPage.css';

const MyOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false); // Добавляем состояние для ошибки
  const { t } = useTranslation();

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        setLoading(true);
        const response = await OrderService.getMyOrders(); // Получаем только заказы текущего пользователя
        setOrders(response.data);
        setError(false); // Сбрасываем ошибку при успешной загрузке
      } catch (error) {
        // AlertifyService.error(t('Failed to load orders')); // Убираем AlertifyService
        setError(true); // Устанавливаем ошибку в true
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [t]);

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
          <h1>{t('My Orders')}</h1>
          <p>{t('View and manage your orders')}</p>
        </div>
        <div className="orders-grid">
          {error ? ( // Условный рендеринг для отображения сообщения об отсутствии данных
            <div className="no-orders">
              <i className="fas fa-exclamation-triangle"></i>
              <p>{t('No data available')}</p>
            </div>
          ) : orders.length > 0 ? (
            orders.map((order) => (
              <CompactOrderCard key={order.id} order={order} />
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

export default MyOrdersPage;