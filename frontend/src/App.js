import React, { Component } from 'react';
import './App.css';
import { BrowserRouter, Route, Redirect, Switch } from 'react-router-dom';
import { connect } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import configureStore from './redux/configureStore';

// Components
import UserSignupPage from './pages/User/UserSignupPage';
import UserLoginPage from './pages/User/UserLoginPage';
import LanguageSelector from './components/LanguageSelector';
import NavbarComponent from './pages/Navbar';
import UserDetailPage from './pages/User/UserDetailPage';
import HomeComponent from './pages/HomeComponent';
import AuthenticatedRoute from './components/AuthenticatedRoute';
import UsersPage from './pages/User/UsersPage';
import BuildingComponent from './pages/Building/BuildingComponent';
import UpdateBuilding from './pages/Building/UpdateBuilding';
import BuildingDetail from './pages/Building/BuildingDetail';

const { store, persistor } = configureStore();

class App extends Component {
  handleLogoutSuccess = () => {
    persistor.purge();
    return <Redirect to="/login" />;
  };

  renderRoutes = () => {
    const { isLoggedIn } = this.props;

    return (
        <Switch>
          {!isLoggedIn ? (
              <>
                <Route exact path="/login" component={UserLoginPage} />
                <Route path="/signup" component={UserSignupPage} />
                <Redirect from="/" to="/login" />
              </>
          ) : (
              <>
                <AuthenticatedRoute exact path="/index" component={HomeComponent} />
                <AuthenticatedRoute path="/user/:username" component={UserDetailPage} />
                <AuthenticatedRoute exact path="/users" component={UsersPage} />
                <AuthenticatedRoute path="/building/:username" component={BuildingComponent} />
                <AuthenticatedRoute path="/update-building/:buildingid" component={UpdateBuilding} />
                <AuthenticatedRoute path="/building-card/:buildingid" component={BuildingDetail} />
                <Redirect from="/" to="/index" />
              </>
          )}
        </Switch>
    );
  };

  render() {
    return (
        <BrowserRouter>
          <PersistGate loading={null} persistor={persistor}>
            <div className="container">
              <div className="row">
                <div className="col-sm-12">
                  <NavbarComponent onLogoutSuccess={this.handleLogoutSuccess} />
                  <LanguageSelector />
                  {this.renderRoutes()}
                </div>
              </div>
            </div>
          </PersistGate>
        </BrowserRouter>
    );
  }
}

const mapStateToProps = (state) => ({
  isLoggedIn: state.auth.isLoggedIn,
  username: state.auth.username,
  jwttoken: state.auth.jwttoken
});

export default connect(mapStateToProps)(App);