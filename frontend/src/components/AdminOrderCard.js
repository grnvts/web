import React from 'react';
import { useTranslation } from 'react-i18next';
import { useHistory } from 'react-router-dom';

const AdminOrderCard = ({ order }) => {
  const { t } = useTranslation();
  const history = useHistory();

  const handleDetailsClick = () => {
    history.push(`/orders/${order.id}`);
  };

  const handleClientClick = () => {
    history.push(`/user/${order.clientUsername}`);
  };

  return (
    <div className="card mb-3">
      <div className="card-body">
        <h5 className="card-title">{t('Order')} #{order.id}</h5>
        <p className="card-text">
          <strong>{t('Address')}:</strong> {order.address?.city}, {order.address?.street}, {order.address?.buildingNo}
        </p>
        <p className="card-text">
          <strong>{t('Status')}:</strong> {t(order.status)}
        </p>
        <p className="card-text">
          <strong>{t('Start Date')}:</strong> {order.startDate || t('N/A')}
        </p>
        <p className="card-text">
          <strong>{t('Brigadier')}:</strong> {order.brigadier || t('Not Assigned')}
        </p>
        <p className="card-text">
          <strong>{t('Client')}:</strong>{' '}
          <span
            className="text-primary"
            style={{ cursor: 'pointer', textDecoration: 'underline' }}
            onClick={handleClientClick}
          >
            {order.clientUsername || t('Unknown')}
          </span>
        </p>
        <button className="btn btn-primary" onClick={handleDetailsClick}>
          {t('View Details')}
        </button>
      </div>
    </div>
  );
};

export default AdminOrderCard;