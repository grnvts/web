import React, { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { logoutAction } from '../redux/AuthenticationAction';
import ApiService from '../Services/BaseService/ApiService';
import ProfileImage from '../components/ProfileImage';
import defaultPicture from "./../assets/profile.png";
import { BACKEND_IMAGE_URL } from '../Shared/config';
import './Navbar.css';

const NavbarComponent = props => {
    const [dropDownVisible, setDropDownVisible] = useState(false);
    const [notificationsVisible, setNotificationsVisible] = useState(false);
    const [notifications, setNotifications] = useState([]);
    const [ordersDropdownVisible, setOrdersDropdownVisible] = useState(false);
    const dropDownMenuArea = useRef(null);
    const notificationsMenuArea = useRef(null);
    const profileMenuArea = useRef(null);
    const [profileDropdownVisible, setProfileDropdownVisible] = useState(false);
    const ordersMenuArea = useRef(null);
    let imageSource = defaultPicture;

    const { isLoggedIn, username, image, roles } = useSelector(store => ({
        isLoggedIn: store.isLoggedIn,
        username: store.username,
        image: store.image,
        roles: store.roles || []
    }));

    const dispatch = useDispatch();
    const isAdmin = roles.includes('ROLE_ADMIN');
    const isBrigadier = roles.includes('ROLE_BRIGADIER');

    useEffect(() => {
        document.addEventListener("click", menuClickTracker);
        return () => {
            document.removeEventListener("click", menuClickTracker);
        };
    }, []);

    const menuClickTracker = (event) => {
        if (notificationsMenuArea.current === null || !notificationsMenuArea.current.contains(event.target)) {
            setNotificationsVisible(false);
        }
        if (profileMenuArea.current === null || !profileMenuArea.current.contains(event.target)) {
            setProfileDropdownVisible(false);
        }
        if (ordersMenuArea.current === null || !ordersMenuArea.current.contains(event.target)) {
            setOrdersDropdownVisible(false);
        }
    };

    const onLogout = () => {
        ApiService.changeAuthToken(null);
        dispatch(logoutAction());
    };

    const { t, i18n } = useTranslation();

    const loadNotifications = async () => {
        try {
            const response = await ApiService.get('/notifications');
            setNotifications(response.data);
        } catch (error) {
            console.error('Failed to load notifications:', error);
            if (error.response?.status === 401) {
                onLogout();
            }
        }
    };

    const toggleNotifications = () => {
        setNotificationsVisible(!notificationsVisible);
        if (!notificationsVisible) {
            loadNotifications();
        }
    };

    const changeLanguage = (lng) => {
        i18n.changeLanguage(lng);
    };

    let links = (
        <ul className="navbar-nav ml-auto">
            <li className="nav-item">
                <Link className="nav-link" to="/login">
                    <i className="fas fa-sign-in-alt"></i>
                    <span>{t('Login')}</span>
                </Link>
            </li>
            <li className="nav-item">
                <Link className="nav-link" to="/signup">
                    <i className="fas fa-user-plus"></i>
                    <span>{t('Sign Up')}</span>
                </Link>
            </li>
        </ul>
    );

    if (isLoggedIn) {
        let dropdownClassName = "nav-dropdown-menu";
        if (dropDownVisible) {
            dropdownClassName += " show";
        }
        if (image) {
            imageSource = image;
        }

        if (isBrigadier) {
            links = (
                <ul className="navbar-nav ml-auto">
                    <li className="nav-item">
                        <Link className="nav-link" to="/orders/brigadier">
                            <i className="fas fa-clipboard-list"></i>
                            <span>{t('My Orders')}</span>
                        </Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/brigade/manage">
                            <i className="fas fa-users"></i>
                            <span>{t('My Brigade')}</span>
                        </Link>
                    </li>
                    <li className="nav-item" ref={dropDownMenuArea}>
                        <div className="nav-item" ref={profileMenuArea}>
                            <div className="nav-dropdown-trigger" onClick={() => setProfileDropdownVisible(!profileDropdownVisible)}>
                                <ProfileImage
                                    width="32"
                                    height="32"
                                    imageSource={imageSource}
                                    username={username}
                                    className="profile-image"
                                />
                                <span className="username">{username}</span>
                            </div>

                            {profileDropdownVisible && (
                                <div className="nav-dropdown-menu">
                                    <div className="dropdown-header">
                                        <ProfileImage
                                            width="60"
                                            height="60"
                                            imageSource={imageSource}
                                            username={username}
                                            className="profile-image-large"
                                        />
                                        <div className="profile-info">
                                            <span className="profile-name">{username}</span>
                                            <span className="profile-role">
                                                {isAdmin ? t('Administrator') : isBrigadier ? t('Brigadier') : t('User')}
                                            </span>
                                        </div>
                                    </div>
                                    <div className="dropdown-content">
                                        <Link to={`/user/${username}`} className="dropdown-item" onClick={() => setProfileDropdownVisible(false)}>
                                            <i className="fas fa-user"></i>
                                            <span>{t('My Profile')}</span>
                                        </Link>
                                        <div className="dropdown-divider"></div>
                                        <div className="dropdown-item" onClick={onLogout}>
                                            <i className="fas fa-sign-out-alt"></i>
                                            <span>{t('Logout')}</span>
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>

                    </li>
                </ul>
            );
        } else {
            links = (
                <ul className="navbar-nav ml-auto">
                    <li className="nav-item">
                        <Link className="nav-link" to="/index">
                            <i className="fas fa-home"></i>
                            <span>{t('HomePage')}</span>
                        </Link>
                    </li>
                    {isAdmin ? (
    <li className="nav-item">
        <Link className="nav-link" to="/orders/all">
            <i className="fas fa-globe"></i>
            <span>{t('All Orders')}</span>
        </Link>
    </li>
) : (
    <li className="nav-item" ref={ordersMenuArea}>
        <div className="nav-dropdown-trigger" onClick={(e) => {
            e.stopPropagation();
            setOrdersDropdownVisible(!ordersDropdownVisible);
        }}>
            <i className="fas fa-clipboard-list"></i>
            <span>{t('Orders')}</span>
        </div>
        {ordersDropdownVisible && (
            <div className="nav-dropdown-menu">
                <div className="dropdown-content">
                    {!isAdmin && (
                        <>
                            <Link to="/orders" className="dropdown-item" onClick={() => setOrdersDropdownVisible(false)}>
                                <i className="fas fa-list"></i>
                                <span>{t('My Orders')}</span>
                            </Link>
                            <Link to="/orders/create" className="dropdown-item" onClick={() => setOrdersDropdownVisible(false)}>
                                <i className="fas fa-plus"></i>
                                <span>{t('Create Order')}</span>
                            </Link>
                        </>
                    )}
                    {isBrigadier && (
                        <Link to="/orders/brigadier" className="dropdown-item" onClick={() => setOrdersDropdownVisible(false)}>
                            <i className="fas fa-hard-hat"></i>
                            <span>{t('Brigadier Orders')}</span>
                        </Link>
                    )}
                </div>
            </div>
        )}
    </li>
)}
                    {isAdmin && (
                        <>
                            <li className="nav-item">
                                <Link className="nav-link" to="/users">
                                    <i className="fas fa-users"></i>
                                    <span>{t('Users')}</span>
                                </Link>
                            </li>
                            <li className="nav-item">
                                <Link className="nav-link" to="/brigades">
                                    <i className="fas fa-hard-hat"></i>
                                    <span>{t('Brigades')}</span>
                                </Link>
                            </li>
                        </>
                    )}
                    
                    <li className="nav-item" ref={notificationsMenuArea}>
                        <div className="nav-dropdown-trigger" onClick={toggleNotifications}>
                            <i className="fas fa-bell"></i>
                            {notifications.length > 0 && (
                                <span className="notification-badge">{notifications.length}</span>
                            )}
                        </div>
                        {notificationsVisible && (
                            <div className="nav-dropdown-menu notifications-menu">
                                <div className="dropdown-header">
                                    <h4>{t('Notifications')}</h4>
                                    {notifications.length > 0 && (
                                        <span className="notification-count">{notifications.length}</span>
                                    )}
                                </div>
                                <div className="dropdown-content">
                                    {notifications.length > 0 ? (
                                        notifications.map((notification, index) => (
                                            <div key={index} className="notification-item">
                                                <i className="fas fa-info-circle"></i>
                                                <div className="notification-text">
                                                    <p>{notification.message || t('No message')}</p>
                                                    <span className="notification-date">
                                                        {notification.orderDate || t('No date')}
                                                    </span>
                                                </div>
                                            </div>
                                        ))
                                    ) : (
                                        <div className="no-notifications">
                                            <i className="fas fa-check-circle"></i>
                                            <p>{t('No notifications')}</p>
                                        </div>
                                    )}
                                </div>
                            </div>
                        )}
                    </li>
                    <li className="nav-item" ref={dropDownMenuArea}>
                        <div className="nav-item" ref={profileMenuArea}>
                            <div className="nav-dropdown-trigger" onClick={() => setProfileDropdownVisible(!profileDropdownVisible)}>
                                <ProfileImage
                                    width="32"
                                    height="32"
                                    imageSource={imageSource}
                                    username={username}
                                    className="profile-image"
                                />
                                <span className="username">{username}</span>
                            </div>

                            {profileDropdownVisible && (
                                <div className="nav-dropdown-menu">
                                    <div className="dropdown-header">
                                        <ProfileImage
                                            width="60"
                                            height="60"
                                            imageSource={imageSource}
                                            username={username}
                                            className="profile-image-large"
                                        />
                                        <div className="profile-info">
                                            <span className="profile-name">{username}</span>
                                            <span className="profile-role">
                                                {isAdmin ? t('Administrator') : t('User')}
                                            </span>
                                        </div>
                                    </div>
                                    <div className="dropdown-content">
                                        <Link to={`/user/${username}`} className="dropdown-item" onClick={() => setProfileDropdownVisible(false)}>
                                            <i className="fas fa-user"></i>
                                            <span>{t('My Profile')}</span>
                                        </Link>
                                        <div className="dropdown-divider"></div>
                                        <div className="dropdown-item" onClick={onLogout}>
                                            <i className="fas fa-sign-out-alt"></i>
                                            <span>{t('Logout')}</span>
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>
                    </li>
                </ul>
            );
        }
    }

    return (
        <nav className="navbar navbar-expand-lg">
            <div className="container">
                <Link className="navbar-brand" to="/">
                    <i className="fas fa-tools"></i>
                    <span>Ремонт-Мастер</span>
                </Link>
                <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
                    <span className="navbar-toggler-icon"></span>
                </button>
                <div className="collapse navbar-collapse" id="navbarNav">
                    {links}
                    {/* Language Switcher */}
                    <ul className="navbar-nav ml-auto" style={{ flexDirection: 'row' }}>
                        <li className="nav-item">
                            <span className="nav-link" style={{ cursor: 'pointer' }} onClick={() => changeLanguage('en')}>
                                English
                            </span>
                        </li>
                        <li className="nav-item">
                            <span className="nav-link" style={{ cursor: 'pointer' }} onClick={() => changeLanguage('ru')}>
                                Русский
                            </span>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    );
};

export default NavbarComponent;