import React, { Component } from 'react';
import { withTranslation } from 'react-i18next';
import { connect } from 'react-redux';
import { loginHandler } from '../../redux/AuthenticationAction';
import Input from '../../components/input';
import './UserLoginPage.css';

class UserLoginPage extends Component {
    constructor(props) {
        super(props);
        this.state = {
            username: '',
            password: '',
            captchaValue: null,
            errors: {}
        };
    }

    componentDidMount() {
        // Загружаем скрипт reCAPTCHA
        const script = document.createElement('script');
        script.src = `https://www.google.com/recaptcha/api.js?render=explicit`;
        script.async = true;
        script.defer = true;
        document.body.appendChild(script);

        script.onload = () => {
            window.grecaptcha.ready(() => {
                window.grecaptcha.render('recaptcha-container', {
                    sitekey: '6LeuUDArAAAAAGrQobdcCr8D5_QVXA44taU9lFHQ',
                    callback: this.onCaptchaChange,
                    theme: 'light'
                });
            });
        };
    }

    onChangeData = (type, event) => {
        const stateData = this.state;
        stateData[type] = event;
        const errors = { ...this.state.errors };
        errors[type] = undefined;
        this.setState({ stateData, errors });
    }

    onCaptchaChange = (value) => {
        console.log('Captcha value:', value);
        this.setState({ captchaValue: value });
    }

    onClickLogin = async (e) => {
        e.preventDefault();
        this.setState({ errors: {} });
        const { username, password, captchaValue } = this.state;
        console.log('Login attempt with:', { username, password, captchaValue });
        const { dispatch, history } = this.props;

        if (!captchaValue) {
            this.setState({
                errors: {
                    captcha: 'Пожалуйста, подтвердите, что вы не робот'
                }
            });
            return;
        }

        try {
            await dispatch(loginHandler({ username, password, captchaValue }));
            history.push("/index");
        } catch (error) {
            console.error('Login error:', error);
            if (error.response?.status === 401) {
                this.setState({
                    errors: {
                        username: 'Неверный логин или пароль',
                        password: 'Неверный логин или пароль'
                    }
                });
            } else if (error.response?.data?.validationErrors) {
                this.setState({ errors: error.response.data.validationErrors });
            }
        }
    }

    render() {
        const { username, password, captcha } = this.state.errors;
        const { t } = this.props;

        return (
            <div className="login-page">
                <div className="login-container">
                    <div className="login-header">
                        <h1>{t('Welcome Back')}</h1>
                        <p>{t('Please login to your account')}</p>
                    </div>
                    <form className="login-form">
                        <Input
                            label={t("Username *")}
                            error={username}
                            type="text"
                            name="username"
                            placeholder={t("Enter your username")}
                            valueName={this.state.username}
                            onChangeData={this.onChangeData}
                        />
                        <Input
                            label={t("Password *")}
                            error={password}
                            type="password"
                            name="password"
                            placeholder={t("Enter your password")}
                            valueName={this.state.password}
                            onChangeData={this.onChangeData}
                        />
                        <div className="captcha-container">
                            <div id="recaptcha-container"></div>
                            {captcha && <div className="error-message">{captcha}</div>}
                        </div>
                        <button
                            className="login-button"
                            type="button"
                            onClick={this.onClickLogin}
                        >
                            {t('Login')}
                        </button>
                        <div className="login-footer">
                            <p>{t("Don't have an account?")} <a href="/signup">{t('Sign Up')}</a></p>
                        </div>
                    </form>
                </div>
            </div>
        );
    }
}

const translation = withTranslation()(UserLoginPage);
export default connect()(translation);