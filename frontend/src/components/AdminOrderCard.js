import React from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import './AdminOrderCard.css';

const AdminOrderCard = ({ order }) => {
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

    const getClientName = (order) => {
        if (!order.clientId) return t('Unknown');
        
        const name = order.clientName || '';
        const surname = order.clientSurname || '';
        const patronymic = order.clientPatronymic || '';
        
        if (name || surname) {
            return `${surname} ${name} ${patronymic}`.trim();
        }
        
        return order.clientUsername || t('Unknown');
    };

    const getBrigadierName = (order) => {
        if (!order.brigadierId) return t('Not Assigned');
        
        const name = order.brigadierName || '';
        const surname = order.brigadierSurname || '';
        const patronymic = order.brigadierPatronymic || '';
        
        if (name || surname) {
            return `${surname} ${name} ${patronymic}`.trim();
        }
        
        return order.brigadierUsername || t('Not Assigned');
    };

    return (
        <div className="order-card">
            <div className="order-card-header">
                <h3 className="order-title">{t('Order')} #{order.id}</h3>
                <span className={`status-badge ${getStatusClass(order.status)}`}>
                    {t(order.status)}
                </span>
            </div>
            <div className="order-card-content">
                <div className="order-info">
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
                        <i className="fas fa-user"></i>
                        <div className="info-label">{t('Client')}:</div>
                        <div className="info-value">{getClientName(order)}</div>
                    </div>
                    <div className="info-item">
                        <i className="fas fa-hard-hat"></i>
                        <div className="info-label">{t('Brigadier')}:</div>
                        <div className="info-value">{getBrigadierName(order)}</div>
                    </div>
                </div>
                <div className="order-actions">
                    <Link to={`/orders/${order.id}`} className="view-details-btn">
                        <i className="fas fa-eye"></i>
                        {t('View Details')}
                    </Link>
                </div>
            </div>
        </div>
    );
};

export default AdminOrderCard;