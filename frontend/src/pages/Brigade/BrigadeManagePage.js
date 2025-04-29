import React, { useEffect, useState } from 'react';
import BrigadeService from '../../Services/BrigadeService';
import { useSelector } from 'react-redux';

const BrigadeManagePage = (props) => {
  // Всегда вызываем хуки вне условий!
  const reduxBrigadeId = useSelector(state => state.brigadeId);
  const userBrigadeId = useSelector(state => state.user?.brigadeId);
  const roles = useSelector(state => state.roles);
  const isBrigadier = roles?.includes('ROLE_BRIGADIER');
  

  // Выбираем id: приоритет — пропсы, потом redux, потом user
  const brigadeId = props.brigadeId || reduxBrigadeId || userBrigadeId;

  const [masters, setMasters] = useState([]);
  const [allMasters, setAllMasters] = useState([]);
  useEffect(() => {
    if (isBrigadier) {
      BrigadeService.getMyBrigadeMasters().then(res => setMasters(res.data));
    } else if (brigadeId) {
      BrigadeService.getBrigadeMasters(brigadeId).then(res => setMasters(res.data));
    }
    BrigadeService.getAllMasters().then(res => setAllMasters(res.data));
  }, [brigadeId, isBrigadier]);

  const handleAddMaster = (userId) => {
    if (isBrigadier) {
      BrigadeService.addMasterToMyBrigade(userId).then(() => {
        setMasters(prev => [...prev, allMasters.find(u => u.id === userId)]);
      });
    } else {
      BrigadeService.addMasterToBrigade(brigadeId, userId).then(() => {
        setMasters(prev => [...prev, allMasters.find(u => u.id === userId)]);
      });
    }
  };
  
  const handleRemoveMaster = (userId) => {
    if (isBrigadier) {
      BrigadeService.removeMasterFromMyBrigade(userId).then(() => {
        setMasters(prev => prev.filter(u => u.id !== userId));
      });
    } else {
      BrigadeService.removeMasterFromBrigade(brigadeId, userId).then(() => {
        setMasters(prev => prev.filter(u => u.id !== userId));
      });
    }
  };

  return (
    <div>
       <div>brigadeId: {brigadeId ? brigadeId : 'нет'}</div>
      <h3>Мастера в бригаде</h3>
      <ul>
        {masters.map(m => (
          <li key={m.id}>
            {m.name} ({m.username})
            <button onClick={() => handleRemoveMaster(m.id)}>Удалить</button>
          </li>
        ))}
      </ul>
      <h4>Добавить мастера</h4>
      <ul>
        {allMasters
          .filter(m => !masters.some(u => u.id === m.id))
          .map(m => (
            <li key={m.id}>
              {m.name} ({m.username})
              <button onClick={() => handleAddMaster(m.id)}>Добавить</button>
            </li>
          ))}
      </ul>
    </div>
  );
};

export default BrigadeManagePage;