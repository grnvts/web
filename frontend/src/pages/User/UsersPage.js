import React, { Component } from 'react';
import { withTranslation } from 'react-i18next';
import { connect } from 'react-redux';
import AlertifyService from '../../Services/AlertifyService';
import UserService from '../../Services/UserService';
import { Redirect } from 'react-router-dom';
import UserTableRow from "../../components/UserTableRow";

class UsersPage extends Component {
    constructor(props) {
        super(props);
        this.state = {
            page: {
                content: [],
                number: 0,
                size: 10,
            },
            jwttoken: props.jwttoken,
            isAdmin: props.roles?.includes('ROLE_ADMIN'), // Проверяем, является ли пользователь администратором
        };
    }

    componentDidMount() {
        if (!this.state.isAdmin) {
            AlertifyService.error('Access denied: Admins only');
            this.props.history.push('/index'); // Перенаправляем на главную страницу
            return;
        }
        this.getUsers(this.state.page.number, this.state.page.size);
    }

    getUsers = async (number, size) => {
        try {
            const response = await UserService.getUsers(number, size);
            this.setState({ page: response.data });
        } catch (error) {
            if (error.response) {
                AlertifyService.alert(error.response.data.message);
            } else if (error.request) {
                AlertifyService.alert(error.request);
            } else {
                AlertifyService.alert(error.message);
            }
        }
    };

    onClickNext = () => {
        const nextPage = this.state.page.number + 1;
        this.getUsers(nextPage, this.state.page.size);
    };

    onClickPrevios = () => {
        const nextPage = this.state.page.number - 1;
        this.getUsers(nextPage, this.state.page.size);
    };

    render() {
        if (!this.state.isAdmin) {
            return <Redirect to="/index" />;
        }

        const { content: users, first, last, number, totalPages } = this.state.page;
        const { t } = this.props;

        return (
            <div className="col-sm-12">
                <div className="card">
                    <h3 className="card-header">
                        <div className="d-flex justify-content-center">{t('Users')}</div>
                    </h3>

                    <div className="card-header d-flex justify-content-between bd-highlight mb-3">
                        <div className="d-flex justify-content-start">
                            {first === false && (
                                <button onClick={this.onClickPrevios} className="btn btn-secondary btn-sm">
                                    {t('Previous')}
                                </button>
                            )}
                        </div>

                        <div className="d-flex justify-content-end">
                            {last === false && (
                                <button onClick={this.onClickNext} className="btn btn-secondary btn-sm">
                                    {t('Next')}
                                </button>
                            )}
                        </div>
                    </div>
                    <table className="table table-hover">
                        <thead>
                            <tr>
                                <th scope="col">ID</th>
                                <th scope="col">{t('Username')}</th>
                                <th scope="col">{t('Name')}</th>
                                <th scope="col">{t('Surname')}</th>
                                <th scope="col">{t('Email')}</th>
                                <th scope="col">{t('Action')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {users.map((user) => (
                                <UserTableRow user={user} key={user.username} />
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        );
    }
}

const mapStateToProps = (store) => {
    return {
        isLoggedIn: store.isLoggedIn,
        username: store.username,
        jwttoken: store.jwttoken,
        roles: store.roles, // Получаем роли пользователя из Redux
    };
};

export default connect(mapStateToProps)(withTranslation()(UsersPage));