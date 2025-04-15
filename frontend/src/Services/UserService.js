import ApiService from "./BaseService/ApiService";

const USER_URL  = '/user'
class UserService {

    getUsers(page, size){ 
        let url = '/users?page='+page+'&size='+size;
        return ApiService.get(USER_URL+url);
    }

    get(url) { 
        return ApiService.get(url)
    }
    getUserByUsername(username){
        return ApiService.get(USER_URL+'/'+username)
    }
    post(data) { 
        return ApiService.post(USER_URL,data)
    }
    update(username, body) {
        return ApiService.put(`/user/${username}`, body); // Без config!
    }


    loadImage(username,body) { 
        return ApiService.put(USER_URL+"/upload-image/"+username,body)
    }
    deleteUserById = (id, token) => {
        return fetch(`/api/user/${id}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        }).then(async response => {
            if (!response.ok) {
                const data = await response.json();
                throw data;
            }
            return response.json();
        });
    };

    //put(url, data) { return axios.put(API_BASE_URL + url, data); }

    //delete(url) { return axios.delete(API_BASE_URL + url); }
}

export default new UserService();