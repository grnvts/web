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
        return ApiService.put(`/user/${username}`, body); 
    }
    createUserWithRoles(data) {
        return ApiService.post('/user/create', data);
    }

    createMaster(data) {
        return ApiService.post('/user/masters', data);
      }

    getBrigadeMasters(brigadeId) {
        return ApiService.get(`/orders/brigade/${brigadeId}/masters`);
      }
      
    loadImage(username,body) { 
        return ApiService.put(USER_URL+"/upload-image/"+username,body)
    }
    getQualifications() {
    
        return ApiService.get('/user/qualifications');
      }
    deleteUserById = (id, token) => {
        return fetch(`http://localhost:8501/api/user/${id}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`
            }
      
        
        }).then(async response => {
            const contentType = response.headers.get("content-type");
            if (!response.ok) {
                if (contentType && contentType.includes("application/json")) {
                    const data = await response.json();
                    throw data;
                } else {
                    throw new Error("Unexpected server response");
                }
            }
            return response.json();
        });
    };

    restoreUser = (id, token) => {
        if (!token) {
            throw new Error('Authorization token is missing');
        }
        return fetch(`http://localhost:8501/api/user/${id}/restore`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        }).then(async (response) => {
            if (!response.ok) {
                const errorText = await response.text();
                console.error('Restore user failed:', errorText);
                throw new Error('Failed to restore user');
            }
            return response.json();
        });
    };
    

    getUserNotifications() {
        return ApiService.get('/notifications');
      }
    //put(url, data) { return axios.put(API_BASE_URL + url, data); }

    //delete(url) { return axios.delete(API_BASE_URL + url); }
}

export default new UserService();