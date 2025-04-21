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
            rolesFilter: '', // Фильтр по роли
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
            AlertifyService.error('Failed to load users');
        }
    };

    handleRoleFilterChange = (e) => {
        this.setState({ rolesFilter: e.target.value });
    };

    onClickNext = () => {
        const nextPage = this.state.page.number + 1;
        this.getUsers(nextPage, this.state.page.size);
    };

    onClickPrevious = () => {
        const prevPage = this.state.page.number - 1;
        this.getUsers(prevPage, this.state.page.size);
    };

    render() {
        if (!this.state.isAdmin) {
            return <Redirect to="/index" />;
        }

        const { content: users, first, last } = this.state.page;
        const { t } = this.props;
        const { rolesFilter } = this.state;

        // Фильтруем пользователей по роли
        const filteredUsers = rolesFilter
            ? users.filter((user) => user.roles.includes(rolesFilter))
            : users;

        return (
            <div className="col-sm-12">
                <div className="card">
                    <h3 className="card-header">
                        <div className="d-flex justify-content-center">{t('Users')}</div>
                    </h3>

                    <div className="card-header d-flex justify-content-between">
                        <div>
                            <label htmlFor="roleFilter">{t('Filter by Role')}:</label>
                            <select
                                id="roleFilter"
                                className="form-control"
                                value={rolesFilter}
                                onChange={this.handleRoleFilterChange}
                            >
                                <option value="">{t('All Roles')}</option>
                                <option value="ROLE_ADMIN">{t('Admin')}</option>
                                <option value="ROLE_USER">{t('User')}</option>
                                <option value="ROLE_BRIGADIER">{t('Brigadier')}</option>
                            </select>
                        </div>
                        <div>
                            {!first && (
                                <button onClick={this.onClickPrevious} className="btn btn-secondary btn-sm">
                                    {t('Previous')}
                                </button>
                            )}
                            {!last && (
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
                                <th scope="col">{t('Roles')}</th>
                                <th scope="col">{t('Action')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filteredUsers.map((user) => (
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