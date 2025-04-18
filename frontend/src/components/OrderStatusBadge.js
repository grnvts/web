import React from 'react';

const OrderStatusBadge = ({ status }) => {
  const getBadgeClass = () => {
    switch (status) {
      case 'NEW':
        return 'badge badge-primary';
      case 'IN_PROGRESS':
        return 'badge badge-warning';
      case 'COMPLETED':
        return 'badge badge-success';
      case 'CANCELLED':
        return 'badge badge-danger';
      default:
        return 'badge badge-secondary';
    }
  };

  return <span className={getBadgeClass()}>{status}</span>;
};

export default OrderStatusBadge;