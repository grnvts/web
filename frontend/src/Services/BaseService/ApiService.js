import Axios from "axios";
import { connect } from "react-redux";
import { logoutAction } from "../../redux/AuthenticationAction";

const API_BASE_URL = 'http://localhost:8501/api';
const LOGIN_URL = '/login';
class ApiService {

    get(url, config = {}) {
        return Axios.get(API_BASE_URL + url, config);
      }
    post(url, data) { return Axios.post(API_BASE_URL + url, data); }

    put(url, data) { return Axios.put(API_BASE_URL + url, data); }

    delete(url) { return Axios.delete(API_BASE_URL + url); }

    login(data) { return Axios.post(API_BASE_URL + LOGIN_URL, data); }

    changeAuthToken(jwt) {
        if (jwt) {
            Axios.defaults.headers.common['Authorization'] = 'Bearer ' + jwt;
            
            console.log('JWT Token:', jwt);
console.log('Authorization header after set:', Axios.defaults.headers.common['Authorization']);
        } else {
            delete Axios.defaults.headers.common['Authorization'];
            console.log('Authorization header removed');
        }
    }
    
    changeLanguage(lg) { Axios.defaults.headers["accept-language"] = lg; }
}


//export default connect()(new ApiService());
export default new ApiService();