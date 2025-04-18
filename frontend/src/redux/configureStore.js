import { createStore, applyMiddleware, compose } from 'redux';
import authReducer from './AuthenticationReducer';
import SecureLS from "secure-ls";
import thunk from 'redux-thunk';
import ApiService from '../Services/BaseService/ApiService';

const secureLS = new SecureLS();


const getStateFromStorage = () => {
  const auth = secureLS.get("auth");

  if (auth?.jwttoken) {
    try {
      const payload = JSON.parse(atob(auth.jwttoken.split('.')[1]));
      const exp = payload.exp * 1000;
      if (Date.now() > exp) {
        secureLS.remove("auth");
        ApiService.changeAuthToken(null);
        window.location.href = '/login'; // 👈 либо используем history.push("/login")
        return {
          isLoggedIn: false
        };
      }
    } catch (e) {
      console.error("Invalid JWT", e);
    }
  }

  return auth || {
    isLoggedIn: false
  };
};




const updateStateInStorage = newState => {
  secureLS.set("auth", newState);
  //localStorage.setItem("auth", JSON.stringify(newState));
}

const configureStore = () => {
  const composeEnhancer = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
  //  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
  const store = createStore(
      authReducer,
      getStateFromStorage(),
      composeEnhancer(applyMiddleware(thunk))
  );

  store.subscribe(() => {
    // insert data to local Storage
    updateStateInStorage(store.getState());
  });
  return store;
}


export default configureStore;