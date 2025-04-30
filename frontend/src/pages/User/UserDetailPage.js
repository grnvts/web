import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next';
import { useDispatch, useSelector } from 'react-redux';
import { useParams, withRouter } from 'react-router-dom';
import Input from '../../components/input';
import UpdateUserForm from '../../components/UpdateUserForm';
import UserCard from '../../components/UserCard'
import ApiService from '../../Services/BaseService/ApiService';
import { updateUser } from '../../redux/AuthenticationAction';
import AlertifyService from '../../Services/AlertifyService';
import UserService from '../../Services/UserService';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faEdit, faTrash, faTimes, faSave } from '@fortawesome/free-solid-svg-icons';
import './UserDetailPage.css';

const UserDetailPage = (props) => {
    const [user, setUser] = useState({});
    const [notFound, setNotFound] = useState(false);
    const [newImage, setNewImage] = useState();
    const [errorImage, setErrorImage] = useState();
    const [editable, setEditable] = useState(false);
    const [inEditMode, setInEditMode] = useState(false);
    const { username } = useParams(); // this.props.match.params.username
    const { t } = useTranslation();

    const dispatch = useDispatch();
    const reduxStore = useSelector((store) => {
        return {
            isLoggedIn: store.isLoggedIn,
            username: store.username,
            email: store.email,
            jwttoken: store.jwttoken,
            password: store.password,
            image: store.image,
            roles: store.roles
        };
    })
    const isAdminEditingOtherUser = reduxStore.roles?.includes("ROLE_ADMIN") && reduxStore.username !== username;

    useEffect(() => {

        console.log("reduxStore.roles", reduxStore.roles);
    }, [reduxStore.roles])
    //console.log(reduxStore)
    useEffect(() => {
        console.log("reduxStore.roles", reduxStore.roles);
    }, []);

    useEffect(() => {
        loadUser();
    }, [username, inEditMode]); // Зависимость от inEditMode

    const handleUserUpdated = (updatedUser) => {
        setUser(updatedUser);
        if (reduxStore.username === updatedUser.username) {
            dispatch(updateUser({
                ...reduxStore,
                ...updatedUser
            }));
        }
    };
    const loadUser = async () => {
        setNotFound(false);
        setEditable(false);

        try {
            const response = await UserService.getUserByUsername(username, reduxStore.jwttoken);
            if (!response.data) {
                throw new Error("User not found");
            }
            setUser(response.data);

            const isOwner = reduxStore.username === username;
            const isAdmin = reduxStore.roles?.includes("ROLE_ADMIN");

            if (!isOwner && !isAdmin) {
                AlertifyService.error(t("You don't have permission to view this profile"));
                props.history.push('/index');
                return;
            }

            setEditable(isOwner || isAdmin);
        } catch (error) {
            console.error(error);
            if (error.response) {
                if (error.response.status === 401) {
                    AlertifyService.error(t("Session expired. Please login again"));
                    props.history.push('/login');
                } else if (error.response.status === 404) {
                    AlertifyService.alert("User not found !!");
                    setNotFound(true);
                }
            } else {
                AlertifyService.alert("Error loading user data");
                setNotFound(true);
            }
        }
    };

    const showUpdateForm = (control) => {
        setInEditMode(control);
        if (!control) {
            setErrorImage(undefined);
            setNewImage(undefined);
        }
    }
    const deleteUser = async () => {
        if (!window.confirm(t("Are you sure you want to delete your account?"))) {
            return;
        }

        try {
            const response = await UserService.deleteUserById(user.id, reduxStore.jwttoken);
            
            AlertifyService.success(t("User account deleted"));
              // Проверяем, удаляет ли пользователь свой собственный аккаунт
            if (reduxStore.username === user.username) {
                // Очистка данных авторизации и выход из аккаунта
                ApiService.clearAuthToken(); // Удаляет токен из заголовков
                dispatch({ type: 'ACTIONS.LOGOUT_ACTION' }); // Очищает данные пользователя из Redux
                props.history.push('/login'); // Перенаправление на страницу входа
            } else {
                // Если администратор удаляет чужой аккаунт, просто обновляем страницу
                props.history.push('/');
            }
            
        } catch (error) {
            AlertifyService.error("Failed to delete user");
            console.error(error);
        }
    };
    const saveImage = async (e) => {
        setErrorImage(undefined)
        //data:image/jpeg;base64,/9j/4AAQSkZJRgA
        e.preventDefault();
        let body = { ...user };
        if (newImage) {
            body['image'] = newImage.split(",")[1];
            try {
                //console.log(body)
                const response = await UserService.loadImage(username, body);
                //console.log(response.data)
                if (response.data.body.message) {
                    setErrorImage(response.data.body.message);
                    AlertifyService.alert(response.data.body.message);
                }
                else {
                    let authData= {...reduxStore, image: response.data.body.image}
                    //console.log(authData)
                    dispatch(updateUser(authData));
                    AlertifyService.success ("User Image Updated..");
                    showUpdateForm(false)
                }
            } catch (error) {
                if (error.response) {
                    console.log(error.response)
                    if(error.response.data.validationErrors.image){
                        setErrorImage(error.response.data.validationErrors.image);
                        AlertifyService.error(error.response.data.validationErrors.image);
                    }
                }
                else if (error.request)
                    console.log(error.request);
                else
                    console.log(error.message);
            }
        } else {
            AlertifyService.alert("Фотография профиля не обновлена.");
        }


    }
    const onChangeData = (type, event) => {
        if (event.target.files.length < 1) {
            return;
        }
        const file = event.target.files[0];
        const fileReader = new FileReader();
        fileReader.onloadend = () => {
            setNewImage(fileReader.result);
        }
        fileReader.readAsDataURL(file);
    };
    if (notFound) {
        return (
            <div className="container">
                <div className="alert alert-danger">User not found !!</div>
            </div>
        )
    } else if (!notFound) {
        return (
            <div className="user-detail-container">
                <div className="user-detail-header">
                    <h5>{t('User Detail')}</h5>
                </div>

                <UserCard
                    user={user}
                    newImage={newImage}
                    editable={editable}
                    username={username}
                />
                {
                    editable &&
                    <div className="action-buttons">
                        {!inEditMode ? (
                            <>
                                <button
                                    onClick={e => showUpdateForm(true)}
                                    className="action-button edit-button">
                                    <FontAwesomeIcon icon={faEdit} />
                                    {t('Edit')}
                                </button>

                                <button
                                    onClick={deleteUser}
                                    className="action-button delete-button">
                                    <FontAwesomeIcon icon={faTrash} />
                                    {t('Delete Account')}
                                </button>
                            </>
                        ) : (
                            <button
                                onClick={e => showUpdateForm(false)}
                                className="action-button cancel-button">
                                <FontAwesomeIcon icon={faTimes} />
                                {t('Cancel')}
                            </button>
                        )}
                    </div>
                }
                
                {inEditMode && (
                    <div className="row">
                        <div className="col-sm-7">
                            <UpdateUserForm
                                user={user}
                                inEditMode={inEditMode}
                                newImage={newImage}
                                showUpdateForm={showUpdateForm}
                                isAdminEditingOtherUser={isAdminEditingOtherUser}
                                onUserUpdated={handleUserUpdated}
                            />
                        </div>
                        {!isAdminEditingOtherUser && (
                            <div className="col-sm-5">
                                <div className="image-edit-section">
                                    <div className="image-edit-header">
                                        <h5>{t("Change Image")}</h5>
                                    </div>
                                    <div className="image-edit-content">
                                        <div className="image-format-info">
                                            {t("Supported formats: PNG or JPEG")}
                                        </div>
                                        <Input
                                            error={errorImage}
                                            name="image"
                                            type="file"
                                            onChangeData={onChangeData}
                                            className="image-upload-input"
                                        />
                                        <div className="image-upload-buttons">
                                            <button
                                                onClick={saveImage}
                                                className="save-image-button">
                                                <FontAwesomeIcon icon={faSave} />
                                                {t('Save')}
                                            </button>
                                            <button
                                                onClick={e => showUpdateForm(false)}
                                                className="action-button cancel-button">
                                                <FontAwesomeIcon icon={faTimes} />
                                                {t('Cancel')}
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                )}
            </div>
        )
    }
};

export default withRouter(UserDetailPage) ;

