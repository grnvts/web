import React, { useState, useEffect } from 'react';
import OrderService from '../Services/OrderService';
import { useTranslation } from 'react-i18next';
import Calendar from 'react-calendar';
import 'react-calendar/dist/Calendar.css';
import './Modal.css';
import './BrigadierPickerWithCalendar.css';

const BrigadierPickerWithCalendar = ({ onAssign }) => {
    const [brigadiers, setBrigadiers] = useState([]);
    const [selectedBrigadier, setSelectedBrigadier] = useState('');
    const [selectedDate, setSelectedDate] = useState(new Date());
    const [error, setError] = useState('');
    const [orderCounts, setOrderCounts] = useState({});
    const { t } = useTranslation();

    useEffect(() => {
        const fetchBrigadiers = async () => {
            try {
                const response = await OrderService.getAllBrigadiers();
                setBrigadiers(response.data);
            } catch (error) {
                console.error('Failed to load brigadiers', error);
                setError(t('Failed to load brigadiers'));
            }
        };

        fetchBrigadiers();
    }, [t]);

    useEffect(() => {
        const fetchOrderCounts = async () => {
            if (selectedBrigadier) {
                try {
                    const month = selectedDate.toISOString().slice(0, 7); // формат "YYYY-MM"
                    const response = await OrderService.getBrigadierCalendar(selectedBrigadier, month);
                    setOrderCounts(response.data);
                } catch (error) {
                    console.error('Failed to load order counts', error);
                }
            }
        };

        fetchOrderCounts();
    }, [selectedBrigadier, selectedDate]);

    const handleAssign = () => {
        if (!selectedBrigadier) {
            setError(t('Please select a brigadier'));
            return;
        }
        onAssign(selectedBrigadier);
    };

    const tileContent = ({ date }) => {
        const dateStr = date.toISOString().split('T')[0];
        const count = orderCounts[dateStr] || 0;
        return count > 0 ? (
            <div className="order-count-badge">{count}</div>
        ) : null;
    };

    return (
        <div className="modal-overlay">
            <div className="modal-container brigadier-picker-modal">
                <div className="modal-header">
                    <h3 className="modal-title">{t('Assign Brigadier')}</h3>
                    <button className="modal-close" onClick={() => onAssign(null)}>×</button>
                </div>
                <div className="modal-body">
                    {error && <div className="modal-error">{error}</div>}
                    <div className="brigadier-picker-content">
                        <div className="brigadier-picker-section">
                            <h4 className="brigadier-picker-section-title">{t('Select Brigadier')}</h4>
                            <select
                                className="modal-input"
                                value={selectedBrigadier}
                                onChange={(e) => setSelectedBrigadier(e.target.value)}
                            >
                                <option value="">{t('Select Brigadier')}</option>
                                {brigadiers.map((brigadier) => (
                                    <option key={brigadier.username} value={brigadier.username}>
                                        {brigadier.fullName && brigadier.fullName.replace(/null/g, '').trim() 
                                            ? brigadier.fullName.replace(/null/g, '').trim() 
                                            : brigadier.username}
                                    </option>
                                ))}
                            </select>
                        </div>
                        <div className="brigadier-picker-section">
                            <h4 className="brigadier-picker-section-title">{t('Select Date')}</h4>
                            <div className="calendar-container">
                                <Calendar
                                    onChange={setSelectedDate}
                                    value={selectedDate}
                                    minDate={new Date()}
                                    className="custom-calendar"
                                    tileContent={tileContent}
                                />
                            </div>
                        </div>
                    </div>
                </div>
                <div className="modal-footer">
                    <button className="modal-button modal-button-secondary" onClick={() => onAssign(null)}>
                        {t('Cancel')}
                    </button>
                    <button 
                        className="modal-button modal-button-primary" 
                        onClick={handleAssign}
                        disabled={!selectedBrigadier}
                    >
                        {t('Assign')}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default BrigadierPickerWithCalendar;