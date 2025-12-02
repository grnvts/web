import React, { Component } from 'react'
import { withTranslation } from 'react-i18next';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { logoutAction } from '../redux/AuthenticationAction';
import AlertifyService from '../Services/AlertifyService';
import ApiService from '../Services/BaseService/ApiService';
import UserService from '../Services/UserService';
import Input from './input';
import { updateUser } from '../redux/AuthenticationAction';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
    faSave,
    faTimes,
    faUser,
    faEnvelope,
    faPhone,
    faLock,
    faIdCard
} from '@fortawesome/free-solid-svg-icons';
import './UpdateUserForm.css';

class UpdateUserForm extends Component {
    constructor(props) {
        super(props);
        this.state = {
            id: null,
            username: '',
            email: '',
            name: '',
            surname: '',
            patronymic: '',
            phone: '',
            errors: {}
        };
    }

    componentDidMount() {
        const { user } = this.props;
        this.loadInputs(user);
    }

    loadInputs = (user) => {
        console.log("Editing user:", user);
        this.setState({ ...user });
    }

    onChangeData = (type, event) => {
        this.setState(prevState => ({
            ...prevState,
            [type]: event,
            errors: {
                ...prevState.errors,
                [type]: undefined
            }
        }));
    }

    onClickSave = async (e) => {
        e.preventDefault();
        this.setState({ errors: {} });
    
        // Валидация обязательных полей
        const { name, surname, patronymic, password, repeatPassword } = this.state;
        const validationErrors = {};
    
        if (!name || name.trim() === '') {
            validationErrors.name = 'Имя обязательно для заполнения';
        }
        if (!surname || surname.trim() === '') {
            validationErrors.surname = 'Фамилия обязательна для заполнения';
        }
        if (!patronymic || patronymic.trim() === '') {
            validationErrors.patronymic = 'Отчество обязательно для заполнения';
        }
        
        // Валидация пароля, если он указан
        if (password && password.trim() !== '') {
            if (!repeatPassword || repeatPassword.trim() === '') {
                validationErrors.repeatPassword = 'Повторите пароль';
            } else if (password !== repeatPassword) {
                validationErrors.repeatPassword = 'Пароли не совпадают';
            }
        } else if (repeatPassword && repeatPassword.trim() !== '') {
            validationErrors.password = 'Введите пароль';
        }
    
        if (Object.keys(validationErrors).length > 0) {
            this.setState({ errors: validationErrors });
            return;
        }
    
        // Подготавливаем данные для отправки
        const { id, username, email, phone, bornDate } = this.state;
        const body = {
            id,
            username,
            email,
            name: name.trim(),
            surname: surname.trim(),
            patronymic: patronymic.trim(),
            phone: phone || null,
            bornDate: bornDate || null,
            password: password || null,
            repeatPassword: repeatPassword || null
        };
    
        try {
            await UserService.update(this.props.user.username, body, this.props.jwttoken);
    
            // Перезагрузка страницы после успешной отправки
            window.location.reload();
        } catch (error) {
            AlertifyService.error("An error occurred while updating the user.");
        }
    };
        

    render() {
        const { t } = this.props;
        const { username, email, name, surname, patronymic, phone, bornDate, password, repeatPassword } = this.state;
        const { errors } = this.state;
        const isAdmin = this.props.isAdminEditingOtherUser;

        return (
            <div className="update-user-form-container">
                {this.props.inEditMode && (
                    <form className="update-user-form">
                        <div className="form-header">
                            <h3>
                                <FontAwesomeIcon icon={faUser} className="header-icon" />
                                {t("Update Profile")}
                            </h3>
                        </div>

                        <div className="form-grid">
                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faIdCard} />
                                    {t("Username")}
                                </label>
                                <Input
                                    error={errors.username}
                                    type="text"
                                    name="username"
                                    placeholder={t("Username")}
                                    valueName={username}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faEnvelope} />
                                    {t("Email")}
                                </label>
                                <Input
                                    error={errors.email}
                                    type="email"
                                    name="email"
                                    placeholder={t("Email")}
                                    valueName={email}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faUser} />
                                    {t("Name")}
                                </label>
                                <Input
                                    error={errors.name}
                                    type="text"
                                    name="name"
                                    placeholder={t("Name")}
                                    valueName={name}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faUser} />
                                    {t("Surname")}
                                </label>
                                <Input
                                    error={errors.surname}
                                    type="text"
                                    name="surname"
                                    placeholder={t("Surname")}
                                    valueName={surname}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faUser} />
                                    {t("Patronymic")}
                                </label>
                                <Input
                                    error={errors.patronymic}
                                    type="text"
                                    name="patronymic"
                                    placeholder={t("Patronymic")}
                                    valueName={patronymic}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faPhone} />
                                    {t("Phone")}
                                </label>
                                <Input
                                    type="text"
                                    name="phone"
                                    placeholder={t("Phone")}
                                    valueName={phone}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>{t("Born Date")}</label>
                                <Input
                                    type="date"
                                    name="bornDate"
                                    placeholder={t("Born Date")}
                                    valueName={bornDate?.slice(0, 10)}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faLock} />
                                    {t("Password (leave empty if you dont want to change it)")}
                                </label>
                                <Input
                                    error={errors.password}
                                    type="password"
                                    name="password"
                                    placeholder={t("New Password ")}
                                    onChangeData={this.onChangeData}
                                />
                            </div>

                            <div className="form-group">
                                <label>
                                    <FontAwesomeIcon icon={faLock} />
                                    {t("Repeat Password")}
                                </label>
                                <Input
                                    error={errors.repeatPassword}
                                    type="password"
                                    name="repeatPassword"
                                    placeholder={t("Repeat Password")}
                                    onChangeData={this.onChangeData}
                                />
                            </div>
                        </div>

                        <div className="form-actions">
                            <button
                                type="button"
                                className="cancel-button"
                                onClick={() => this.props.showUpdateForm(false)}>
                                <FontAwesomeIcon icon={faTimes} />
                                {t('Cancel')}
                            </button>
                            <button
                                type="submit"
                                className="save-button"
                                onClick={this.onClickSave}>
                                <FontAwesomeIcon icon={faSave} />
                                {t('Save Changes')}
                            </button>
                        </div>
                    </form>
                )}
            </div>
        );
    }
}

const mapStateToProps = (store) => {
    return {
        isLoggedIn: store.isLoggedIn,
        username: store.username,
        email: store.email,
        jwttoken: store.jwttoken,
        password: store.password,
        image: store.image
    };
};

export default connect(mapStateToProps)(withTranslation()(withRouter(UpdateUserForm)));