import React, { Component } from 'react'
import Input from '../../components/input';
import { withTranslation } from 'react-i18next';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import { /*loginAction,*/ loginHandler } from './../../redux/AuthenticationAction';
import Spinner from '../../components/Spinner';
import Axios from 'axios';

class UserLoginPage extends Component {
    constructor(props) {
        super(props);
        this.state = {
            username: '',
            email: null,
            password: '',
            error: null,
            errors: {},
            pendingApiCall: false
        };

        this.requestInterceptor = null;
        this.responseInterceptor = null;
    }

    componentDidMount() {
        this.requestInterceptor = Axios.interceptors.request.use(request => {
            this.setState({ pendingApiCall: true });
            return request;
        });

        this.responseInterceptor = Axios.interceptors.response.use(
            response => {
                this.setState({ pendingApiCall: false });
                return response;
            },
            error => {
                this.setState({ pendingApiCall: false });
                throw error;
            }
        );
    }

    componentWillUnmount() {
        // Eject Axios interceptors to prevent memory leaks
        if (this.requestInterceptor !== null) {
            Axios.interceptors.request.eject(this.requestInterceptor);
        }
        if (this.responseInterceptor !== null) {
            Axios.interceptors.response.eject(this.responseInterceptor);
        }
    }

    onChangeData = (type, event) => {
        if (this.state.error) this.setState({ error: null });
        const stateData = this.state;
        stateData[type] = event;
        this.setState({ stateData });
    };

    onClickLogin = async (event) => {
        event.preventDefault();
        if (this.state.error) {
            this.setState({ error: null });
        }
        const { dispatch, history } = this.props;
        const { username, password } = this.state;
        const creds = { username, password };

        try {
            await dispatch(loginHandler(creds));
            history.push("/index");
        } catch (error) {
            if (error.response) {
                if (error.response.data.message) {
                    console.log(error.response);
                    this.setState({ error: error.response.data.message });
                }
            } else if (error.request) {
                console.log(error.request);
            } else {
                console.log(error.message);
            }
        }
    };

    render() {
        const { username, password } = this.state.errors;
        const btnEnable = this.state.username && this.state.password;
        const { t } = this.props;
        return (
            <div className="container row">
                <div className="col-lg-8">
                    <h3>{t('Login')}</h3>
                    <p className="description-p" style={{ color: "red" }}>
                        ( * ) {t('Required field')}
                    </p>
                    <form>
                        <Input
                            label={t("Username *")}
                            error={username}
                            type="text"
                            name="username"
                            placeholder={t("Username *")}
                            valueName={this.state.username}
                            onChangeData={this.onChangeData}
                        />
                        <Input
                            label={t("Password *")}
                            error={password}
                            type="password"
                            name="password"
                            placeholder={t("Password *")}
                            valueName={this.state.password}
                            onChangeData={this.onChangeData}
                        />
                        {this.state.pendingApiCall ? (
                            <Spinner />
                        ) : (
                            <button
                                className="btn btn-dark"
                                type="button"
                                disabled={!btnEnable}
                                onClick={this.onClickLogin}
                            >
                                {t('Login')}
                            </button>
                        )}
                    </form>
                    <br />
                    {this.state.error && (
                        <div className="alert alert-danger" role="alert">
                            {this.state.error}
                        </div>
                    )}
                </div>
                <div className="col-lg-3"></div>
                <div className="col"></div>
                <div className="col-lg-12"></div>
            </div>
        );
    }
}

export default connect()(withTranslation()(withRouter(UserLoginPage)));