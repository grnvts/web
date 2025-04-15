import * as ACTIONS from "./Constants";

const defaultState = {
    isLoggedIn: false,
    username: undefined,
    jwttoken: undefined,
    password: undefined,
    email: undefined,
    image: undefined,
    roles: []
}
const initialState = {
    isLoggedIn: false,
    username: null,
    jwttoken: null,
    password: undefined,
    email: undefined,
    image: undefined,
    roles: []
};

// const authReducer = (state = { ...defaultState }, action) => {
//     if (action.type === ACTIONS.LOGOUT_ACTION) {
//         return defaultState;
//     }
//     if (action.type ===  ACTIONS.LOGIN_ACTION ) {
//         return {
//             ...action.payload
//         };
//     }
//     if(action.type === ACTIONS.UPDATE_ACTION){
//         return {...action.payload};
//     }
//     return state;
// };
function authReducer(state = initialState, action) {
    switch(action.type) {
        case 'LOGIN_ACTION':
            return {
                ...state,
                ...action.payload,
                isLoggedIn: true
            };
        case 'LOGOUT_ACTION':
            return initialState;
        default:
            return state;
    }
}
export default authReducer;