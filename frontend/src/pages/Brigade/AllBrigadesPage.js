import React, { useEffect, useState } from 'react';
import BrigadeManagePage from './BrigadeManagePage';
import BrigadeService from '../../Services/BrigadeService';

// Импортируем модалку
import AddMasterModal from '../../components/AddMasterModal';

const AllBrigadesPage = () => {
  const [brigades, setBrigades] = useState([]);
  const [selectedBrigade, setSelectedBrigade] = useState(null);
  const [showAddMaster, setShowAddMaster] = useState(false);

  useEffect(() => {
    BrigadeService.getAllBrigades().then(res => setBrigades(res.data));
  }, []);

  return (
    <div>
      <h2>Все бригады</h2>
      <button className="btn btn-success mb-2" onClick={() => setShowAddMaster(true)}>
        Добавить мастера
      </button>
      <ul>
        {brigades.map(b => (
          <li key={b.id}>
            <button onClick={() => setSelectedBrigade(b.id)}>
              {b.name || `Бригада #${b.id}`}
            </button>
          </li>
        ))}
      </ul>
      {selectedBrigade && <BrigadeManagePage brigadeId={selectedBrigade} />}
      {showAddMaster && (
        <AddMasterModal
          onClose={() => setShowAddMaster(false)}
          onCreated={() => {
            setShowAddMaster(false);
            // Можно обновить список мастеров, если нужно
          }}
        />
      )}
    </div>
  );
};

export default AllBrigadesPage;