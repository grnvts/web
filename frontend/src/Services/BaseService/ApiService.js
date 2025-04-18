import Axios from "axios";
import { connect } from "react-redux";
import { logoutAction } from "../../redux/AuthenticationAction";

const API_BASE_URL = 'http://localhost:8501/api';
const LOGIN_URL = '/login';
class ApiService {

    get(url) {
        console.log('Authorization header:', Axios.defaults.headers['Authorization']);
        return Axios.get(API_BASE_URL + url);
    }
    post(url, data) { return Axios.post(API_BASE_URL + url, data); }

    put(url, data) { return Axios.put(API_BASE_URL + url, data); }

    delete(url) { return Axios.delete(API_BASE_URL + url); }

    login(data) { return Axios.post(API_BASE_URL + LOGIN_URL, data); }

    changeAuthToken(jwt) {
        console.log('Setting Authorization header:', jwt);
        if (jwt) {
            Axios.defaults.headers['Authorization'] = 'Bearer ' + jwt;
        } else {
            Axios.defaults.headers['Authorization'] = null;
        }
    }

    changeLanguage(lg) { Axios.defaults.headers["accept-language"] = lg; }
}


//export default connect()(new ApiService());
export default new ApiService();