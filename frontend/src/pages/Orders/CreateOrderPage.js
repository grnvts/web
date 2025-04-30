import React from 'react';
import OrderForm from '../../components/OrderForm';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import { useHistory } from 'react-router-dom'; // Импортируем useHistory

const CreateOrderPage = () => {
  const { t } = useTranslation();
  const history = useHistory(); // Инициализируем history

  const handleOrderSubmit = async (orderData) => {
    try {
      await OrderService.createOrder(orderData);
      AlertifyService.success(t('Order created successfully'));
      history.push('/orders'); // Перенаправляем на страницу "Мои заказы"
    } catch (error) {
      AlertifyService.error(t('Failed to create order'));
    }
  };

  return (
    <div className="container">
      <h3>{t('Create Order')}</h3>
      <OrderForm onSubmit={handleOrderSubmit} />
    </div>
  );
};

export default CreateOrderPage;