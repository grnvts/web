import React, { Component } from "react";
import Input from "../../components/input";
import { withTranslation } from "react-i18next";
import UserService from "../../Services/UserService";
import AlertifyService from "../../Services/AlertifyService";

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
      bornDate: new Date(),
      roles: [],
      errors: {},
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
    const { options } = e.target;
    const selectedRoles = Array.from(options)
      .filter((option) => option.selected)
      .map((option) => option.value);
    this.setState({ roles: selectedRoles });
  };

  onClickCreateUser = async (e) => {
    e.preventDefault();
    this.setState({ errors: {} });

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
      roles,
    } = this.state;

    if (password !== repeatPassword) {
      AlertifyService.error(this.props.t("Password mismatch"));
      return;
    }

    const userData = {
      username,
      password,
      email,
      name,
      surname,
      patronymic,
      phone,
      bornDate,
      roles,
    };

    try {
      await UserService.createUserWithRoles(userData);
      AlertifyService.success(this.props.t("User created successfully!"));
      this.props.history.push("/users");
    } catch (error) {
      if (error.response && error.response.data.validationErrors) {
        this.setState({ errors: error.response.data.validationErrors });
      } else {
        AlertifyService.error(this.props.t("Failed to create user."));
      }
    }
  };

  render() {
    const { t } = this.props;
    const { username, password, repeatPassword, email, name, surname, patronymic, phone, bornDate, errors } = this.state;

    return (
      <div className="container">
        <h3>{t("Create User")}</h3>
        <form>
          <Input
            label={t("Username *")}
            error={errors.username}
            type="text"
            name="username"
            placeholder={t("Username *")}
            value={username}
            onChangeData={this.onChangeData}
          />
          <Input
            label={t("Password *")}
            error={errors.password}
            type="password"
            name="password"
            placeholder={t("Password *")}
            value={password}
            onChangeData={this.onChangeData}
          />
          <Input
            label={t("Repeat Password *")}
            error={errors.repeatPassword}
            type="password"
            name="repeatPassword"
            placeholder={t("Repeat Password *")}
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
          <Input
            label={t("Name")}
            type="text"
            name="name"
            placeholder={t("Name")}
            value={name}
            onChangeData={this.onChangeData}
          />
          <Input
            label={t("Surname")}
            type="text"
            name="surname"
            placeholder={t("Surname")}
            value={surname}
            onChangeData={this.onChangeData}
          />
          <Input
            label={t("Patronymic")}
            type="text"
            name="patronymic"
            placeholder={t("Patronymic")}
            value={patronymic}
            onChangeData={this.onChangeData}
          />
          <Input
            label={t("Phone")}
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
            onChange={this.onChangeData}
            />
          </div>
          <div className="form-group">
            <label>{t("Roles")}</label>
            <select multiple className="form-control" onChange={this.handleRoleChange}>
              <option value="ROLE_USER">{t("User")}</option>
              <option value="ROLE_ADMIN">{t("Admin")}</option>
              <option value="ROLE_BRIGADIER">{t("Brigadier")}</option>
            </select>
          </div>
          <button className="btn btn-primary" onClick={this.onClickCreateUser}>
            {t("Create User")}
          </button>
        </form>
      </div>
    );
  }
}

export default withTranslation()(CreateUserPage);