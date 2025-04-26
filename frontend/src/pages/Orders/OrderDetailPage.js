import React, { useState, useEffect } from 'react';
import OrderCard from '../../components/OrderCard';
import OrderService from '../../Services/OrderService';
import { useParams, useHistory } from 'react-router-dom';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import BrigadierPickerWithCalendar from '../../components/BrigadierPickerWithCalendar';


const OrderDetailPage = () => {
  const { orderId } = useParams();
  const history = useHistory();
  const [order, setOrder] = useState(null);
  const [brigadier, setBrigadier] = useState('');
  const [status, setStatus] = useState('');
  const [showBrigadierModal, setShowBrigadierModal] = useState(false);
  const [showStatusModal, setShowStatusModal] = useState(false);
  const { t } = useTranslation();
  const [statusMessage, setStatusMessage] = useState('');


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

  const handleEditClick = () => {
    history.push(`/orders/${orderId}/edit`);
  };
  
  const handleOpenStatusModal = () => {
    setStatus(order.status); // Устанавливаем текущий статус заказа
    setShowStatusModal(true); // Открываем модальное окно
  };

  const handleAssignBrigadier = async (username) => {
    try {
      await OrderService.assignBrigadier(orderId, username);
      AlertifyService.success(t('Brigadier assigned successfully'));
      const updatedOrder = await OrderService.getOrderById(orderId);
      setOrder(updatedOrder.data);
      setShowBrigadierModal(false); // Закрываем модальное окно
    } catch (error) {
      AlertifyService.error(t('Failed to assign brigadier'));
    }
  };

  const handleChangeStatus = async () => {
    try {
      // Ensure the payload matches the backend DTO
      await OrderService.updateOrderStatus(orderId, { status, message: statusMessage });
      AlertifyService.success(t('Order status updated successfully'));
      const updatedOrder = await OrderService.getOrderById(orderId);
      setOrder(updatedOrder.data);
      setShowStatusModal(false);
    } catch (error) {
      AlertifyService.error(t('Failed to update order status'));
    }
  };

  return (
    <div className="container">
      {order ? (
        <>
          <OrderCard order={order} />
          <button className="btn btn-primary mt-3" onClick={handleEditClick}>
            {t('Edit Order')}
          </button>

          {/* Кнопка для открытия модального окна "Назначить бригадира" */}
          <button
            className="btn btn-success mt-3"
            onClick={() => setShowBrigadierModal(true)}
          >
            {t('Assign Brigadier')}
          </button>

           {/* Кнопка для открытия модального окна "Изменить статус" */}
        <button
          className="btn btn-warning mt-3"
          onClick={handleOpenStatusModal}
        >
          {t('Change Status')}
        </button>

          {/* Модальное окно для назначения бригадира */}
          {showBrigadierModal && (
  <BrigadierPickerWithCalendar onAssign={(username) => {
    if (username) handleAssignBrigadier(username);
    setShowBrigadierModal(false);
  }} />
)}

          {/* Модальное окно для изменения статуса */}
          {showStatusModal && (
            <div className="modal show d-block" tabIndex="-1">
              <div className="modal-dialog">
                <div className="modal-content">
                  <div className="modal-header">
                    <h5 className="modal-title">{t('Change Status')}</h5>
                    <button
                      type="button"
                      className="btn-close"
                      onClick={() => setShowStatusModal(false)}
                    ></button>
                  </div>
                  <div className="modal-body">
                    <label htmlFor="status">{t('Select Status')}</label>
                    <select
                      id="status"
                      className="form-control"
                      value={status}
                      onChange={(e) => setStatus(e.target.value)}
                    >
                      <option value="">{t('Select Status')}</option>
                      <option value="CREATED">{t('Created')}</option>
                      <option value="IN_PROGRESS">{t('In Progress')}</option>
                      <option value="COMPLETED">{t('Completed')}</option>
                      <option value="CANCELLED">{t('Cancelled')}</option>
                      <option value="REJECTED">{t('Rejected')}</option>
                    </select>
                    <textarea
                      className="form-control"
                      value={statusMessage}
                      onChange={(e) => setStatusMessage(e.target.value)}
                      placeholder={t('Enter a message for the user')}
                    />
                  </div>
                  <div className="modal-footer">
                    <button
                      className="btn btn-secondary"
                      onClick={() => setShowStatusModal(false)}
                    >
                      {t('Cancel')}
                    </button>
                    <button
                      className="btn btn-warning"
                      onClick={handleChangeStatus}
                    >
                      {t('Change')}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </>
      ) : (
        <p>{t('Loading...')}</p>
      )}
    </div>
  );
};

export default OrderDetailPage;