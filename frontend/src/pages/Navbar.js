import React, { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { logoutAction } from '../redux/AuthenticationAction';
import ApiService from '../Services/BaseService/ApiService';
import ProfileImage from '../components/ProfileImage';
import defaultPicture from "./../assets/profile.png";
import { BACKEND_IMAGE_URL } from '../Shared/config';

const NavbarComponent = props => {
    const [dropDownVisible, setDropDownVisible] = useState(false);
    const [notificationsVisible, setNotificationsVisible] = useState(false); // Для управления видимостью уведомлений
    const [notifications, setNotifications] = useState([]); // Для хранения уведомлений
    const dropDownMenuArea = useRef(null);
    const notificationsMenuArea = useRef(null);
    const [ordersDropdownVisible, setOrdersDropdownVisible] = useState(false); // Для отслеживания кликов вне уведомлений
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
    }, [isLoggedIn]);

    const menuClickTracker = (event) => {
        if (dropDownMenuArea.current === null || !dropDownMenuArea.current.contains(event.target)) {
            setDropDownVisible(false);
        }
        if (notificationsMenuArea.current === null || !notificationsMenuArea.current.contains(event.target)) {
            setNotificationsVisible(false);
        }
    };

    const onLogout = () => {
        ApiService.changeAuthToken(null);
        dispatch(logoutAction());
    };

    const { t } = useTranslation();

    const loadNotifications = async () => {
        try {
            console.log('Loading notifications...');
            const response = await ApiService.get('/notifications');
            console.log('Notifications received:', response.data);
            setNotifications(response.data);
        } catch (error) {
            console.error('Failed to load notifications:', error);
            if (error.response?.status === 401) {
                onLogout();
            }
        }
    };

    const toggleNotifications = () => {
        console.log('Current visibility:', notificationsVisible);
        setNotificationsVisible(!notificationsVisible);
        if (!notificationsVisible) {
            loadNotifications();
        }
    };

    const { i18n } = useTranslation();

    const changeLanguage = (lng) => {
        i18n.changeLanguage(lng);
    };

    let links = (
        <ul className="navbar-nav ml-auto">
            <li className="nav-item">
                <Link className="nav-link" to="/login">{t('Login')}</Link>
            </li>
            <li className="nav-item">
                <Link className="nav-link" to="/signup">{t('Sign Up')}</Link>
            </li>
        </ul>
    );
    
    if (isLoggedIn) {




        let dropdownClassName = "dropdown-menu p-2 shadow";
        if (dropDownVisible) {
            dropdownClassName += " show";
        }
        if (image) {
            imageSource = image;
        }
        if (isBrigadier) {
            links = (
                <ul className="navbar-nav ml-auto">
                    <li className="nav-item active">
                        <Link className="nav-link" to="/orders/brigadier">{t('My Orders')}</Link>
                    </li>
                    <li className="nav-item active">
                        <Link className="nav-link" to="/brigade/manage">{t('My Brigade')}</Link>
                    </li>
                    <li className="naw-item dropdown ml-3" style={{ cursor: "pointer" }} ref={dropDownMenuArea}>
                        <div className="d-flex" onClick={() => setDropDownVisible(true)}>
                            <ProfileImage
                                width="32"
                                height="32"
                                imageSource={imageSource}
                                username={username}
                                className="m-auto"
                            />
                            <span className="nav-link dropdown-toggle">{username}</span>
                        </div>
                        <div className={dropdownClassName}>
                            <Link
                                className="dropdown-item"
                                to={"/user/" + username}
                                onClick={() => setDropDownVisible(false)}>{t("My Profile")}</Link>
                            <span className="dropdown-item" onClick={onLogout} style={{ cursor: "pointer" }}>
                                {t('Logout')}
                            </span>
                        </div>
                    </li>
                </ul>
            );
        }
        else {



            links = (
                <ul className="navbar-nav ml-auto">
                    <li className="nav-item active">
                        <Link className="nav-link" to="/index">{t('HomePage')} <span className="sr-only">(current)</span></Link>
                    </li>
                    <li className="nav-item dropdown" style={{ position: 'relative' }}>
                        <span className="nav-link dropdown-toggle" onClick={() => setOrdersDropdownVisible(!ordersDropdownVisible)} style={{ cursor: 'pointer' }}>
                            {t('Orders')}
                        </span>

                        {ordersDropdownVisible && (
                            <div className="dropdown-menu show" style={{ display: 'block' }}>
                                <Link className="dropdown-item" to="/orders">{t('My Orders')}</Link>
                                <Link className="dropdown-item" to="/orders/create">{t('Create Order')}</Link>
                                {isAdmin && <Link className="dropdown-item" to="/orders/all">{t('All Orders')}</Link>}
                            </div>
                        )}
                    </li>
                    {isAdmin && (
                        <>
                            <li className="nav-item active">
                                <Link className="nav-link" to="/users">{t('Users')}</Link>
                            </li>
                            <li className="nav-item active">
                                <Link className="nav-link" to="/brigades">{t('Brigades')}</Link>
                            </li>
                        </>
                    )}
                    <li className="nav-item active">
                        <Link className="nav-link" to={"/building/" + username}>{t('Building')}</Link>
                    </li>
                    {/* Уведомления */}
                    <li className="nav-item dropdown" ref={notificationsMenuArea} style={{ position: 'relative' }}>
                        <span className="nav-link" style={{ cursor: 'pointer' }} onClick={toggleNotifications}>
                            <img
                                src="/bell-1-svgrepo-com.svg"
                                alt="Notifications"
                                style={{ width: '20px', height: '20px' }}
                            />
                            {/* Добавьте бейдж с количеством уведомлений */}
                            {notifications.length > 0 && (
                                <span className="badge badge-danger" style={{
                                    position: 'absolute',
                                    top: '5px',
                                    right: '5px',
                                    fontSize: '10px'
                                }}>
                                    {notifications.length}
                                </span>
                            )}
                        </span>
                        {notificationsVisible && (
                            <div className="dropdown-menu show"
                                style={{
                                    position: 'absolute',
                                    right: 0,
                                    left: 'auto',
                                    top: '100%',
                                    zIndex: 1000,
                                    display: 'block'
                                }}>
                                <h6 className="dropdown-header">{t('Notifications')}</h6>

                                {notifications.length > 0 ? (
                                    notifications.map((notification, index) => (
                                        <div key={index} className="dropdown-item">
                                            <p>{notification.message || 'No message'}</p>
                                            <small>
                                                {notification.orderDate
                                                    ? `${t('Order Date')}: ${notification.orderDate}`
                                                    : t('No date')}
                                            </small>
                                        </div>
                                    ))
                                ) : (
                                    <p className="dropdown-item">{t('No notifications')}</p>
                                )}
                            </div>
                        )}
                    </li>
                    {/* DropDown Menu */}
                    <li className="naw-item dropdown ml-3" style={{ cursor: "pointer" }} ref={dropDownMenuArea}>
                        <div className="d-flex" onClick={() => setDropDownVisible(true)}>
                            <ProfileImage
                                width="32"
                                height="32"
                                imageSource={imageSource}
                                username={username}
                                className="m-auto"
                            />
                            <span className="nav-link dropdown-toggle">{username}</span>
                        </div>
                        <div className={dropdownClassName}>
                            <Link
                                className="dropdown-item"
                                to={"/user/" + username}
                                onClick={() => setDropDownVisible(false)}>{t("My Profile")}</Link>

                            <span className="dropdown-item" onClick={onLogout} style={{ cursor: "pointer" }}>
                                {t('Logout')}
                            </span>
                        </div>
                    </li>
                </ul>
            );
        }
    }
    return (
        <div className="col-lg-12 shadow-sm mb-2" style={{ width: '100%', padding: 0 }}>
            <nav className="navbar navbar-expand-lg navbar-light" style={{ backgroundColor: '#fff' }}>
                {/* Language Switcher */}
                <ul className="navbar-nav" style={{marginLeft: 'auto', marginRight: 'auto', flexDirection: 'row'}}>
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
                <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                    <span className="navbar-toggler-icon"></span>
                </button>
                <div className="collapse navbar-collapse" id="navbarNav">
                    {links}
                </div>
            </nav>
        </div>
    );
};
export default NavbarComponent;