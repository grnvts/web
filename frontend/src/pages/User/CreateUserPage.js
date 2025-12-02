import React, { Component } from 'react';
import { useHistory } from 'react-router-dom';
import { withTranslation } from 'react-i18next';
import UserService from "../../Services/UserService";
import AlertifyService from "../../Services/AlertifyService";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { 
  faArrowLeft, 
  faUser, 
  faUserTie, 
  faUserCog,
  faSpinner,
  faTimes,
  faCheck
} from '@fortawesome/free-solid-svg-icons';
import Input from "../../components/input";
import './CreateUserPage.css';

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const phonePattern = /^\+\d{11,14}$/;
const namePattern = /^[\p{L}\s'-]+$/u;

class CreateUserPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      username: "",
      password: "",
      repeatPassword: "",
      email: "",
      name: "",
      surname: "",
      patronymic: "",
      phone: "",
      bornDate: "",
      role: "",
      errors: {},
      loading: false
    };
  }

  onChangeData = (name, value) => {
    const stateData = { ...this.state };
    stateData[name] = value;
    const errors = { ...this.state.errors };
    errors[name] = undefined;

    if (name === "password" || name === "repeatPassword") {
      if (stateData.password !== stateData.repeatPassword) {
        errors.repeatPassword = this.props.t("Password mismatch");
      } else {
        errors.repeatPassword = undefined;
      }
    }

    this.setState({ ...stateData, errors });
  };

  handleRoleChange = (e) => {
    this.setState({ role: e.target.value });
  };

  validateForm = () => {
    const errors = {};
    const { username, password, repeatPassword, email, name, surname, patronymic, role, phone } = this.state;
    const { t } = this.props;

    if (!username.trim()) errors.username = t("Username is required");
    if (!password.trim()) errors.password = t("Password is required");
    if (!repeatPassword.trim()) errors.repeatPassword = t("Repeat password is required");
    if (!email.trim()) {
      errors.email = t("Email is required");
    } else if (!emailPattern.test(email.trim())) {
      errors.email = t("Invalid email format");
    }
    if (!name.trim()) errors.name = t("Name is required");
    if (!surname.trim()) errors.surname = t("Surname is required");
    if (!patronymic.trim()) errors.patronymic = t("Patronymic is required");
    if (!role) errors.role = t("Role is required");
    if (phone && phone.trim() && !phonePattern.test(phone.trim())) {
      errors.phone = t("Invalid phone format");
    }

    ['name', 'surname', 'patronymic'].forEach((field) => {
      const value = this.state[field];
      if (value && value.trim() && !namePattern.test(value.trim())) {
        errors[field] = t("Name can contain only letters");
      }
    });

    if (password !== repeatPassword) {
      errors.repeatPassword = t("Password mismatch");
    }

    return errors;
  };

  onClickCreateUser = async (e) => {
    e.preventDefault();
    this.setState({ errors: {}, loading: true });

    const validationErrors = this.validateForm();
    if (Object.keys(validationErrors).length > 0) {
      this.setState({ errors: validationErrors, loading: false });
      return;
    }

    const {
      username,
      password,
      email,
      name,
      surname,
      patronymic,
      phone,
      bornDate,
      role,
    } = this.state;

    const userData = {
      username: username.trim(),
      password: password.trim(),
      email: email.trim(),
      name: name.trim(),
      surname: surname.trim(),
      patronymic: patronymic.trim(),
      phone: phone ? phone.trim() : null,
      bornDate: bornDate || null,
      roles: [role],
      status: 1
    };

    try {
      const response = await UserService.createUserWithRoles(userData);
      if (response && response.status === 200) {
        AlertifyService.success(this.props.t("User created successfully!"));
        this.props.history.push("/users");
      } else {
        throw new Error("Failed to create user");
      }
    } catch (error) {
      if (error.response && error.response.data.validationErrors) {
        this.setState({ errors: error.response.data.validationErrors });
      } else {
        AlertifyService.error(this.props.t("Failed to create user."));
      }
    } finally {
      this.setState({ loading: false });
    }
  };

  handleCancel = () => {
    this.props.history.push('/users');
  };

  render() {
    const { t } = this.props;
    const {
      username,
      password,
      repeatPassword,
      email,
      name,
      surname,
      patronymic,
      phone,
      bornDate,
      role,
      errors,
      loading
    } = this.state;

    return (
      <div className="create-user-container">
        <div className="create-user-header">
          <h2>{t("Creating User")}</h2>
          <button className="back-button" onClick={this.handleCancel}>
            <FontAwesomeIcon icon={faArrowLeft} />
            {t("Back")}
          </button>
        </div>

        <form onSubmit={this.onClickCreateUser} className="create-user-form">
          <div className="form-grid">
            <div className="form-section">
              <h3>{t("Basic Information")}</h3>
              <Input
                label={t("Username")}
                error={errors.username}
                type="text"
                name="username"
                placeholder={t("Username")}
                value={username}
                onChangeData={this.onChangeData}
              />
              <Input
                label={t("Password")}
                error={errors.password}
                type="password"
                name="password"
                placeholder={t("Password")}
                value={password}
                onChangeData={this.onChangeData}
              />
              <Input
                label={t("Repeat Password")}
                error={errors.repeatPassword}
                type="password"
                name="repeatPassword"
                placeholder={t("Repeat Password")}
                value={repeatPassword}
                onChangeData={this.onChangeData}
              />
              <Input
                label={t("Email *")}
                error={errors.email}
                type="email"
                name="email"
                placeholder={t("Email *")}
                value={email}
                onChangeData={this.onChangeData}
              />
            </div>

            <div className="form-section">
              <h3>{t("Personal Information")}</h3>
              <Input
                label={t("Name")}
                error={errors.name}
                type="text"
                name="name"
                placeholder={t("Name")}
                value={name}
                onChangeData={this.onChangeData}
              />
              <Input
                label={t("Surname")}
                error={errors.surname}
                type="text"
                name="surname"
                placeholder={t("Surname")}
                value={surname}
                onChangeData={this.onChangeData}
              />
              <Input
                label={t("Patronymic")}
                error={errors.patronymic}
                type="text"
                name="patronymic"
                placeholder={t("Patronymic")}
                value={patronymic}
                onChangeData={this.onChangeData}
              />
              <Input
                label={t("Phone")}
                error={errors.phone}
                type="tel"
                name="phone"
                placeholder={t("Phone (e.g. +3754467890)")}
                value={phone}
                onChangeData={this.onChangeData}
              />
              <div className="form-group">
                <label>{t("Born Date")}</label>
                <input
                  type="date"
                  name="bornDate"
                  className="form-control"
                  value={bornDate ? new Date(bornDate).toISOString().slice(0, 10) : ""}
                  onChange={(e) => this.onChangeData("bornDate", e.target.value)}
                />
              </div>
            </div>
          </div>

          <div className="form-section roles-section">
            <h3>{t("User Role")}</h3>
            <div className="roles-grid">
              <label className="role-option">
                <input
                  type="radio"
                  name="role"
                  value="ROLE_USER"
                  checked={role === "ROLE_USER"}
                  onChange={this.handleRoleChange}
                />
                <span className="role-label">
                  <FontAwesomeIcon icon={faUser} />
                  {t("User")}
                </span>
              </label>
              <label className="role-option">
                <input
                  type="radio"
                  name="role"
                  value="ROLE_ADMIN"
                  checked={role === "ROLE_ADMIN"}
                  onChange={this.handleRoleChange}
                />
                <span className="role-label">
                  <FontAwesomeIcon icon={faUserCog} />
                  {t("Admin")}
                </span>
              </label>
              <label className="role-option">
                <input
                  type="radio"
                  name="role"
                  value="ROLE_BRIGADIER"
                  checked={role === "ROLE_BRIGADIER"}
                  onChange={this.handleRoleChange}
                />
                <span className="role-label">
                  <FontAwesomeIcon icon={faUserTie} />
                  {t("Brigadier")}
                </span>
              </label>
            </div>
            {errors.role && <div className="error-message">{errors.role}</div>}
          </div>

          <div className="form-actions">
            <button type="button" className="cancel-button" onClick={this.handleCancel}>
              <FontAwesomeIcon icon={faTimes} />
              {t("Cancel")}
            </button>
            <button type="submit" className="submit-button" disabled={loading}>
              {loading ? (
                <>
                  <FontAwesomeIcon icon={faSpinner} spin />
                  {t("Creating...")}
                </>
              ) : (
                <>
                  <FontAwesomeIcon icon={faCheck} />
                  {t("Create User")}
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    );
  }
}

export default withTranslation()(CreateUserPage);