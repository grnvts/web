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
            errors: {}
        };
    }

    onChangeData = (type, event) => {
        const stateData = this.state;
        stateData[type] = event;
        const errors = { ...this.state.errors };
        errors[type] = undefined;
        this.setState({ stateData, errors });
    }

    onClickLogin = async (e) => {
        e.preventDefault();
        this.setState({ errors: {} });
        const { username, password } = this.state;
        const { dispatch, history } = this.props;

        try {
            await dispatch(loginHandler({ username, password }));
            history.push("/index");
        } catch (error) {
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
        const { username, password } = this.state.errors;
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