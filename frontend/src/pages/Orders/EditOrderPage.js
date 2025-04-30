import React, { useState, useEffect } from 'react';
import AdminOrderForm from '../../components/AdminOrderForm';
import OrderCard from '../../components/OrderCard';
import OrderService from '../../Services/OrderService';
import { useParams, useHistory } from 'react-router-dom';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSpinner, faArrowLeft } from '@fortawesome/free-solid-svg-icons';
import './EditOrderPage.css';

const EditOrderPage = () => {
  const { orderId } = useParams();
  const history = useHistory();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const { t } = useTranslation();

  useEffect(() => {
    const fetchOrder = async () => {
      try {
        setLoading(true);
        const response = await OrderService.getOrderById(orderId);
        setOrder(response.data);
      } catch (error) {
        AlertifyService.error(t('Failed to load order details'));
      } finally {
        setLoading(false);
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

  const handleBack = () => {
    history.push(`/orders/${orderId}`);
  };

  return (
    <div className="edit-order-container">
      <div className="edit-order-header">
        <h3>
          <button 
            className="back-button"
            onClick={handleBack}
          >
            <FontAwesomeIcon icon={faArrowLeft} />
          </button>
          {t('Edit Order')}
        </h3>
      </div>

      <div className="edit-order-content">
        {loading ? (
          <div className="loading-container">
            <FontAwesomeIcon icon={faSpinner} spin />
            <span>{t('Loading...')}</span>
          </div>
        ) : order ? (
          <AdminOrderForm onSubmit={handleOrderSubmit} initialData={order} />
        ) : (
          <div className="error-message">
            {t('Order not found')}
          </div>
        )}
      </div>
    </div>
  );
};

export default EditOrderPage;