import React, { Component } from 'react';
import Input from '../../components/input';
import { withTranslation } from 'react-i18next';
import { signupHandler } from '../../redux/AuthenticationAction';
import { connect } from 'react-redux';
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import './UserSignupPage.css';

class UserSignupPage extends Component {
    constructor(props) {
        super(props);
        this.state = {
            id: null,
            username: '',
            email: '',
            password: '',
            repeatPassword: "",
            name: '',
            surname: '',
            patronymic: '',
            phone: '',
            bornDate: new Date(), 
            errors: {}
        };

        this.emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        this.phonePattern = /^\+\d{11,14}$/;
        this.namePattern = /^[\p{L}\s'-]+$/u;
    }

    onChangeData = (type, event) => {
        const { t } = this.props;
        const stateData = this.state;
        stateData[type] = event;
        const errors = { ...this.state.errors };
        errors[type] = undefined;

        if (type === 'password' || type === "repeatPassword") {
            if (type === 'password' && event !== this.state.repeatPassword) {
                errors.repeatPassword = t('Password mismatch');
            } else if (type === 'repeatPassword' && event !== this.state.password) {
                errors.repeatPassword = t('Password mismatch');
            } else {
                errors.repeatPassword = undefined;
            }
        }
        this.setState({ stateData, errors });
    }

    onClickSignUp = async (e) => {
        e.preventDefault();
        const { t } = this.props;
        const clientErrors = {};
        const { username, email, password, repeatPassword, name, surname, patronymic, phone } = this.state;

        if (!this.emailPattern.test(email.trim())) {
            clientErrors.email = t('Invalid email format');
        }

        if (phone && phone.trim() && !this.phonePattern.test(phone.trim())) {
            clientErrors.phone = t('Invalid phone format');
        }

        ['name', 'surname', 'patronymic'].forEach((field) => {
            const value = this.state[field];
            if (value && value.trim() && !this.namePattern.test(value.trim())) {
                clientErrors[field] = t('Name can contain only letters');
            }
        });

        if (!username.trim()) {
            clientErrors.username = t('Username is required');
        }

        if (!password.trim()) {
            clientErrors.password = t('Password is required');
        }

        if (!repeatPassword.trim()) {
            clientErrors.repeatPassword = t('Repeat password is required');
        }

        if (password !== repeatPassword) {
            clientErrors.repeatPassword = t('Password mismatch');
        }

        if (Object.keys(clientErrors).length > 0) {
            this.setState({ errors: clientErrors });
            return;
        }

        this.setState({ errors: {} });
        let data = this.state;
        const { dispatch, history } = this.props;
        try {
            await dispatch(signupHandler(data));
            history.push("/index");
        } catch (error) {
            if (error.response?.data?.validationErrors) {
                this.setState({ errors: error.response.data.validationErrors });
            }
        }
    }

    render() {
        const { errors } = this.state;
        const { username, email, password, repeatPassword, phone, name: nameError, surname: surnameError, patronymic: patronymicError } = errors;
        const { t, i18n } = this.props;

        return (
            <div className="signup-page">
                <div className="signup-container">
                    <div className="signup-header">
                        <h1>{t('Create Account')}</h1>
                        <p>{t('Please fill in your details')}</p>
                    </div>
                    <form className="signup-form">
                        <div className="form-row">
                            <Input
                                label={t("Username *")}
                                error={username}
                                type="text"
                                name="username"
                                placeholder={t("Enter username")}
                                valueName={this.state.username}
                                onChangeData={this.onChangeData}
                            />
                            <Input
                                label={t("Email *")}
                                type="email"
                                error={email}
                                name="email"
                                placeholder={t("Enter email")}
                                valueName={this.state.email}
                                onChangeData={this.onChangeData}
                            />
                        </div>
                        <div className="form-row">
                            <Input
                                label={t("Password *")}
                                error={password}
                                type="password"
                                name="password"
                                placeholder={t("Enter password")}
                                valueName={this.state.password}
                                onChangeData={this.onChangeData}
                            />
                            <Input
                                label={t("Repeat Password *")}
                                error={repeatPassword}
                                type="password"
                                name="repeatPassword"
                                placeholder={t("Repeat password")}
                                valueName={this.state.repeatPassword}
                                onChangeData={this.onChangeData}
                            />
                        </div>
                        <div className="form-row">
                            <Input
                                label={t("Name")}
                                type="text"
                                name="name"
                                placeholder={t("Enter name")}
                                valueName={this.state.name}
                                onChangeData={this.onChangeData}
                                error={nameError}
                            />
                            <Input
                                label={t("Surname")}
                                type="text"
                                name="surname"
                                placeholder={t("Enter surname")}
                                valueName={this.state.surname}
                                onChangeData={this.onChangeData}
                                error={surnameError}
                            />
                        </div>
                        <div className="form-row">
                            <Input
                                label={t("Patronymic")}
                                type="text"
                                name="patronymic"
                                placeholder={t("Enter patronymic")}
                                valueName={this.state.patronymic}
                                onChangeData={this.onChangeData}
                                error={patronymicError}
                            />
                            <Input
                                label={t("Phone")}
                                error={phone}
                                type="tel"
                                name="phone"
                                placeholder={t("Enter phone")}
                                valueName={this.state.phone}
                                onChangeData={this.onChangeData}
                            />
                        </div>
                        <div className="form-group date-picker">
                            <label>{t('Born Date *')}</label>
                            <DatePicker
                                className="form-control"
                                selected={this.state.bornDate}
                                onChange={e => this.onChangeData('bornDate', e)}
                                dateFormat="yyyy/MM/dd"
                                locale={i18n.language === 'ru' ? 'ru' : 'en'}
                                placeholderText={t('Select date')}
                            />
                        </div>
                        <button
                            className="signup-button"
                            type="button"
                            disabled={repeatPassword !== undefined}
                            onClick={this.onClickSignUp}
                        >
                            {t('Sign Up')}
                        </button>
                        <div className="signup-footer">
                            <p>{t("Already have an account?")} <a href="/login">{t('Login')}</a></p>
                        </div>
                    </form>
                </div>
            </div>
        );
    }
}

const translation = withTranslation()(UserSignupPage);
export default connect()(translation);