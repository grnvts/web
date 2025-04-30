import React, { useState, useEffect } from 'react';
import axios from 'axios';
import MasterSearchSelect from './MasterSearchSelect';
import { useTranslation } from 'react-i18next';
import './BrigadeManagement.css';

const BrigadeManagement = () => {
  const [brigades, setBrigades] = useState([]);
  const [selectedBrigade, setSelectedBrigade] = useState(null);
  const [selectedMasters, setSelectedMasters] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const { t } = useTranslation();

  useEffect(() => {
    fetchBrigades();
  }, []);

  const fetchBrigades = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/brigades');
      setBrigades(response.data);
    } catch (err) {
      setError(t('Error loading brigades'));
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleBrigadeSelect = (brigade) => {
    setSelectedBrigade(brigade);
    setSelectedMasters(brigade.masters || []);
  };

  const handleMastersSelect = (masters) => {
    setSelectedMasters(masters);
  };

  const handleSaveBrigade = async () => {
    if (!selectedBrigade) return;

    try {
      setLoading(true);
      await axios.put(`/api/brigades/${selectedBrigade.id}`, {
        ...selectedBrigade,
        masters: selectedMasters
      });
      await fetchBrigades();
      setError(null);
    } catch (err) {
      setError(t('Error saving brigade'));
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading && !brigades.length) {
    return (
      <div className="brigade-management-container">
        <div className="loading-spinner">
          <i className="fas fa-spinner fa-spin"></i>
          <span>{t('Loading...')}</span>
        </div>
      </div>
    );
  }

  return (
    <div className="brigade-management-container">
      <h2>{t('Brigade Management')}</h2>
      
      {error && <div className="error-message">{error}</div>}
      
      <div className="brigade-selection">
        <h3>{t('Select Brigade')}</h3>
        <div className="brigade-list">
          {brigades.map(brigade => (
            <div
              key={brigade.id}
              className={`brigade-item ${selectedBrigade?.id === brigade.id ? 'selected' : ''}`}
              onClick={() => handleBrigadeSelect(brigade)}
            >
              {brigade.name || t('Brigade')} #{brigade.id}
            </div>
          ))}
        </div>
      </div>

      {selectedBrigade && (
        <div className="brigade-details">
          <h3>{t('Edit Brigade')}: {selectedBrigade.name || `${t('Brigade')} #${selectedBrigade.id}`}</h3>
          
          <div className="masters-section">
            <h4>{t('Masters in Brigade')}</h4>
            <MasterSearchSelect
              selectedMasters={selectedMasters}
              onMastersChange={handleMastersSelect}
            />
          </div>

          <button
            className="save-button"
            onClick={handleSaveBrigade}
            disabled={loading}
          >
            {loading ? (
              <>
                <i className="fas fa-spinner fa-spin"></i>
                {t('Saving...')}
              </>
            ) : (
              t('Save Changes')
            )}
          </button>
        </div>
      )}
    </div>
  );
};

export default BrigadeManagement; 