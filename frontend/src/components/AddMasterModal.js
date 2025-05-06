import React, { useState, useEffect } from 'react';
import { withTranslation } from 'react-i18next';
import UserService from '../Services/UserService';
import AlertifyService from '../Services/AlertifyService';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTimes, faCheck, faSpinner } from '@fortawesome/free-solid-svg-icons';
import './AddMasterModal.css';

const AddMasterModal = ({ onClose, onCreated, t }) => {
  const [name, setName] = useState('');
  const [surname, setSurname] = useState('');
  const [patronymic, setPatronymic] = useState('');
  const [qualifications, setQualifications] = useState([]);
  const [selectedQualifications, setSelectedQualifications] = useState([]);
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchQualifications = async () => {
      try {
        setLoading(true);
        const response = await UserService.getQualifications();
        console.log('Ответ сервера:', response);
        
        if (response && response.data) {
          const qualifications = Array.isArray(response.data) 
            ? response.data 
            : JSON.parse(response.data);
            
          if (Array.isArray(qualifications)) {
            setQualifications(qualifications);
          } else {
            console.error('Некорректный формат данных:', qualifications);
            setQualifications([]);
          }
        } else {
          console.error('Нет данных в ответе:', response);
          setQualifications([]);
        }
      } catch (error) {
        console.error('Ошибка при загрузке квалификаций:', error);
        setQualifications([]);
      } finally {
        setLoading(false);
      }
    };

    fetchQualifications();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    let errs = {};
    if (!name) errs.name = t('Name is required');
    if (!surname) errs.surname = t('Surname is required');
    if (!patronymic) errs.patronymic = t('Patronymic is required');
    if (selectedQualifications.length === 0) errs.qualifications = t('Select at least one qualification');
    setErrors(errs);
    if (Object.keys(errs).length > 0) return;

    try {
      await UserService.createMaster({
        name,
        surname,
        patronymic,
        qualificationIds: selectedQualifications,
      });
      AlertifyService.success(t('Master created successfully'));
      onCreated && onCreated();
    } catch (error) {
      AlertifyService.error(t('Failed to create master'));
    }
  };

  const handleQualificationChange = (id) => {
    setSelectedQualifications((prev) =>
      prev.includes(id)
        ? prev.filter(q => q !== id)
        : [...prev, id]
    );
  };

  const getQualificationTranslation = (name) => {
    const translations = {
      'electrician': t('Electrician'),
      'plumber': t('Plumber'),
      'carpenter': t('Carpenter'),
      'labourer': t('labourer'),
      'tiler': t('tiler'),
      'painter': t('painter'),
      'plasterer': t('plasterer'),
      'roofer': t('Roofer')
    };
    return translations[name] || name;
  };

  return (
    <div className="modal show d-block" tabIndex="-1">
      <div className="modal-dialog modal-dialog-centered">
        <div className="modal-content">
          <form onSubmit={handleSubmit}>
            <div className="modal-header">
              <h5 className="modal-title">{t('Add Master')}</h5>
              <button type="button" className="btn-close" onClick={onClose}></button>
            </div>
            <div className="modal-body">
              <div className="mb-3">
                <label className="form-label">{t('Name')} *</label>
                <input 
                  className={`form-control ${errors.name ? 'is-invalid' : ''}`} 
                  value={name} 
                  onChange={e => setName(e.target.value)} 
                />
                {errors.name && <div className="invalid-feedback">{errors.name}</div>}
              </div>
              <div className="mb-3">
                <label className="form-label">{t('Surname')} *</label>
                <input 
                  className={`form-control ${errors.surname ? 'is-invalid' : ''}`} 
                  value={surname} 
                  onChange={e => setSurname(e.target.value)} 
                />
                {errors.surname && <div className="invalid-feedback">{errors.surname}</div>}
              </div>
              <div className="mb-3">
                <label className="form-label">{t('Patronymic')} *</label>
                <input 
                  className={`form-control ${errors.patronymic ? 'is-invalid' : ''}`} 
                  value={patronymic} 
                  onChange={e => setPatronymic(e.target.value)} 
                />
                {errors.patronymic && <div className="invalid-feedback">{errors.patronymic}</div>}
              </div>
              <div className="mb-3">
                <label className="form-label">{t('Qualifications')} *</label>
                {loading ? (
                  <div className="text-center">
                    <FontAwesomeIcon icon={faSpinner} spin className="me-2" />
                    {t('Loading qualifications...')}
                  </div>
                ) : (
                  <div className="qualifications-grid">
                    {qualifications.map(q => (
                      <div key={q.id} className="qualification-item">
                        <input
                          type="checkbox"
                          id={`qual-${q.id}`}
                          checked={selectedQualifications.includes(q.id)}
                          onChange={() => handleQualificationChange(q.id)}
                          className="form-check-input"
                        />
                        <label htmlFor={`qual-${q.id}`} className="form-check-label">
                          {getQualificationTranslation(q.name)}
                        </label>
                      </div>
                    ))}
                  </div>
                )}
                {errors.qualifications && <div className="text-danger mt-2">{errors.qualifications}</div>}
              </div>
            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-secondary" onClick={onClose}>
                <FontAwesomeIcon icon={faTimes} className="me-2" />
                {t('Cancel')}
              </button>
              <button type="submit" className="btn btn-primary">
                <FontAwesomeIcon icon={faCheck} className="me-2" />
                {t('Create')}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default withTranslation()(AddMasterModal);