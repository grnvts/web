
import React, { Component } from 'react'
import { withTranslation } from 'react-i18next';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { logoutAction } from '../redux/AuthenticationAction';
import AlertifyService from '../Services/AlertifyService';
import ApiService from '../Services/BaseService/ApiService';
import UserService from '../Services/UserService';
import Input from './input';
import { updateUser } from '../redux/AuthenticationAction';

class UpdateUserForm extends Component {
    constructor(props) {
        super(props);
        this.state = {
            id: null,
            username: '',
            email: '',
            name: '',
            surname: '',
            errors: {
            }
        };
        this.loadInputs = this.loadInputs.bind(this);
    }

    componentDidMount(){
        const { user } = this.props;
        this.loadInputs(user);
    }
    loadInputs =  (user) =>{
        // const { user } = props;
        console.log("Editing user:", user);

        this.setState({ ...user });
    }
    onChangeData = (type, event) =>{
        const stateData = this.state;
        stateData[type] = event
        const errors = { ...this.state.errors }
        errors[type] = undefined;
        this.setState({ stateData, errors: errors });
    }
    onClickSave = async (e) => {
        e.preventDefault();
        this.setState({ errors: {} });
        const body = this.state;





        try {
            const response = await UserService.update(
                this.props.user.username, // обновляемого юзера
                body,
                this.props.jwttoken       // токен текущего авторизованного пользователя (админа)
            );


            // const data = {isLoggedIn, jwttoken,password, ...response.data.body};
            // this.props.dispatch(updateUser(data));
            // this.props.showUpdateForm(false)
            // this.props.history.push("/user/"+data.username)

            if (response.status === 200) {
                if (this.props.isAdminEditingOtherUser) {
                    console.log(response.data)
                    AlertifyService.success("User updated successfully");
                    this.props.onUserUpdated(response.data.body);
                    this.props.showUpdateForm(false);
                } else {
                    const updatedUser = {
                        ...this.props,
                        ...response.data.body,
                        // Если роли приходят как Set, конвертируем в массив
                        roles: response.data.roles ? Array.from(response.data.roles) : []
                    };
                    this.props.dispatch(updateUser(updatedUser));
                    AlertifyService.success("Profile updated successfully");
                    this.props.showUpdateForm(false);

                    // Если изменился username, обновляем токен (если он возвращается)
                    if (response.data.jwttoken) {
                        ApiService.changeAuthToken(response.data.jwttoken);
                    }
                }
            }
        } catch (error) {
            // Обработка ошибок Axios
            if (error.response) {
                const { status, data } = error.response;

                // Ошибка доступа (403)
                if (status === 403) {
                    AlertifyService.error(data.message || "You don't have permission to update this user.");

                    // Ошибки валидации (400)
                } else if (status === 400 && data.validationErrors) {
                    this.setState({ errors: data.validationErrors });

                    // Другие ошибки
                } else {
                    AlertifyService.error(data.message || "An error occurred while updating the user.");
                }

            } else {
                AlertifyService.error("Network error or server is unavailable.");
            }
        }
    }
    logoutForChangingUserData = () =>{
        ApiService.changeAuthToken(null);
        this.props.dispatch(logoutAction());
    }
    render() {
        const { t /*,user*/ } = this.props;
        const { username,email /*,bornDate*/} = this.state.errors;
        return (
            <div>
                {this.props.inEditMode &&
                    <form>
                        <h5 className="card-header text-center">{t("Change User Info")}</h5>
                        <Input
                        label={t("Username *")}
                        error={username}
                        type="text"
                        name="username"
                        placeholder={t("Username *")}
                        valueName={this.state.username}
                        onChangeData={this.onChangeData}
                        disabled={this.props.isAdminEditingOtherUser}

                        />
                    <Input
                        label={t("Email *")}
                        type="email"
                        error={email}
                        name="email"
                        placeholder={t("Email *")}
                        valueName={this.state.email}
                        onChangeData={this.onChangeData}
                    />
                    <Input
                        label={t("Name")}
                        type="text"
                        name="name"
                        placeholder={t("Name")}
                        valueName={this.state.name}
                        onChangeData={this.onChangeData}
                    />
                    <Input
                        label={t("Surname")}
                        type="text"
                        name="surname"
                        placeholder={t("Surname")}
                        valueName={this.state.surname}
                        onChangeData={this.onChangeData}
                    />
                    <button
                        className="btn btn-primary "
                        type="button"
                        onClick={this.onClickSave}>{t('Update')}</button>

                    </form>
                }
            </div>
        )
    }
}
const mapStateToProps = (store) => {
    return {
        isLoggedIn: store.isLoggedIn,
        username: store.username,
        email: store.email,
        jwttoken: store.jwttoken,
        password: store.password,
        image: store.image
    };
};
export default connect(mapStateToProps)(withTranslation()(withRouter(UpdateUserForm)));