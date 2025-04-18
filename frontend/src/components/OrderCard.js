import React from 'react';
import OrderStatusBadge from './OrderStatusBadge';

const OrderCard = ({ order }) => {
  return (
    <div className="card mb-3">
      <div className="card-header">
        <h5>{order.serviceType}</h5>
        <OrderStatusBadge status={order.status} />
      </div>
      <div className="card-body">
        <p><strong>Building:</strong> {order.buildingName}</p>
        <p><strong>Details:</strong> {order.orderDetails}</p>
        <p><strong>Start Date:</strong> {order.startDate}</p>
        <p><strong>End Date:</strong> {order.endDate || 'N/A'}</p>
      </div>
    </div>
  );
};

export default OrderCard;