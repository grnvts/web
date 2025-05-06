import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import AdminOrderCard from '../../components/AdminOrderCard';
import OrderService from '../../Services/OrderService';
import AlertifyService from '../../Services/AlertifyService';
import { useTranslation } from 'react-i18next';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSort, faSortUp, faSortDown } from '@fortawesome/free-solid-svg-icons';
import './AllOrdersPage.css';

const AllOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sortConfig, setSortConfig] = useState({
    key: 'startDate',
    direction: 'desc'
  });
  const roles = useSelector((state) => state.roles);
  const history = useHistory();
  const { t } = useTranslation();

  // Проверяем, является ли пользователь администратором
  const isAdmin = roles?.includes('ROLE_ADMIN');

  useEffect(() => {
    if (!isAdmin) {
      history.push('/index'); // Перенаправляем на главную страницу
      return;
    }

    const fetchOrders = async () => {
      try {
        setLoading(true);
        const response = await OrderService.getAllOrders();
        setOrders(response.data);
      } catch (error) {
        AlertifyService.error(t('Failed to load orders'));
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [isAdmin, history, t]);

  const handleSort = (key) => {
    let direction = 'asc';
    if (sortConfig.key === key && sortConfig.direction === 'asc') {
      direction = 'desc';
    }
    setSortConfig({ key, direction });
  };

  const getSortedOrders = () => {
    const sortedOrders = [...orders];
    sortedOrders.sort((a, b) => {
      if (a[sortConfig.key] < b[sortConfig.key]) {
        return sortConfig.direction === 'asc' ? -1 : 1;
      }
      if (a[sortConfig.key] > b[sortConfig.key]) {
        return sortConfig.direction === 'asc' ? 1 : -1;
      }
      return 0;
    });
    return sortedOrders;
  };

  const getSortIcon = (key) => {
    if (sortConfig.key !== key) {
      return faSort;
    }
    return sortConfig.direction === 'asc' ? faSortUp : faSortDown;
  };

  if (loading) {
    return (
      <div className="orders-page">
        <div className="orders-container">
          <div className="loading-spinner">
            <FontAwesomeIcon icon="spinner" spin />
            <span>{t('Loading orders...')}</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="orders-page">
      <div className="orders-container">
        <div className="orders-header">
          <h1>{t('All Orders')}</h1>
          <p>{t('Manage and monitor all orders in the system')}</p>
        </div>
        <div className="orders-filters">
          <div className="sort-options">
            <button 
              className={`sort-button ${sortConfig.key === 'startDate' ? 'active' : ''}`}
              onClick={() => handleSort('startDate')}
            >
              {t('Date')}
              <FontAwesomeIcon icon={getSortIcon('startDate')} className="ms-2" />
            </button>
            <button 
              className={`sort-button ${sortConfig.key === 'status' ? 'active' : ''}`}
              onClick={() => handleSort('status')}
            >
              {t('Status')}
              <FontAwesomeIcon icon={getSortIcon('status')} className="ms-2" />
            </button>
          </div>
        </div>
        <div className="orders-grid">
          {getSortedOrders().length > 0 ? (
            getSortedOrders().map((order) => (
              <AdminOrderCard key={order.id} order={order} />
            ))
          ) : (
            <div className="no-orders">
              <FontAwesomeIcon icon="clipboard-list" />
              <p>{t('No orders found')}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AllOrdersPage;