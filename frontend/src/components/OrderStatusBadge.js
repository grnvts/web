import React from 'react';
import { useTranslation } from 'react-i18next';

const OrderStatusBadge = ({ status }) => {
  const getBadgeClass = () => {
    switch (status) {
      case 'CREATED':
        return 'badge badge-primary';
      case 'IN_PROGRESS':
        return 'badge badge-warning';
      case 'COMPLETED':
        return 'badge badge-success';
      case 'CANCELLED':
        return 'badge badge-danger';
      case 'APPROVED':
        return 'badge badge-info';
      default:
        return 'badge badge-secondary';
    }
  };

  return <span className={getBadgeClass()}>{status}</span>;
};

export default OrderStatusBadge;