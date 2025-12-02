import React, { useState, useEffect } from 'react';
import OrderStatusBadge from './OrderStatusBadge';
import OrderService from '../Services/OrderService';
import { Link } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { format } from 'date-fns';
import './OrderCard.css';

const OrderCard = ({ order }) => {
  const {
    serviceType,
    orderDetails,
    startDate,
    endDate,
    status,
    address = {},
    price,
    createdDate,
    clientUsername = 'Unknown'
  } = order;

  const { t } = useTranslation();
  const roles = useSelector((state) => state.roles);
  const isUser = roles?.includes('ROLE_USER');
  const isBrigadier = roles?.includes('ROLE_BRIGADIER');
  const isAdmin = roles?.includes('ROLE_ADMIN');
  const [masters, setMasters] = useState([]);
  const [loadingMasters, setLoadingMasters] = useState(false);

  useEffect(() => {
    const fetchMasters = async () => {
      try {
        setLoadingMasters(true);
        const response = await OrderService.getAssignedMasters(order.id);
        setMasters(response.data || []);
      } catch (error) {
        console.error('Failed to load masters:', error);
        setMasters([]);
      } finally {
        setLoadingMasters(false);
      }
    };

    if (order.id) {
      fetchMasters();
    }
  }, [order.id]);

  const getMasterName = (master) => {
    const name = master.name || '';
    const surname = master.surname || '';
    const patronymic = master.patronymic || '';
    
    if (name || surname) {
      return `${surname} ${name} ${patronymic}`.trim();
    }
    
    return master.username || t('Unknown');
  };
  const handleCancelOrder = async () => {
    if (window.confirm(t('Are you sure you want to cancel this order?'))) {
      try {
        await OrderService.updateOrderStatus(order.id, { status: 'REJECTED' });
        alert(t('Order canceled successfully'));
        // Здесь можно обновить состояние или вызвать перезагрузку данных
      } catch (error) {
        console.error('Failed to cancel order:', error);
        alert(t('Failed to cancel order'));
      }
    }
  };
  const {
    street,
    city,
    apartmentNo,
    buildingNo,
  } = address || {};

  const formattedCreatedDate = createdDate ? format(new Date(createdDate), 'yyyy-MM-dd HH:mm:ss') : t('N/A');
  const clientFullName = `${order.clientSurname || ''} ${order.clientName || ''} ${order.clientPatronymic || ''}`.trim();

  let brigadierContent;

if (order.brigadierName || order.brigadierSurname || order.brigadierPatronymic) {
  const brigadierFullName = `${order.brigadierSurname || ''} ${order.brigadierName || ''} ${order.brigadierPatronymic || ''}`.trim() + 
    ` - ${order.brigadierPhone || t('No Phone')}`;
  
  if (roles?.includes('ROLE_ADMIN')) {
    brigadierContent = (
      <Link to={`/user/${order.brigadierUsername}`} className="order-card-link">
        {brigadierFullName}
      </Link>
    );
  } else {
    brigadierContent = <span className="order-card-value">{brigadierFullName}</span>;
  }
} else {
  brigadierContent = <span className="order-card-value">{t('No data')}</span>;
}


  return (
    <div className="order-card">
      <div className="order-card-header">
        <h3 className="order-card-title">{t(serviceType)}</h3>
        <OrderStatusBadge status={t(status)} />
      </div>
      
      <div className="order-card-body">
        <div className="order-card-section">
          <span className="order-card-label">{t('Order Details')}</span>
          <span className="order-card-value">{orderDetails}</span>
        </div>

        <div className="order-card-section">
          <span className="order-card-label">{t('Price')}</span>
          <span className="order-card-value">{price ? `${price} BYN` : t('N/A')}</span>
        </div>

        <div className="order-card-section">
          <span className="order-card-label">{t('Created Date')}</span>
          <span className="order-card-value">{formattedCreatedDate}</span>
        </div>

        <div className="order-card-section">
          <span className="order-card-label">{t('Start Date')}</span>
          <span className="order-card-value">{startDate}</span>
        </div>

        <div className="order-card-section">
          <span className="order-card-label">{t('End Date')}</span>
          <span className="order-card-value">{endDate || t('N/A')}</span>
        </div>

        <div className="order-card-section">
          <span className="order-card-label">{t('Address')}</span>
          <div className="order-card-value">
            <div>{city || t('N/A')}</div>
            <div>{street || t('N/A')}</div>
            <div>{buildingNo || t('N/A')}</div>
            <div>{apartmentNo || t('N/A')}</div>
          </div>
        </div>

        {!isBrigadier && (
          <div className="order-card-section">
            <span className="order-card-label">{t('Brigadier')}</span>
            {brigadierContent}
          </div>
        )}

        {(isAdmin || (masters && masters.length > 0)) && (
          <div className="order-card-section">
            <span className="order-card-label">{t('Masters')}</span>
            <div className="order-card-value">
              {loadingMasters ? (
                <span>{t('Loading...')}</span>
              ) : masters && masters.length > 0 ? (
                masters.map((master, index) => (
                  <span key={master.id || index}>
                    {getMasterName(master)}
                    {index < masters.length - 1 ? ', ' : ''}
                  </span>
                ))
              ) : (
                <span>{t('Not Assigned')}</span>
              )}
            </div>
          </div>
        )}

        {!isUser && (
          <div className="order-card-section">
            <span className="order-card-label">{t('Client')}</span>
            {roles?.includes('ROLE_ADMIN') ? (
              clientUsername ? (
                <Link to={`/user/${clientUsername}`} className="order-card-link">
                  {clientFullName || clientUsername}
                </Link>
              ) : (
                <span className="order-card-value">{t('No data')}</span>
              )
            ) : (
              <span className="order-card-value">{clientFullName || t('Unknown')}</span>
            )}
            {roles?.includes('ROLE_BRIGADIER') && (
              <div className="order-card-value">
                <span className="order-card-label">{t('Phone')}:</span>
                <span>{order.clientPhone || t('No Phone')}</span>
              </div>
            )}
          </div>
        )}

{isUser && status !== 'REJECTED' && (
          <div className="order-card-actions">
            <button className="cancel-order-button" onClick={handleCancelOrder}>
              {t('Cancel Order')}
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default OrderCard;