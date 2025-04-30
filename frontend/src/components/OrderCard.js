import React from 'react';
import OrderStatusBadge from './OrderStatusBadge';
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

  const {
    street,
    city,
    apartmentNo,
    buildingNo,
  } = address || {};

  const formattedCreatedDate = createdDate ? format(new Date(createdDate), 'yyyy-MM-dd HH:mm:ss') : t('N/A');
  const clientFullName = `${order.clientSurname || ''} ${order.clientName || ''} ${order.clientPatronymic || ''}`.trim();

  let brigadierContent;

  if (order.brigade) {
    if (order.brigade.brigadier) {
      const brigadierFullName = `${order.brigade.brigadier.brigadierSurname || ''} ${order.brigade.brigadier.brigadierName || ''} ${order.brigade.brigadier.brigadierPatronymic || ''}`.trim() + ` - ${order.brigade.brigadier.brigadierPhone || t('No Phone')}`;
      if (roles?.includes('ROLE_ADMIN')) {
        brigadierContent = (
          <Link to={`/user/${order.brigade.brigadier.username}`} className="order-card-link">
            {brigadierFullName}
          </Link>
        );
      } else {
        brigadierContent = <span className="order-card-value">{brigadierFullName}</span>;
      }
    } else {
      brigadierContent = <span className="order-card-value">{t('No data')}</span>;
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
      </div>
    </div>
  );
};

export default OrderCard;