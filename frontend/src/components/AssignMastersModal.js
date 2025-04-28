// components/AssignMastersModal.js
import React, { useEffect, useState } from 'react';
import UserService from '../Services/UserService';

const AssignMastersModal = ({ brigadeId, assignedMasters, onAssign, onClose }) => {
  const [masters, setMasters] = useState([]);
  const [selected, setSelected] = useState(assignedMasters?.map(m => m.id) || []);

  useEffect(() => {
    UserService.getBrigadeMasters(brigadeId).then(res => setMasters(res.data));
  }, [brigadeId]);

  const handleToggle = (id) => {
    setSelected(selected =>
      selected.includes(id) ? selected.filter(mid => mid !== id) : [...selected, id]
    );
  };

  return (
    <div className="modal show d-block">
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header"><h5>Назначить мастеров</h5></div>
          <div className="modal-body">
            <ul>
              {masters.map(m => (
                <li key={m.id}>
                  <label>
                    <input
                      type="checkbox"
                      checked={selected.includes(m.id)}
                      onChange={() => handleToggle(m.id)}
                    />
                    {m.name} ({m.username})
                  </label>
                </li>
              ))}
            </ul>
          </div>
          <div className="modal-footer">
            <button className="btn btn-secondary" onClick={onClose}>Отмена</button>
            <button className="btn btn-success" onClick={() => onAssign(selected)}>Назначить</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AssignMastersModal;