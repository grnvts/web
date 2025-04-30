import React from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import './CompactOrderCard.css';

const CompactOrderCard = ({ order }) => {
    const { t } = useTranslation();

    const getStatusClass = (status) => {
        switch (status) {
            case 'CREATED':
                return 'status-created';
            case 'IN_PROGRESS':
                return 'status-in-progress';
            case 'COMPLETED':
                return 'status-completed';
            case 'APPROVED':
                return 'status-approved';
            case 'REJECTED':
                return 'status-rejected';
            default:
                return '';
        }
    };

    const formatDate = (dateString) => {
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Date(dateString).toLocaleDateString(undefined, options);
    };

    const formatAddress = (address) => {
        if (!address) return t('N/A');
        return `${address.city}, ${address.street} ${address.buildingNo}, кв. ${address.apartmentNo}`;
    };

    return (
        <div className="compact-order-card">
            <div className="compact-order-header">
                <h3 className="order-title">{t('Order')} #{order.id}</h3>
                <span className={`status-badge ${getStatusClass(order.status)}`}>
                    {t(order.status)}
                </span>
            </div>
            <div className="compact-order-content">
                <div className="info-item">
                    <i className="fas fa-map-marker-alt"></i>
                    <div className="info-label">{t('Address')}:</div>
                    <div className="info-value">{formatAddress(order.address)}</div>
                </div>
                <div className="info-item">
                    <i className="fas fa-calendar-alt"></i>
                    <div className="info-label">{t('Start Date')}:</div>
                    <div className="info-value">{formatDate(order.startDate)}</div>
                </div>
                <div className="info-item">
                    <i className="fas fa-tools"></i>
                    <div className="info-label">{t('Service Type')}:</div>
                    <div className="info-value">{t(order.serviceType)}</div>
                </div>
            </div>
            <div className="compact-order-actions">
                <Link to={`/orders/${order.id}`} className="view-details-btn">
                    <i className="fas fa-eye"></i>
                    {t('View Details')}
                </Link>
            </div>
        </div>
    );
};

export default CompactOrderCard;