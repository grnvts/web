import React from 'react';
import { useTranslation } from 'react-i18next';

const OrderCard = ({ order, onClick }) => {
  const { t } = useTranslation();
  const { id, serviceType, status, createdDate, price } = order;

  return (
    <div className="card mb-3" onClick={onClick} style={{ cursor: 'pointer' }}>
      <div className="card-header">
        <h5>{t(serviceType)}</h5>
      </div>
      <div className="card-body">
        <p>
          <strong>{t('Order ID')}:</strong> {id}
        </p>
        <p>
          <strong>{t('Status')}:</strong> {t(status)}
        </p>
        <p>
          <strong>{t('Created Date')}:</strong> {createdDate || t('N/A')}
        </p>
        <p>
          <strong>{t('Price')}:</strong> {price ? `${price} BYN` : t('N/A')}
        </p>
      </div>
    </div>
  );
};

export default OrderCard;