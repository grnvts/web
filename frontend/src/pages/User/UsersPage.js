import React, { Component } from 'react';
import { withTranslation } from 'react-i18next';
import { connect } from 'react-redux';
import AlertifyService from '../../Services/AlertifyService';
import UserService from '../../Services/UserService';
import { Redirect } from 'react-router-dom';
import UserTableRow from "../../components/UserTableRow";
import AddMasterModal from '../../components/AddMasterModal';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSort, faSortUp, faSortDown } from '@fortawesome/free-solid-svg-icons';
import './UsersPage.css';

class UsersPage extends Component {
    constructor(props) {
        super(props);
        this.state = {
            page: {
                content: [],
                number: 0,
                size: 10,
            },
            rolesFilter: '',
            searchQuery: '',
            jwttoken: props.jwttoken,
            isAdmin: props.roles?.includes('ROLE_ADMIN'),
            loading: true,
            showAddMasterModal: false,
            sortConfig: {
                key: 'surname',
                direction: 'asc'
            }
        };
    }

    componentDidMount() {
        if (!this.state.isAdmin) {
            AlertifyService.error('Доступ запрещен: только для администраторов');
            this.props.history.push('/index');
            return;
        }
        this.getUsers(this.state.page.number, this.state.page.size);
    }

    getUsers = async (number, size) => {
        try {
            this.setState({ loading: true });
            const response = await UserService.getUsers(number, size);
            this.setState({ page: response.data, loading: false });
        } catch (error) {
            AlertifyService.error('Ошибка при загрузке пользователей');
            this.setState({ loading: false });
        }
    };

    restoreUser = async (userId) => {
        try {
            await UserService.restoreUser(userId, this.state.jwttoken);
            AlertifyService.success('Пользователь успешно восстановлен');
            this.getUsers(this.state.page.number, this.state.page.size);
        } catch (error) {
            console.error('Error restoring user:', error);
            AlertifyService.error('Ошибка при восстановлении пользователя');
        }
    };

    handleRoleFilterChange = (e) => {
        this.setState({ rolesFilter: e.target.value });
    };

    handleSearchChange = (e) => {
        this.setState({ searchQuery: e.target.value });
    };

    onClickNext = () => {
        const nextPage = this.state.page.number + 1;
        this.getUsers(nextPage, this.state.page.size);
    };

    onClickPrevious = () => {
        const prevPage = this.state.page.number - 1;
        this.getUsers(prevPage, this.state.page.size);
    };

    handleSort = (key) => {
        let direction = 'asc';
        if (this.state.sortConfig.key === key && this.state.sortConfig.direction === 'asc') {
            direction = 'desc';
        }
        this.setState({ sortConfig: { key, direction } });
    };

    getSortedUsers = () => {
        const { content: users } = this.state.page;
        const { sortConfig } = this.state;
        const { rolesFilter, searchQuery } = this.state;

        let filteredUsers = users
            .filter(user => !rolesFilter || user.roles.includes(rolesFilter))
            .filter(user => {
                if (!searchQuery) return true;
                const searchLower = searchQuery.toLowerCase();
                return (
                    (user.username && user.username.toLowerCase().includes(searchLower)) ||
                    (user.name && user.name.toLowerCase().includes(searchLower)) ||
                    (user.surname && user.surname.toLowerCase().includes(searchLower)) ||
                    (user.email && user.email.toLowerCase().includes(searchLower))
                );
            });

        return filteredUsers.sort((a, b) => {
            if (!a[sortConfig.key]) return 1;
            if (!b[sortConfig.key]) return -1;
            
            if (a[sortConfig.key] < b[sortConfig.key]) {
                return sortConfig.direction === 'asc' ? -1 : 1;
            }
            if (a[sortConfig.key] > b[sortConfig.key]) {
                return sortConfig.direction === 'asc' ? 1 : -1;
            }
            return 0;
        });
    };

    getSortIcon = (key) => {
        const { sortConfig } = this.state;
        if (sortConfig.key !== key) {
            return faSort;
        }
        return sortConfig.direction === 'asc' ? faSortUp : faSortDown;
    };

