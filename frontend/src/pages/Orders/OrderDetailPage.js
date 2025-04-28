import React, { useState, useEffect } from 'react';
import OrderCard from '../../components/OrderCard';
import ChatModal from '../../components/ChatModal';
import OrderService from '../../Services/OrderService';
import { useParams, useHistory } from 'react-router-dom';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import BrigadierPickerWithCalendar from '../../components/BrigadierPickerWithCalendar';
import { useSelector } from 'react-redux';

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
  const roles = useSelector((state) => state.roles); // Получаем роли пользователя
  const username = useSelector((state) => state.username);
  const [showChat, setShowChat] = useState(false);
  const [chatRecipient, setChatRecipient] = useState('');
  
  const isBrigadier = roles?.includes('ROLE_BRIGADIER');
  const isAdmin = roles?.includes('ROLE_ADMIN');
  const isUser = roles?.includes('ROLE_USER');

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

  const openChat = (recipientType) => {
    if (recipientType === 'admin') {
      setChatRecipient('admin'); // Все администраторы
    } else if (recipientType === 'brigadier') {
      setChatRecipient(order.brigadierUsername); // Конкретный бригадир
    } else if (recipientType === 'user') {
      setChatRecipient(order.clientUsername); // Конкретный пользователь
    }
    setShowChat(true);
  };


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
        await OrderService.updateOrderStatus(orderId, {
            status,
            message: `Status changed to ${status}`,
        });
        AlertifyService.success(t('Order status updated successfully'));
        const updatedOrder = await OrderService.getOrderById(orderId);
        setOrder(updatedOrder.data);
        setShowStatusModal(false);
    } catch (error) {
        AlertifyService.error(t('Failed to update order status'));
    }
};


  const handleStartOrder = async () => {
    try {
      await OrderService.updateOrderStatus(order.id, { status: 'IN_PROGRESS' });
      AlertifyService.success(t('Order started successfully'));
      setOrder({ ...order, status: 'IN_PROGRESS' });
    } catch (error) {
      AlertifyService.error(t('Failed to start order'));
    }
  };

  const handleCompleteOrder = async () => {
    try {
      await OrderService.updateOrderStatus(order.id, { status: 'COMPLETED' });
      AlertifyService.success(t('Order marked as completed'));
      setOrder({ ...order, status: 'COMPLETED' });
    } catch (error) {
      AlertifyService.error(t('Failed to complete order'));
    }
  };

  return (
    <div className="container">
      {order ? (
        <>
          <OrderCard order={order} />



           {/* Кнопки для бригадира */}
      {isBrigadier && (
        <div className="mt-3">
          {order.status === 'APPROVED' && (
            <button className="btn btn-primary" onClick={handleStartOrder}>
              {t('Start Order')}
            </button>
          )}
          {order.status === 'IN_PROGRESS' && (
            <button className="btn btn-success" onClick={handleCompleteOrder}>
              {t('Mark as Completed')}
            </button>
          )}
        </div>
      )}
 {/* Кнопки чатов для пользователя */}
 {isUser && (
            <div className="mt-3">
              <button
                className="btn btn-primary"
                onClick={() => openChat('admin')}
              >
                {t('Chat with Admin')}
              </button>
              {order.brigadierUsername && (
                <button
                  className="btn btn-primary ms-2"
                  onClick={() => openChat('brigadier')}
                >
                  {t('Chat with Brigadier')}
                </button>
              )}
            </div>
          )}

          {/* Кнопка чата для бригадира */}
          {isBrigadier && (
            <div className="mt-3">
              <button
                className="btn btn-primary"
                onClick={() => openChat('user')}
              >
                {t('Chat with User')}
              </button>
            </div>
          )}

          {/* Кнопка чата для администратора */}
          {isAdmin && (
  <div className="mt-3">
    {/* Кнопка "Чат с пользователем" всегда показывается */}
    <button
      className="btn btn-primary"
      onClick={() => openChat('user')}
    >
      {t('Chat with User')}
    </button>
    {/* Кнопка "Чат с бригадиром" только если админ — клиент этого заказа */}
    {order.brigadierUsername && order.clientUsername === username && (
      <button
        className="btn btn-primary ms-2"
        onClick={() => openChat('brigadier')}
      >
        {t('Chat with Brigadier')}
      </button>
    )}
    {/* Кнопка "Чат с админом" только если админ НЕ клиент этого заказа */}
    {order.clientUsername !== username && !isAdmin && (
      <button
        className="btn btn-primary ms-2"
        onClick={() => openChat('admin')}
      >
        {t('Chat with Admin')}
      </button>
    )}
  </div>
)}


{showChat && (
  <ChatModal
    orderId={order.id}
    recipientUsername={
      // если чат с админом (для пользователя), то передаем username пользователя
      (chatRecipient === 'admin' && isUser)
        ? order.clientUsername
        : chatRecipient
    }
    isAdminChat={isAdmin ? chatRecipient === order.clientUsername : isUser && chatRecipient === 'admin'}
    onClose={() => setShowChat(false)}
  />
)}




{isAdmin && (
  <>
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
  </>
)}
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
                      <option value="APPROVED">{t('Approved')}</option>
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