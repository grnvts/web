import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import UserService from '../Services/UserService'; // Для получения списка бригадиров


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
    brigadier: initialData?.brigadierUsername || '',
  });

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

  const handleChange = (e) => {
    const { name, value } = e.target;
    if (name.startsWith('address.')) {
      const field = name.split('.')[1];
      setFormData((prev) => ({
        ...prev,
        address: { ...prev.address, [field]: value },
      }));
    } else {
      setFormData({ ...formData, [name]: value });
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
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
          className="form-control"
          value={formData.endDate}
          onChange={handleChange}
        />
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
          <option value="IN_PROGRESS">{t('In Progress')}</option>
          <option value="COMPLETED">{t('Completed')}</option>
          <option value="CANCELLED">{t('Cancelled')}</option>
          <option value="REJECTED">{t('Rejected')}</option>
        </select>
      </div>

      <div className="form-group">
        <label>{t('Brigadier')}</label>
        <select
          name="brigadier"
          className="form-control"
          value={formData.brigadier}
          onChange={handleChange}
        >
          <option value="">{t('Select Brigadier')}</option>
          {brigadiers.map((brigadier) => (
            <option key={brigadier.id} value={brigadier.username}>
              {brigadier.name}
            </option>
          ))}
        </select>
      </div>

      <button type="submit" className="btn btn-primary">
        {t('Save')}
      </button>
    </form>
  );
};

export default AdminOrderForm;