    render() {
        if (!this.state.isAdmin) {
            return <Redirect to="/index" />;
        }

        const { loading, showAddMasterModal } = this.state;
        const sortedUsers = this.getSortedUsers();

        return (
            <div className="users-page-container">
                <div className="users-page-header">
                    <h2>Управление пользователями</h2>
                    <div className="header-buttons">
                        <button
                            className="create-user-btn"
                            onClick={() => this.props.history.push('/create-user')}
                        >
                            <i className="fas fa-plus"></i>
                            Создать пользователя
                        </button>
                        <button
                            className="create-master-btn"
                            onClick={() => this.setState({ showAddMasterModal: true })}
                        >
                            <i className="fas fa-user-tie"></i>
                            Создать мастера
                        </button>
                    </div>
                </div>

                {showAddMasterModal && (
                    <AddMasterModal
                        onClose={() => this.setState({ showAddMasterModal: false })}
                        onCreated={() => {
                            this.setState({ showAddMasterModal: false });
                            this.getUsers(this.state.page.number, this.state.page.size);
                        }}
                    />
                )}

                <div className="users-filters">
                    <div className="search-container">
                        <input
                            type="text"
                            className="search-input"
                            placeholder="Поиск по имени, email или логину..."
                            value={this.state.searchQuery}
                            onChange={this.handleSearchChange}
                        />
                        <i className="fas fa-search search-icon"></i>
                    </div>

                    <div className="role-filter">
                        <select
                            className="role-select"
                            value={this.state.rolesFilter}
                            onChange={this.handleRoleFilterChange}
                        >
                            <option value="">Все роли</option>
                            <option value="ROLE_ADMIN">Администратор</option>
                            <option value="ROLE_USER">Пользователь</option>
                            <option value="ROLE_BRIGADIER">Бригадир</option>
                            <option value="ROLE_MASTER">Мастер</option>
                        </select>
                    </div>
                </div>

                {loading ? (
                    <div className="loading-spinner">
                        <i className="fas fa-spinner fa-spin"></i>
                        <span>Загрузка...</span>
                    </div>
                ) : (
                    <>
                        <div className="users-table-container">
                            <table className="users-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th onClick={() => this.handleSort('username')}>
                                            Логин
                                            <FontAwesomeIcon 
                                                icon={this.getSortIcon('username')} 
                                                className="ms-2" 
                                            />
                                        </th>
                                        <th onClick={() => this.handleSort('name')}>
                                            Имя
                                            <FontAwesomeIcon 
                                                icon={this.getSortIcon('name')} 
                                                className="ms-2" 
                                            />
                                        </th>
                                        <th onClick={() => this.handleSort('surname')}>
                                            Фамилия
                                            <FontAwesomeIcon 
                                                icon={this.getSortIcon('surname')} 
                                                className="ms-2" 
                                            />
                                        </th>
                                        <th onClick={() => this.handleSort('email')}>
                                            Email
                                            <FontAwesomeIcon 
                                                icon={this.getSortIcon('email')} 
                                                className="ms-2" 
                                            />
                                        </th>
                                        <th>Роли</th>
                                        <th>Действия</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {sortedUsers.map((user) => (
                                        <UserTableRow 
                                            user={user}
                                            key={user.username}
                                            onRestore={this.restoreUser}
                                        />
                                    ))}
                                </tbody>
                            </table>
                        </div>

                        <div className="pagination-controls">
                            {!this.state.page.first && (
                                <button 
                                    onClick={this.onClickPrevious} 
                                    className="pagination-btn"
                                >
                                    <i className="fas fa-chevron-left"></i>
                                    Предыдущая
                                </button>
                            )}
                            {!this.state.page.last && (
                                <button 
                                    onClick={this.onClickNext} 
                                    className="pagination-btn"
                                >
                                    Следующая
                                    <i className="fas fa-chevron-right"></i>
                                </button>
                            )}
                        </div>
                    </>
                )}
            </div>
        );
    }
}

const mapStateToProps = (store) => {
    return {
        isLoggedIn: store.isLoggedIn,
        username: store.username,
        jwttoken: store.jwttoken,
        roles: store.roles,
    };
};

export default connect(mapStateToProps)(withTranslation()(UsersPage));