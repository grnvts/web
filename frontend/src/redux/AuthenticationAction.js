import ApiService from "../Services/BaseService/ApiService";
import UserService from "../Services/UserService";
import * as ACTIONS from "./Constants";

export const logoutAction = () => ({ type: ACTIONS.LOGOUT_ACTION });

export const loginAction = (authData) => ({
    type: ACTIONS.LOGIN_ACTION,
    payload: authData
});

export const updateUser = (updateData) => ({
    type: ACTIONS.UPDATE_ACTION,
    payload: updateData
});

export const loginHandler = (credentials) => async (dispatch) => {
    try {
        const response = await ApiService.login(credentials);
        const { data } = response;

        const authState = {
            username: data.username,
            email: data.email,
            image: data.image,
            jwttoken: data.jwttoken,
            roles: data.roles,
            isLoggedIn: true
        };

        ApiService.changeAuthToken(data.jwttoken); // Устанавливаем токен
        dispatch(loginAction(authState)); // Обновляем Redux
        return response;
    } catch (error) {
        throw error;
    }
};

export const signupHandler = (user) => async (dispatch) => {
    try {
        const response = await UserService.post(user);
        return response;
    } catch (error) {
        throw error;
    }
};