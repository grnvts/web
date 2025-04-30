import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import UserService from '../Services/UserService'; // Для получения списка бригадиров
import AlertifyService from '../Services/AlertifyService';

const AdminOrderForm = ({ onSubmit, initialData }) => {
  const { t } = useTranslation();
  const [formData, setFormData] = useState({
    serviceType: initialData?.serviceType || '',
    address: {
      city: initialData?.address?.city || '',
      street: initialData?.address?.street || '',
      buildingNo: initialData?.address?.buildingNo || '',
      apartmentNo: initialData?.address?.apartmentNo || '',
    },
    orderDetails: initialData?.orderDetails || '',
    startDate: initialData?.startDate || '',
    endDate: initialData?.endDate || '',
    price: initialData?.price || '',
    status: initialData?.status || 'NEW',
  });

  const [errors, setErrors] = useState({});
  const [brigadiers, setBrigadiers] = useState([]);

  useEffect(() => {
    // Получение списка бригадиров
    const fetchBrigadiers = async () => {
      try {
        const response = await UserService.getBrigadiers();
        setBrigadiers(response.data);
      } catch (error) {
        console.error('Failed to fetch brigadiers', error);
      }
    };

    fetchBrigadiers();
  }, []);

  const validateDates = (startDate, endDate) => {
    if (startDate && endDate) {
      const start = new Date(startDate);
      const end = new Date(endDate);
      return end >= start;
    }
    return true;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    let newFormData;
    
    if (name.startsWith('address.')) {
      const field = name.split('.')[1];
      newFormData = {
        ...formData,
        address: { ...formData.address, [field]: value },
      };
    } else {
      newFormData = { ...formData, [name]: value };
    }

    // Валидация дат
    if (name === 'startDate' || name === 'endDate') {
      const startDate = name === 'startDate' ? value : newFormData.startDate;
      const endDate = name === 'endDate' ? value : newFormData.endDate;
      
      if (!validateDates(startDate, endDate)) {
        setErrors(prev => ({
          ...prev,
          endDate: t('End date cannot be earlier than start date')
        }));
      } else {
        setErrors(prev => {
          const newErrors = { ...prev };
          delete newErrors.endDate;
          return newErrors;
        });
      }
    }

    setFormData(newFormData);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Проверка дат перед отправкой
    if (!validateDates(formData.startDate, formData.endDate)) {
      AlertifyService.error(t('Please correct the dates'));
      return;
    }

    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="admin-order-form">
      <div className="form-group">
        <label>{t('Service Type')}</label>
        <select
          name="serviceType"
          className="form-control"
          value={formData.serviceType}
          onChange={handleChange}
          required
        >
          <option value="">{t('Select Service')}</option>
          <option value="electrician">{t('Electrician')}</option>
          <option value="plumbing">{t('Plumbing')}</option>
          <option value="painting">{t('Painting')}</option>
        </select>
      </div>

      <div className="form-group">
        <label>{t('City')}</label>
        <input
          type="text"
          name="address.city"
          className="form-control"
          value={formData.address.city}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-group">
        <label>{t('Street')}</label>
        <input
          type="text"
          name="address.street"
          className="form-control"
          value={formData.address.street}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-group">
        <label>{t('Building Number')}</label>
        <input
          type="text"
          name="address.buildingNo"
          className="form-control"
          value={formData.address.buildingNo}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-group">
        <label>{t('Apartment Number')}</label>
        <input
          type="text"
          name="address.apartmentNo"
          className="form-control"
          value={formData.address.apartmentNo}
          onChange={handleChange}
        />
      </div>

      <div className="form-group">
        <label>{t('Order Details')}</label>
        <textarea
          name="orderDetails"
          className="form-control"
          value={formData.orderDetails}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-group">
        <label>{t('Start Date')}</label>
        <input
          type="date"
          name="startDate"
          className="form-control"
          value={formData.startDate}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-group">
        <label>{t('End Date')}</label>
        <input
          type="date"
          name="endDate"
          className={`form-control ${errors.endDate ? 'is-invalid' : ''}`}
          value={formData.endDate}
          onChange={handleChange}
          min={formData.startDate}
        />
        {errors.endDate && (
          <div className="invalid-feedback">{errors.endDate}</div>
        )}
      </div>

      <div className="form-group">
        <label>{t('Price')}</label>
        <input
          type="number"
          name="price"
          className="form-control"
          value={formData.price}
          onChange={handleChange}
          required
          min="0"
        />
      </div>

      <div className="form-group">
        <label>{t('Status')}</label>
        <select
          name="status"
          className="form-control"
          value={formData.status}
          onChange={handleChange}
          required
        >
          <option value="CREATED">{t('Created')}</option>
          <option value="APPROVED">{t('Approved')}</option>
          <option value="IN_PROGRESS">{t('In Progress')}</option>
          <option value="COMPLETED">{t('Completed')}</option>

          <option value="REJECTED">{t('Rejected')}</option>
        </select>
      </div>

      <button type="submit" className="btn btn-primary">
        {t('Save')}
      </button>
    </form>
  );
};

export default AdminOrderForm;