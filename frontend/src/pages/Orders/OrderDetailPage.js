import React, { useState, useEffect } from 'react';
import OrderCard from '../../components/OrderCard';
import ChatModal from '../../components/ChatModal';
import OrderService from '../../Services/OrderService';
import { useParams, useHistory } from 'react-router-dom';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import BrigadierPickerWithCalendar from '../../components/BrigadierPickerWithCalendar';
import { useSelector } from 'react-redux';
import AssignMastersModal from '../../components/AssignMastersModal';
import jsPDF from 'jspdf';
import { format } from 'date-fns';
import './OrderDetailPage.css';

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
  const [showAssignMastersModal, setShowAssignMastersModal] = useState(false);
  const [showExpenseModal, setShowExpenseModal] = useState(false);
  const [expenseAmount, setExpenseAmount] = useState('');
  const [loading, setLoading] = useState(true); // Добавляем состояние загрузки
  const [error, setError] = useState(false); // Добавляем состояние для ошибки

  const isBrigadier = roles?.includes('ROLE_BRIGADIER');
  const isAdmin = roles?.includes('ROLE_ADMIN');
  const isUser = roles?.includes('ROLE_USER');

  useEffect(() => {
    const fetchOrder = async () => {
      try {
        setLoading(true);
        const response = await OrderService.getOrderById(orderId);
        setOrder(response.data);
        setError(false); // Сбрасываем ошибку при успешной загрузке
      } catch (error) {
        console.error('Failed to load order details', error);
        AlertifyService.error(t('Failed to load order details'));
        setError(true); // Устанавливаем ошибку в true
      } finally {
        setLoading(false);
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

  const handleAddExpense = async () => {
    if (!expenseAmount || isNaN(expenseAmount) || Number(expenseAmount) <= 0) {
      alert('Введите корректную сумму расходов');
      return;
    }

    try {
      await OrderService.addExpense(orderId, Number(expenseAmount));
      alert('Расходы успешно добавлены');
      setShowExpenseModal(false);
      setExpenseAmount('');
      // Обновляем данные заказа
      const updatedOrder = await OrderService.getOrderById(orderId);
      setOrder(updatedOrder.data);
    } catch (error) {
      alert('Ошибка при добавлении расходов');
    }
  };

  const handleAssignMasters = async (masterIds) => {
    try {
      await OrderService.assignMasters(order.id, masterIds);
      AlertifyService.success(t('Masters assigned successfully'));
      const updatedOrder = await OrderService.getOrderById(order.id);
      setOrder(updatedOrder.data);
      setShowAssignMastersModal(false);
    } catch (error) {
      AlertifyService.error(t('Failed to assign masters'));
    }
  };


  const handleEditClick = () => {
    history.push(`/orders/${orderId}/edit`);
  };
  
  const handleOpenStatusModal = () => {
    setStatus(order.status); 
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

  const generatePDF = async () => {
    if (!order) return;

    // Загружаем мастеров для заказа
    let masters = [];
    try {
      const mastersResponse = await OrderService.getAssignedMasters(order.id);
      masters = mastersResponse.data || [];
    } catch (error) {
      console.error('Failed to load masters for PDF:', error);
    }

    const formatDate = (dateString) => {
      if (!dateString) return 'N/A';
      try {
        return format(new Date(dateString), 'dd.MM.yyyy');
      } catch {
        return dateString;
      }
    };

    const formatDateTime = (dateString) => {
      if (!dateString) return 'N/A';
      try {
        return format(new Date(dateString), 'dd.MM.yyyy HH:mm');
      } catch {
        return dateString;
      }
    };

    const getMasterName = (master) => {
      const name = master.name || '';
      const surname = master.surname || '';
      const patronymic = master.patronymic || '';
      
      if (name || surname) {
        return `${surname} ${name} ${patronymic}`.trim();
      }
      
      return master.username || 'N/A';
    };

    // Создаем canvas для рендеринга текста с кириллицей
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    canvas.width = 794; // A4 width in pixels
    canvas.height = 1123; // A4 height in pixels
    
    // Устанавливаем стили для текста
    ctx.fillStyle = '#000000';
    ctx.font = '16px Arial';
    ctx.textBaseline = 'top';
    
    let yPos = 40;
    const margin = 40;
    const lineHeight = 20;
    const pageWidth = canvas.width;
    
    // Функция для добавления текста с переносами
    const addText = (text, x, y, maxWidth, fontSize = 12, isBold = false) => {
      ctx.font = `${isBold ? 'bold ' : ''}${fontSize}px Arial`;
      const words = text.split(' ');
      let line = '';
      let currentY = y;
      
      for (let i = 0; i < words.length; i++) {
        const testLine = line + words[i] + ' ';
        const metrics = ctx.measureText(testLine);
        const testWidth = metrics.width;
        
        if (testWidth > maxWidth && i > 0) {
          ctx.fillText(line, x, currentY);
          line = words[i] + ' ';
          currentY += lineHeight;
        } else {
          line = testLine;
        }
      }
      ctx.fillText(line, x, currentY);
      return currentY + lineHeight;
    };

    // Заголовок
    ctx.font = 'bold 24px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('ЧЕК ЗАКАЗА', pageWidth / 2, yPos);
    yPos += 40;
    
    // Линия
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(margin, yPos);
    ctx.lineTo(pageWidth - margin, yPos);
    ctx.stroke();
    yPos += 20;
    
    ctx.textAlign = 'left';
    ctx.font = '12px Arial';
    
    // Информация о заказе
    yPos = addText(`Номер заказа: #${order.id}`, margin, yPos, pageWidth - 2 * margin, 12, true);
    yPos = addText(`Дата создания: ${formatDateTime(order.createdDate)}`, margin, yPos, pageWidth - 2 * margin, 12, true);
    yPos = addText(`Статус: ${t(order.status) || order.status}`, margin, yPos, pageWidth - 2 * margin, 12, true);
    yPos += 10;
    
    // Разделитель
    ctx.beginPath();
    ctx.moveTo(margin, yPos);
    ctx.lineTo(pageWidth - margin, yPos);
    ctx.stroke();
    yPos += 20;
    
    // Тип услуги
    yPos = addText('Тип услуги:', margin, yPos, pageWidth - 2 * margin, 14, true);
    yPos = addText(t(order.serviceType) || order.serviceType, margin, yPos, pageWidth - 2 * margin, 12, false);
    yPos += 10;
    
    // Детали заказа
    yPos = addText('Детали заказа:', margin, yPos, pageWidth - 2 * margin, 14, true);
    yPos = addText(order.orderDetails || 'N/A', margin, yPos, pageWidth - 2 * margin, 12, false);
    yPos += 10;
    
    // Разделитель
    ctx.beginPath();
    ctx.moveTo(margin, yPos);
    ctx.lineTo(pageWidth - margin, yPos);
    ctx.stroke();
    yPos += 20;
    
    // Даты
    yPos = addText(`Дата начала: ${formatDate(order.startDate)}`, margin, yPos, pageWidth - 2 * margin, 12, true);
    yPos = addText(`Дата окончания: ${formatDate(order.endDate) || 'N/A'}`, margin, yPos, pageWidth - 2 * margin, 12, true);
    yPos += 10;
    
    // Адрес
    const address = order.address || {};
    yPos = addText('Адрес:', margin, yPos, pageWidth - 2 * margin, 14, true);
    yPos = addText(`Город: ${address.city || 'N/A'}`, margin, yPos, pageWidth - 2 * margin, 12, false);
    yPos = addText(`Улица: ${address.street || 'N/A'}`, margin, yPos, pageWidth - 2 * margin, 12, false);
    yPos = addText(`Дом: ${address.buildingNo || 'N/A'}`, margin, yPos, pageWidth - 2 * margin, 12, false);
    yPos = addText(`Квартира: ${address.apartmentNo || 'N/A'}`, margin, yPos, pageWidth - 2 * margin, 12, false);
    yPos += 10;
    
    // Клиент
    const clientFullName = `${order.clientSurname || ''} ${order.clientName || ''} ${order.clientPatronymic || ''}`.trim() || order.clientUsername || 'N/A';
    yPos = addText('Клиент:', margin, yPos, pageWidth - 2 * margin, 14, true);
    yPos = addText(clientFullName, margin, yPos, pageWidth - 2 * margin, 12, false);
    if (order.clientPhone) {
      yPos = addText(`Телефон: ${order.clientPhone}`, margin, yPos, pageWidth - 2 * margin, 12, false);
    }
    yPos += 10;
    
    // Бригадир
    if (order.brigadierName || order.brigadierSurname || order.brigadierUsername) {
      const brigadierFullName = `${order.brigadierSurname || ''} ${order.brigadierName || ''} ${order.brigadierPatronymic || ''}`.trim() || order.brigadierUsername || 'N/A';
      yPos = addText('Бригадир:', margin, yPos, pageWidth - 2 * margin, 14, true);
      yPos = addText(brigadierFullName, margin, yPos, pageWidth - 2 * margin, 12, false);
      if (order.brigadierPhone) {
        yPos = addText(`Телефон: ${order.brigadierPhone}`, margin, yPos, pageWidth - 2 * margin, 12, false);
      }
      yPos += 10;
    }
    
    // Номер бригады
    if (order.brigadeNumber) {
      yPos = addText(`Номер бригады: ${order.brigadeNumber}`, margin, yPos, pageWidth - 2 * margin, 12, true);
      yPos += 10;
    }
    
    // Мастера
    if (masters && masters.length > 0) {
      yPos = addText('Мастера:', margin, yPos, pageWidth - 2 * margin, 14, true);
      const mastersText = masters.map(master => getMasterName(master)).join(', ');
      yPos = addText(mastersText, margin, yPos, pageWidth - 2 * margin, 12, false);
      yPos += 10;
    }
    
    // Разделитель перед ценой
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(margin, yPos);
    ctx.lineTo(pageWidth - margin, yPos);
    ctx.stroke();
    yPos += 20;
    
    // Цена
    ctx.font = 'bold 18px Arial';
    ctx.fillText('Сумма:', margin, yPos);
    const priceText = order.price ? `${order.price} BYN` : 'N/A';
    ctx.font = 'bold 20px Arial';
    ctx.textAlign = 'right';
    ctx.fillText(priceText, pageWidth - margin, yPos);
    yPos += 30;
    
    // Итоговая линия
    ctx.beginPath();
    ctx.moveTo(margin, yPos);
    ctx.lineTo(pageWidth - margin, yPos);
    ctx.stroke();
    yPos += 30;
    
    // Подпись и дата
    ctx.textAlign = 'center';
    ctx.font = '10px Arial';
    ctx.fillStyle = '#666666';
    ctx.fillText(`Дата формирования чека: ${formatDateTime(new Date())}`, pageWidth / 2, yPos);
    yPos += 15;
    ctx.fillStyle = '#000000';
    ctx.font = '12px Arial';

    // Конвертируем canvas в изображение и добавляем в PDF
    const imgData = canvas.toDataURL('image/png');
    const doc = new jsPDF('p', 'mm', 'a4');
    const imgWidth = 210; // A4 width in mm
    const imgHeight = (canvas.height * imgWidth) / canvas.width;
    
    doc.addImage(imgData, 'PNG', 0, 0, imgWidth, imgHeight);
    
    // Сохранение PDF
    const fileName = `order_${order.id}_${format(new Date(), 'yyyy-MM-dd')}.pdf`;
    doc.save(fileName);
    AlertifyService.success(t('PDF generated successfully'));
  };

  if (loading) {
    return (
      <div className="order-detail-page">
        <div className="loading-spinner">
          <i className="fas fa-spinner fa-spin"></i>
          <span>{t('Loading...')}</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="order-detail-page">
        <div className="order-detail-container">
          <div className="order-detail-header">
            <h1>{t('Order Details')}</h1>
            <p>{t('View and manage order information')}</p>
          </div>
          <div className="no-data">
            <i className="fas fa-exclamation-triangle"></i>
            <p>{t('No data available')}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="order-detail-page">
      <div className="order-detail-container">
        <div className="order-detail-header">
          <h1>{t('Order Details')}</h1>
          <p>{t('View and manage order information')}</p>
        </div>

        <div className="order-detail-content">
          <OrderCard order={order} />

          <div className="order-actions">
            {isBrigadier && (
              <>
                {order.status === 'APPROVED' && (
                  <button className="btn btn-primary" onClick={handleStartOrder}>
                    <i className="fas fa-play"></i>
                    {t('Start Order')}
                  </button>
                )}
                {order.status === 'IN_PROGRESS' && (
                  <button className="btn btn-success" onClick={handleCompleteOrder}>
                    <i className="fas fa-check"></i>
                    {t('Mark as Completed')}
                  </button>
                )}
                <button className="btn btn-info" onClick={() => setShowAssignMastersModal(true)}>
                  <i className="fas fa-users"></i>
                  {t('Assign Masters')}
                </button>
                <button className="btn btn-info" onClick={() => setShowExpenseModal(true)}>
                  <i className="fas fa-money-bill"></i>
                  {t('Add Expenses')}
                </button>
              </>
            )}

            {isUser && (
              <>
                <button className="btn btn-primary" onClick={() => openChat('admin')}>
                  <i className="fas fa-comments"></i>
                  {t('Chat with Admin')}
                </button>
                {order?.brigadierUsername && (
                  <button className="btn btn-primary" onClick={() => openChat('brigadier')}>
                    <i className="fas fa-comments"></i>
                    {t('Chat with Brigadier')}
                  </button>
                )}
              </>
            )}

            {isBrigadier && (
              <button className="btn btn-primary" onClick={() => openChat('user')}>
                <i className="fas fa-comments"></i>
                {t('Chat with User')}
              </button>
            )}

            {isAdmin && (
              <>
                <button className="btn btn-primary" onClick={handleEditClick}>
                  <i className="fas fa-edit"></i>
                  {t('Edit Order')}
                </button>
                <button className="btn btn-success" onClick={() => setShowBrigadierModal(true)}>
                  <i className="fas fa-user-tie"></i>
                  {t('Assign Brigadier')}
                </button>
                <button className="btn btn-warning" onClick={handleOpenStatusModal}>
                  <i className="fas fa-exchange-alt"></i>
                  {t('Change Status')}
                </button>
                <button className="btn btn-info" onClick={() => openChat('user')}>
                  <i className="fas fa-comments"></i>
                  {t('Chat with User')}
                </button>
                <button className="btn btn-secondary" onClick={generatePDF}>
                  <i className="fas fa-file-pdf"></i>
                  {t('Download Receipt')}
                </button>
               
              </>
            )}
          </div>
        </div>
      </div>

      {showBrigadierModal && (
        <BrigadierPickerWithCalendar onAssign={(username) => {
          if (username) handleAssignBrigadier(username);
          setShowBrigadierModal(false);
        }} />
      )}

      {showStatusModal && (
        <div className="modal show d-block" tabIndex="-1">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">{t('Change Status')}</h5>
                <button type="button" className="btn-close" onClick={() => setShowStatusModal(false)}></button>
              </div>
              <div className="modal-body">
                <div className="mb-3">
                  <label htmlFor="status" className="form-label">{t('Select Status')}</label>
                  <select
                    id="status"
                    className="form-select"
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
                </div>
                <div className="mb-3">
                  <label htmlFor="statusMessage" className="form-label">{t('Enter a message for the user')}</label>
                  <textarea
                    id="statusMessage"
                    className="form-control"
                    value={statusMessage}
                    onChange={(e) => setStatusMessage(e.target.value)}
                    rows="3"
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button className="btn btn-secondary" onClick={() => setShowStatusModal(false)}>
                  {t('Cancel')}
                </button>
                <button 
                  className="btn btn-warning" 
                  onClick={handleChangeStatus}
                  disabled={!status || status === order.status}
                >
                  {t('Change')}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {showExpenseModal && (
        <div className="modal show d-block" tabIndex="-1">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">{t('Add Expenses')}</h5>
                <button type="button" className="btn-close" onClick={() => setShowExpenseModal(false)}></button>
              </div>
              <div className="modal-body">
                <label>{t('Expense Amount')}</label>
                <input
                  type="number"
                  className="form-control"
                  value={expenseAmount}
                  onChange={(e) => setExpenseAmount(e.target.value)}
                />
              </div>
              <div className="modal-footer">
                <button className="btn btn-secondary" onClick={() => setShowExpenseModal(false)}>
                  {t('Cancel')}
                </button>
                <button className="btn btn-success" onClick={handleAddExpense}>
                  {t('Add')}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

{showChat && (
  <>
    {console.log("isAdminChat:", isAdmin ? chatRecipient === order.clientUsername : isUser && chatRecipient === 'admin')}
    <ChatModal
      orderId={order.id}
      recipientUsername={chatRecipient}
      isAdminChat={isAdmin ? chatRecipient === order.clientUsername : isUser && chatRecipient === 'admin'}
      onClose={() => setShowChat(false)}
    />
  </>
)}
      {showAssignMastersModal && (
        <AssignMastersModal
          brigadeId={order.brigadeId}
          orderId={order.id}
          onAssign={handleAssignMasters}
          onClose={() => setShowAssignMastersModal(false)}
        />
      )}
    </div>
  );
};

export default OrderDetailPage;