import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { 
  faSave,
  faMapMarkerAlt,
  faTools,
  faCalendarAlt
} from '@fortawesome/free-solid-svg-icons';
import './OrderForm.css';

const OrderForm = ({ onSubmit }) => {
  const { t } = useTranslation();
  const [formData, setFormData] = useState({
    serviceType: '',
    address: {
      city: '',
      street: '',
      buildingNo: '',
      apartmentNo: ''
    },
    orderDetails: '',
    startDate: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    if (name.startsWith('address.')) {
      const field = name.split('.')[1];
      setFormData((prev) => ({
        ...prev,
        address: { ...prev.address, [field]: value }
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
    <form onSubmit={handleSubmit} className="create-order-form">
      <div className="form-grid">
        <div className="form-section">
          <h3>
            <FontAwesomeIcon icon={faTools} className="section-icon" />
            {t('Service Information')}
          </h3>
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
            <label>{t('Order Details')}</label>
            <textarea
              name="orderDetails"
              className="form-control"
              value={formData.orderDetails}
              onChange={handleChange}
              required
              rows="4"
              placeholder={t('Describe the problem or service needed')}
            />
          </div>
        </div>

        <div className="form-section">
          <h3>
            <FontAwesomeIcon icon={faMapMarkerAlt} className="section-icon" />
            {t('Address Information')}
          </h3>
          <div className="form-group">
            <label>{t('City')}</label>
            <input
              type="text"
              name="address.city"
              className="form-control"
              value={formData.address.city}
              onChange={handleChange}
              required
              placeholder={t('Enter city')}
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
              placeholder={t('Enter street')}
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
              placeholder={t('Enter building number')}
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
              placeholder={t('Enter apartment number')}
            />
          </div>
        </div>
      </div>

      <div className="form-section">
        <h3>
          <FontAwesomeIcon icon={faCalendarAlt} className="section-icon" />
          {t('Schedule')}
        </h3>
        <div className="form-group">
          <label>{t('Preferred Start Date')}</label>
          <input
            type="date"
            name="startDate"
            className="form-control"
            value={formData.startDate}
            onChange={handleChange}
            required
            min={new Date().toISOString().split('T')[0]}
          />
        </div>
      </div>

      <div className="form-actions">
        <button type="submit" className="submit-button">
          <FontAwesomeIcon icon={faSave} />
          {t('Create Order')}
        </button>
      </div>
    </form>
  );
};

export default OrderForm;