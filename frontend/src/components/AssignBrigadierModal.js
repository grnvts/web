import React, { useState, useEffect } from 'react';
import OrderService from '../Services/OrderService';
import { useTranslation } from 'react-i18next';
import './Modal.css';

const AssignBrigadierModal = ({ orderId, onClose, onSuccess }) => {
    const [brigadiers, setBrigadiers] = useState([]);
    const [selectedBrigadier, setSelectedBrigadier] = useState('');
    const [error, setError] = useState('');
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

    const handleAssign = async () => {
        try {
            await OrderService.assignBrigadier(orderId, selectedBrigadier);
            onSuccess();
            onClose();
        } catch (error) {
            console.error('Failed to assign brigadier', error);
            setError(t('Failed to assign brigadier'));
        }
    };

    return (
        <div className="modal-overlay">
            <div className="modal-container">
                <div className="modal-header">
                    <h3 className="modal-title">{t('Assign Brigadier')}</h3>
                    <button className="modal-close" onClick={onClose}>×</button>
                </div>
                <div className="modal-body">
                    {error && <div className="modal-error">{error}</div>}
                    <select
                        className="modal-input"
                        value={selectedBrigadier}
                        onChange={(e) => setSelectedBrigadier(e.target.value)}
                    >
                        <option value="">{t('Select Brigadier')}</option>
                        {brigadiers.map((brigadier) => (
                            <option key={brigadier.username} value={brigadier.username}>
                                {brigadier.username}
                            </option>
                        ))}
                    </select>
                </div>
                <div className="modal-footer">
                    <button className="modal-button modal-button-secondary" onClick={onClose}>
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

export default AssignBrigadierModal; 