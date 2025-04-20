import React from 'react';
import OrderStatusBadge from './OrderStatusBadge';

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
  } = order;

  // Убедимся, что address не равен null или undefined
  const {
    street,
    city,
    apartmentNo,
    buildingNo,
  } = address || {};

  return (
    <div className="card mb-3">
      <div className="card-header">
        <h5>{serviceType}</h5>
        <OrderStatusBadge status={status} />
      </div>
      <div className="card-body">
        <p><strong>Order Details:</strong> {orderDetails}</p>
        <p><strong>Price:</strong> {price ? `$${price}` : 'N/A'}</p>
        <p><strong>Created Date:</strong> {createdDate}</p>
        <p><strong>Start Date:</strong> {startDate}</p>
        <p><strong>End Date:</strong> {endDate || 'N/A'}</p>
        <h6>Address:</h6>
        <p><strong>Street:</strong> {street || 'N/A'}</p>
        <p><strong>City:</strong> {city || 'N/A'}</p>
        <p><strong>Building No:</strong> {buildingNo || 'N/A'}</p>
        <p><strong>Apartment No:</strong> {apartmentNo || 'N/A'}</p>
      </div>
    </div>
  );
};

export default OrderCard;