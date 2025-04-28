import React from 'react';
import { useTranslation } from 'react-i18next';
import { useHistory } from 'react-router-dom';

const CompactOrderCard = ({ order }) => {
  const { t } = useTranslation();
  const history = useHistory();

  const handleDetailsClick = () => {
    history.push(`/orders/${order.id}`);
  };

  return (
    <div className="card mb-3">
      <div className="card-body">
        <h5 className="card-title">{t('Order')} #{order.id}</h5>
        <p className="card-text">
          <strong>{t('Status')}:</strong> {t(order.status)}
        </p>
        <p className="card-text">
          <strong>{t('Created Date')}:</strong> {order.createdDate || t('N/A')}
        </p>
        <p className="card-text">
          <strong>{t('Price')}:</strong> {order.price ? `${order.price} BYN` : t('N/A')}
        </p>
        <button className="btn btn-primary" onClick={handleDetailsClick}>
          {t('View Details')}
        </button>
      </div>
    </div>
  );
};

export default CompactOrderCard;