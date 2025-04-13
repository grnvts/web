import * as alertify from 'alertifyjs';
import "alertifyjs/build/css/alertify.css";
import "alertifyjs/build/css/themes/default.css";

class AlertifyService {
    alert(message) {
        alertify.alert(message);
    }

    success(message) {
        alertify.success(message);
    }

    error(message) {
        alertify.error(message);
    }

    // Сохраняем старые методы для обратной совместимости
    successMessage(message) {
        return this.success(message);
    }

    errorMessage(message) {
        return this.error(message);
    }
}

export default new AlertifyService();