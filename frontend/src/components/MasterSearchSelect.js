import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import './MasterSearchSelect.css';

const MasterSearchSelect = ({ masters, selectedMasters, onSelect, onRemove }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const { t } = useTranslation();

  const filteredMasters = masters.filter(master => {
    const fullName = `${master.name || ''} ${master.surname || ''}`.toLowerCase();
    return fullName.includes(searchTerm.toLowerCase()) || 
           master.username.toLowerCase().includes(searchTerm.toLowerCase());
  });

  const handleSelect = (master) => {
    onSelect(master);
    setIsOpen(false);
    setSearchTerm('');
  };

  return (
    <div className="master-search-container">
      <div className="master-search-input-container">
        <input
          type="text"
          className="master-search-input"
          placeholder={t('Search masters...')}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          onFocus={() => setIsOpen(true)}
        />
        <button 
          className="master-search-button"
          onClick={() => setIsOpen(!isOpen)}
        >
          {isOpen ? '▼' : '▲'}
        </button>
      </div>

      {isOpen && (
        <div className="master-search-dropdown">
          {filteredMasters.map(master => (
            <div 
              key={master.id}
              className="master-search-item"
              onClick={() => handleSelect(master)}
            >
              <span className="master-name">
                {master.fullName || master.username}
              </span>
            </div>
          ))}
        </div>
      )}

      <div className="selected-masters-list">
        {selectedMasters.map(master => (
          <div key={master.id} className="selected-master-item">
            <span className="selected-master-name">
              {master.fullName || master.username}
            </span>
            <button 
              className="remove-master-button"
              onClick={() => onRemove(master)}
            >
              ×
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};

export default MasterSearchSelect; 