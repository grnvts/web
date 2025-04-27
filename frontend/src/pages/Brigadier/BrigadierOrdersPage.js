import React, { useState, useEffect } from 'react';
import AdminOrderCard from '../../components/AdminOrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import moment from 'moment'; // Для работы с датами

const BrigadierOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const { t } = useTranslation();

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        setLoading(true);
        console.log('Fetching active orders for brigadier...');
        const response = await OrderService.getActiveOrdersForBrigadier();
        setOrders(response.data);
      } catch (error) {
        console.error('Error fetching orders:', error);
        AlertifyService.error(t('Failed to load orders'));
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [t]);

  // Группировка заказов по дате
  const groupOrdersByDate = (orders) => {
    const today = moment().startOf('day'); // Текущая дата
    const grouped = {};

    orders.forEach((order) => {
      const startDate = order.status === 'IN_PROGRESS' ? today : moment(order.startDate).startOf('day');
      const dateKey = startDate.format('YYYY-MM-DD');

      if (!grouped[dateKey]) {
        grouped[dateKey] = [];
      }
      grouped[dateKey].push(order);
    });

    // Сортируем даты по возрастанию
    const sortedDates = Object.keys(grouped).sort((a, b) => moment(a).diff(moment(b)));

    return sortedDates.map((date) => ({
      date,
      orders: grouped[date].sort((a, b) => moment(a.startDate).diff(moment(b.startDate))),
    }));
  };

  if (loading) {
    return <div className="container">{t('Loading orders...')}</div>;
  }

  const groupedOrders = groupOrdersByDate(orders);

  return (
    <div className="container">
      <h3>{t('My Active Orders')}</h3>
      {groupedOrders.length > 0 ? (
        groupedOrders.map((group) => (
          <div key={group.date} className="mb-4">
            <h5>{moment(group.date).format('DD.MM.YYYY')}</h5>
            {group.orders.map((order) => (
              <div key={order.id} className="mb-3">
                <AdminOrderCard order={order} />
              </div>
            ))}
          </div>
        ))
      ) : (
        <p>{t('No active orders found')}</p>
      )}
    </div>
  );
};

export default BrigadierOrdersPage;