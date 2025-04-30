import React, { useEffect, useState } from 'react';
import BrigadeService from '../../Services/BrigadeService';
import { useSelector } from 'react-redux';
import './BrigadeManagePage.css';

const BrigadeManagePage = (props) => {
  const reduxBrigadeId = useSelector(state => state.brigadeId);
  const userBrigadeId = useSelector(state => state.user?.brigadeId);
  const roles = useSelector(state => state.roles);
  const isBrigadier = roles?.includes('ROLE_BRIGADIER');

  const brigadeId = props.brigadeId || reduxBrigadeId || userBrigadeId;

  const [masters, setMasters] = useState([]);
  const [allMasters, setAllMasters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [mastersData, allMastersData] = await Promise.all([
          isBrigadier 
            ? BrigadeService.getMyBrigadeMasters()
            : BrigadeService.getBrigadeMasters(brigadeId),
          BrigadeService.getAllMasters()
        ]);
        
        setMasters(mastersData.data);
        setAllMasters(allMastersData.data);
      } catch (err) {
        setError('Ошибка при загрузке мастеров');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    if (isBrigadier || brigadeId) {
      fetchData();
    }
  }, [brigadeId, isBrigadier]);

  const handleAddMaster = async (userId) => {
    try {
      if (isBrigadier) {
        await BrigadeService.addMasterToMyBrigade(userId);
      } else {
        await BrigadeService.addMasterToBrigade(brigadeId, userId);
      }
      setMasters(prev => [...prev, allMasters.find(u => u.id === userId)]);
    } catch (err) {
      setError('Ошибка при добавлении мастера');
      console.error(err);
    }
  };
  
  const handleRemoveMaster = async (userId) => {
    try {
      if (isBrigadier) {
        await BrigadeService.removeMasterFromMyBrigade(userId);
      } else {
        await BrigadeService.removeMasterFromBrigade(brigadeId, userId);
      }
      setMasters(prev => prev.filter(u => u.id !== userId));
    } catch (err) {
      setError('Ошибка при удалении мастера');
      console.error(err);
    }
  };

  const filteredAvailableMasters = allMasters
    .filter(m => !masters.some(u => u.id === m.id))
    .filter(m => {
      const searchLower = searchQuery.toLowerCase();
      const fullName = `${m.name || ''} ${m.surname || ''}`.toLowerCase();
      const username = m.username.toLowerCase();
      return fullName.includes(searchLower) || username.includes(searchLower);
    });

  if (loading) {
    return (
      <div className="brigade-manage-container">
        <div className="loading-spinner">
          <i className="fas fa-spinner fa-spin"></i>
          <span>Загрузка...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="brigade-manage-container">
      <div className="brigade-manage-header">
        <h2>Управление бригадой</h2>
        <p className="brigade-id">
          ID бригады: {brigadeId ? `#${brigadeId}` : 'Не назначена'}
        </p>
      </div>

      {error && (
        <div className="error-message">
          {error}
        </div>
      )}

      <div className="masters-section">
        <div className="current-masters">
          <h3>Мастера в бригаде</h3>
          {masters.length === 0 ? (
            <p className="no-masters">В бригаде пока нет мастеров</p>
          ) : (
            <div className="masters-grid">
              {masters.map(master => (
                <div key={master.id} className="master-card">
                  <div className="master-info">
                    <span className="master-name">
                      {master.name} {master.surname}
                    </span>
                    <span className="master-username">@{master.username}</span>
                  </div>
                  <button 
                    className="remove-master-btn"
                    onClick={() => handleRemoveMaster(master.id)}
                  >
                    <i className="fas fa-times"></i>
                    Удалить
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="available-masters">
          <h3>Доступные мастера</h3>
          <div className="search-container">
            <input
              type="text"
              className="search-input"
              placeholder="Поиск по ФИО или логину..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            <i className="fas fa-search search-icon"></i>
          </div>
          <div className="masters-grid">
            {filteredAvailableMasters.length === 0 ? (
              <p className="no-masters">
                {searchQuery 
                  ? 'Мастера не найдены' 
                  : 'Нет доступных мастеров'}
              </p>
            ) : (
              filteredAvailableMasters.map(master => (
                <div key={master.id} className="master-card">
                  <div className="master-info">
                    <span className="master-name">
                      {master.name} {master.surname}
                    </span>
                    <span className="master-username">@{master.username}</span>
                  </div>
                  <button 
                    className="add-master-btn"
                    onClick={() => handleAddMaster(master.id)}
                  >
                    <i className="fas fa-plus"></i>
                    Добавить
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default BrigadeManagePage;