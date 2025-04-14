import { createStore, applyMiddleware, compose, combineReducers } from 'redux';
import { persistStore, persistReducer } from 'redux-persist';
import SecureLS from 'secure-ls';
import thunk from 'redux-thunk';
import authReducer from './AuthenticationReducer';
import ApiService from '../Services/BaseService/ApiService';

const secureLS = new SecureLS({
  encodingType: 'aes',
  encryptionSecret: 'your-secret-key' // Замените на реальный секретный ключ
});

const persistConfig = {
  key: 'root',
  storage: {
    getItem: (key) => Promise.resolve(secureLS.get(key)),
    setItem: (key, value) => Promise.resolve(secureLS.set(key, value)),
    removeItem: (key) => Promise.resolve(secureLS.remove(key))
  },
  whitelist: ['auth']
};

const rootReducer = combineReducers({
  auth: authReducer
});

const persistedReducer = persistReducer(persistConfig, rootReducer);

const configureStore = () => {
  const composeEnhancer = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

  const store = createStore(
      persistedReducer,
      composeEnhancer(applyMiddleware(thunk))
  );

  const persistor = persistStore(store, null, () => {
    const state = store.getState();
    if (state.auth?.jwttoken) {
      ApiService.changeAuthToken(state.auth.jwttoken);
    }
  });

  return { store, persistor };
};

export default configureStore;