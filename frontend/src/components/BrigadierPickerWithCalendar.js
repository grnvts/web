import OrderService from '../Services/OrderService';
import React, { useEffect, useState } from 'react';
import Calendar from 'react-calendar';
import { format } from 'date-fns';


const BrigadierPickerWithCalendar = ({ onAssign }) => {
  const [brigadiers, setBrigadiers] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [selected, setSelected] = useState(null);
  const [search, setSearch] = useState('');
  const [calendarData, setCalendarData] = useState({});
  const [month, setMonth] = useState(new Date());

  useEffect(() => {
    const loadBrigadiers = async () => {
      const res = await OrderService.getAllBrigadiers();
      setBrigadiers(res.data);
      setFiltered(res.data);
    };
    loadBrigadiers();
  }, []);

  useEffect(() => {
    if (selected) {
      const monthStr = format(month, 'yyyy-MM');
      OrderService.getBrigadierCalendar(selected.username, monthStr)
        .then(res => setCalendarData(res.data))
        .catch(error => {
          console.error('Failed to fetch calendar data:', error);
          setCalendarData({}); // Reset calendar data on error
        });
    }
  }, [selected, month]);

  const handleSearch = (e) => {
    const term = e.target.value.toLowerCase();
    setSearch(term);
    setFiltered(brigadiers.filter(b =>
      b.username.toLowerCase().includes(term) ||
      (b.name && b.name.toLowerCase().includes(term))
    ));
  };

  return (
    <div className="modal show d-block" tabIndex="-1">
      <div className="modal-dialog modal-lg">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Назначить бригадира</h5>
          </div>
          <div className="modal-body d-flex">
            <div className="w-50 pe-3">
              <input
                className="form-control mb-2"
                placeholder="Поиск по имени/логину"
                value={search}
                onChange={handleSearch}
              />
              <ul className="list-group overflow-auto" style={{ maxHeight: '300px' }}>
                {filtered.map(b => (
                  <li
                    key={b.username}
                    className={`list-group-item ${selected?.username === b.username ? 'active' : ''}`}
                    onClick={() => setSelected(b)}
                    style={{ cursor: 'pointer' }}
                  >
                    {b.name} ({b.username})
                  </li>
                ))}
              </ul>
            </div>
            <div className="w-50">
              {selected ? (
                <>
                  <p className="fw-bold">Загрузка заказов для {selected.username}</p>
                  <Calendar
                    onActiveStartDateChange={({ activeStartDate }) => setMonth(activeStartDate)}
                    tileContent={({ date }) => {
                      const dateStr = format(date, 'yyyy-MM-dd');
                      const count = calendarData[dateStr];
                      return count ? <div className="badge bg-primary">{count}</div> : null;
                    }}
                  />
                </>
              ) : (
                <p>Выберите бригадира</p>
              )}
            </div>
          </div>
          <div className="modal-footer">
            <button className="btn btn-secondary" onClick={() => onAssign(null)}>Отмена</button>
            <button
              className="btn btn-success"
              disabled={!selected}
              onClick={() => onAssign(selected.username)}
            >
              Назначить
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default BrigadierPickerWithCalendar;
