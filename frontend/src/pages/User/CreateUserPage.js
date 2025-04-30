import React, { useState } from 'react';
import { useHistory } from 'react-router-dom';
import axios from 'axios';
import './CreateUserPage.css';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { 
  faArrowLeft, 
  faUser, 
  faUserTie, 
  faUserCog,
  faSpinner,
  faTimes,
  faCheck
} from '@fortawesome/free-solid-svg-icons';

const CreateUserPage = () => {
  const history = useHistory();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    username: '',
    password: '',
    firstName: '',
    lastName: '',
    patronymic: '',
    email: '',
    phoneNumber: '',
    birthDate: '',
    role: ''
  });
  const [error, setError] = useState('');

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      await axios.post('/api/users/create', formData);
      history.push('/users');
    } catch (err) {
      setError(err.response?.data?.message || 'Произошла ошибка при создании пользователя');
      setLoading(false);
    }
  };

  const handleCancel = () => {
    history.push('/users');
  };

  return (
    <div className="create-user-container">
      <div className="create-user-header">
        <h2>Создание нового пользователя</h2>
        <button className="back-button" onClick={handleCancel}>
          <FontAwesomeIcon icon={faArrowLeft} />
          Назад
        </button>
      </div>

      <form onSubmit={handleSubmit} className="create-user-form">
        <div className="form-grid">
          <div className="form-section">
            <h3>Основная информация</h3>
            <div className="form-group">
              <label htmlFor="username">Имя пользователя</label>
              <input
                type="text"
                id="username"
                name="username"
                className="form-control"
                value={formData.username}
                onChange={handleChange}
                required
                placeholder="Введите имя пользователя"
              />
            </div>
            <div className="form-group">
              <label htmlFor="password">Пароль</label>
              <input
                type="password"
                id="password"
                name="password"
                className="form-control"
                value={formData.password}
                onChange={handleChange}
                required
                placeholder="Введите пароль"
              />
            </div>
            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input
                type="email"
                id="email"
                name="email"
                className="form-control"
                value={formData.email}
                onChange={handleChange}
                required
                placeholder="Введите email"
              />
            </div>
            <div className="form-group">
              <label htmlFor="phoneNumber">Номер телефона</label>
              <input
                type="tel"
                id="phoneNumber"
                name="phoneNumber"
                className="form-control"
                value={formData.phoneNumber}
                onChange={handleChange}
                required
                placeholder="+7 (XXX) XXX-XX-XX"
              />
            </div>
          </div>

          <div className="form-section">
            <h3>Персональные данные</h3>
            <div className="form-group">
              <label htmlFor="lastName">Фамилия</label>
              <input
                type="text"
                id="lastName"
                name="lastName"
                className="form-control"
                value={formData.lastName}
                onChange={handleChange}
                required
                placeholder="Введите фамилию"
              />
            </div>
            <div className="form-group">
              <label htmlFor="firstName">Имя</label>
              <input
                type="text"
                id="firstName"
                name="firstName"
                className="form-control"
                value={formData.firstName}
                onChange={handleChange}
                required
                placeholder="Введите имя"
              />
            </div>
            <div className="form-group">
              <label htmlFor="patronymic">Отчество</label>
              <input
                type="text"
                id="patronymic"
                name="patronymic"
                className="form-control"
                value={formData.patronymic}
                onChange={handleChange}
                placeholder="Введите отчество"
              />
            </div>
            <div className="form-group">
              <label htmlFor="birthDate">Дата рождения</label>
              <input
                type="date"
                id="birthDate"
                name="birthDate"
                className="form-control"
                value={formData.birthDate}
                onChange={handleChange}
                required
              />
            </div>
          </div>
        </div>

        <div className="form-section roles-section">
          <h3>Роль пользователя</h3>
          <div className="roles-grid">
            <label className="role-option">
              <input
                type="radio"
                name="role"
                value="USER"
                checked={formData.role === 'USER'}
                onChange={handleChange}
              />
              <span className="role-label">
                <FontAwesomeIcon icon={faUser} />
                Пользователь
              </span>
            </label>
            <label className="role-option">
              <input
                type="radio"
                name="role"
                value="MASTER"
                checked={formData.role === 'MASTER'}
                onChange={handleChange}
              />
              <span className="role-label">
                <FontAwesomeIcon icon={faUserTie} />
                Мастер
              </span>
            </label>
            <label className="role-option">
              <input
                type="radio"
                name="role"
                value="ADMIN"
                checked={formData.role === 'ADMIN'}
                onChange={handleChange}
              />
              <span className="role-label">
                <FontAwesomeIcon icon={faUserCog} />
                Администратор
              </span>
            </label>
          </div>
        </div>

        {error && <div className="alert alert-danger">{error}</div>}

        <div className="form-actions">
          <button type="button" className="cancel-button" onClick={handleCancel}>
            <FontAwesomeIcon icon={faTimes} />
            Отмена
          </button>
          <button type="submit" className="submit-button" disabled={loading}>
            {loading ? (
              <>
                <FontAwesomeIcon icon={faSpinner} spin />
                Создание...
              </>
            ) : (
              <>
                <FontAwesomeIcon icon={faCheck} />
                Создать пользователя
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default CreateUserPage;