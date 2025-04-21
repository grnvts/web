import React from 'react';
import OrderStatusBadge from './OrderStatusBadge';
import { Link } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { format } from 'date-fns'; // Импортируем функцию format из date-fns

const OrderCard = ({ order }) => {
  const {
    serviceType,
    orderDetails,
    startDate,
    endDate,
    status,
    address = {}, // Дефолтное значение
    price,
    createdDate,
    brigadier,
    clientUsername = 'Unknown',
  } = order;

  const { t } = useTranslation();

  // Убедимся, что address не равен null или undefined
  const {
    street,
    city,
    apartmentNo,
    buildingNo,
  } = address || {};

  // Получаем роли текущего пользователя из Redux
  const roles = useSelector((state) => state.roles);

  // Проверяем, является ли пользователь администратором
  const isUser = roles?.includes('ROLE_USER');
  const isBrigadier = roles?.includes('ROLE_BRIGADIER');

  // Форматируем дату создания
  const formattedCreatedDate = createdDate
    ? format(new Date(createdDate), 'yyyy-MM-dd HH:mm:ss') // Пример формата: 2025-04-20 19:26:36
    : t('N/A');

  return (
    <div className="card mb-3">
      <div className="card-header">
        <h5>{t(serviceType)}</h5>
        <OrderStatusBadge status={t(status)} />
      </div>
      <div className="card-body">
        <p>
          <strong>{t('Order Details')}:</strong> {orderDetails}
        </p>
        <p>
          <strong>{t('Price')}:</strong> {price ? `${price} BYN ` : t('N/A')}
        </p>
        <p>
          <strong>{t('Created Date')}:</strong> {formattedCreatedDate}
        </p>
        <p>
          <strong>{t('Start Date')}:</strong> {startDate}
        </p>
        <p>
          <strong>{t('End Date')}:</strong> {endDate || t('N/A')}
        </p>
        <h6>{t('Address')}:</h6>
        <p>
          <strong>{t('City')}:</strong> {city || t('N/A')}
        </p>
        <p>
          <strong>{t('Street')}:</strong> {street || t('N/A')}
        </p>
        <p>
          <strong>{t('Building No')}:</strong> {buildingNo || t('N/A')}
        </p>
        <p>
          <strong>{t('Apartment No')}:</strong> {apartmentNo || t('N/A')}
        </p>
        {!isBrigadier && (
          <p>
            <strong>{t('Brigadier')}:</strong> {brigadier || t('Not Assigned')}
          </p>
        )}
        {!isUser && (
          <p>
            <strong>{t('Client')}:</strong>{' '}
            <Link
              to={`/user/${clientUsername}`}
              className="text-primary"
              style={{ textDecoration: 'underline' }}
            >
              {clientUsername || t('Unknown')}
            </Link>
          </p>
        )}
      </div>
    </div>
  );
};

export default OrderCard;