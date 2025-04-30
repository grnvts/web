import React, { useEffect, useState } from 'react';
import BrigadeManagePage from './BrigadeManagePage';
import BrigadeService from '../../Services/BrigadeService';
import { useTranslation } from 'react-i18next';
import './AllBrigadesPage.css';

// Импортируем модалку
import AddMasterModal from '../../components/AddMasterModal';

const AllBrigadesPage = () => {
  const [brigades, setBrigades] = useState([]);
  const [selectedBrigade, setSelectedBrigade] = useState(null);
  const [error, setError] = useState('');
  const { t } = useTranslation();

  useEffect(() => {
    const fetchBrigades = async () => {
      try {
        const response = await BrigadeService.getAllBrigades();
        console.log('Brigades response:', response);
        
        if (response && response.data) {
          setBrigades(response.data);
        } else {
          setError(t('No brigades found'));
          setBrigades([]);
        }
      } catch (error) {
        console.error('Failed to load brigades', error);
        setError(t('Failed to load brigades'));
        setBrigades([]);
      }
    };

    fetchBrigades();
  }, [t]);

  return (
    <div className="brigades-page">
      <div className="brigades-container">
        <h2 className="brigades-title">{t('All Brigades')}</h2>
        
        {error && <div className="error-message">{error}</div>}
        
        <div className="brigades-grid">
          {brigades.map(brigade => (
            <div key={brigade.id} className="brigade-card">
              <div className="brigade-info">
                <h3 className="brigade-name">
                  {brigade.brigadier?.fullName || brigade.brigadier?.username || `Brigade #${brigade.id}`}
                </h3>
                <p className="brigade-details">
                  {t('Masters')}: {brigade.masters?.length || 0}
                </p>
                <p className="brigade-number">
                  {t('Brigade Number')}: {brigade.number}
                </p>
              </div>
              <button 
                className="brigade-button"
                onClick={() => setSelectedBrigade(brigade.id)}
              >
                {t('Manage Brigade')}
              </button>
            </div>
          ))}
        </div>

        {selectedBrigade && (
          <div className="brigade-manage-section">
            <BrigadeManagePage brigadeId={selectedBrigade} />
          </div>
        )}
      </div>
    </div>
  );
};

export default AllBrigadesPage;