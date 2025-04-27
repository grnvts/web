import React, { useState, useEffect } from 'react';
import OrderCard from '../../components/OrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import { useHistory } from 'react-router-dom';

const MyOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const { t } = useTranslation();
  const history = useHistory();

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

  const handleOrderClick = (orderId) => {
    history.push(`/orders/${orderId}`); // Переход к деталям заказа
  };

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
              <OrderCard order={order} onClick={() => handleOrderClick(order.id)} />
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