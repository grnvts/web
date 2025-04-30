import React, { useState, useEffect } from 'react';
import UserService from '../Services/UserService';
import AlertifyService from '../Services/AlertifyService';

const AddMasterModal = ({ onClose, onCreated }) => {
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
        if (response.data && Array.isArray(response.data)) {
          setQualifications(response.data);
        } else {
          setQualifications([]);
          console.error('Полученные данные не являются массивом:', response.data);
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
    if (!name) errs.name = 'Имя обязательно';
    if (!surname) errs.surname = 'Фамилия обязательна';
    if (!patronymic) errs.patronymic = 'Отчество обязательно';
    if (selectedQualifications.length === 0) errs.qualifications = 'Выберите хотя бы одну квалификацию';
    setErrors(errs);
    if (Object.keys(errs).length > 0) return;

    try {
      await UserService.createMaster({
        name,
        surname,
        patronymic,
        qualificationIds: selectedQualifications,
      });
      AlertifyService.success('Мастер создан');
      onCreated && onCreated();
    } catch (error) {
      AlertifyService.error('Ошибка при создании мастера');
    }
  };

  const handleQualificationChange = (id) => {
    setSelectedQualifications((prev) =>
      prev.includes(id)
        ? prev.filter(q => q !== id)
        : [...prev, id]
    );
  };

  return (
    <div className="modal show d-block" tabIndex="-1">
      <div className="modal-dialog">
        <div className="modal-content">
          <form onSubmit={handleSubmit}>
            <div className="modal-header">
              <h5 className="modal-title">Добавить мастера</h5>
              <button type="button" className="btn-close" onClick={onClose}></button>
            </div>
            <div className="modal-body">
              <div className="mb-2">
                <label>Имя *</label>
                <input className="form-control" value={name} onChange={e => setName(e.target.value)} />
                {errors.name && <div className="text-danger">{errors.name}</div>}
              </div>
              <div className="mb-2">
                <label>Фамилия *</label>
                <input className="form-control" value={surname} onChange={e => setSurname(e.target.value)} />
                {errors.surname && <div className="text-danger">{errors.surname} </div>}
              </div>
              <div className="mb-2">
                <label>Отчество *</label>
                <input className="form-control" value={patronymic} onChange={e => setPatronymic(e.target.value)} />
                {errors.patronymic && <div className="text-danger">{errors.patronymic}</div>}
              </div>
              <div className="mb-2">
                <label>Квалификации *</label>
                {loading ? (
                  <div>Загрузка квалификаций...</div>
                ) : (
                  <div>
                    {Array.isArray(qualifications) && qualifications.length > 0 ? (
                      qualifications.map(q => (
                        <label key={q.id} className="me-2">
                          <input
                            type="checkbox"
                            checked={selectedQualifications.includes(q.id)}
                            onChange={() => handleQualificationChange(q.id)}
                          />{' '}
                          {q.name}
                        </label>
                      ))
                    ) : (
                      <div className="text-warning">Нет доступных квалификаций</div>
                    )}
                  </div>
                )}
                {errors.qualifications && <div className="text-danger">{errors.qualifications}</div>}
              </div>
            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-secondary" onClick={onClose}>Отмена</button>
              <button type="submit" className="btn btn-success">Создать</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default AddMasterModal;