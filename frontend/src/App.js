import React, { Component, useEffect } from 'react'
import './App.css';
import UserSignupPage from './pages/User/UserSignupPage';
import UserLoginPage from './pages/User/UserLoginPage';

import { Route, BrowserRouter, Redirect, Switch } from 'react-router-dom';
import NavbarComponent from './pages/Navbar';
import UserDetailPage from './pages/User/UserDetailPage';
import HomeComponent from './pages/HomeComponent';
import AuthenticatedRoute from './components/AuthenticatedRoute';
import { connect } from 'react-redux';
import ApiService from './Services/BaseService/ApiService';
import UsersPage from './pages/User/UsersPage';
import MyOrdersPage from "./pages/Orders/MyOrdersPage";
import OrderDetailPage from "./pages/Orders/OrderDetailPage";
import CreateOrderPage from "./pages/Orders/CreateOrderPage";
import EditOrderPage from './pages/Orders/EditOrderPage';
import AllOrdersPage from './pages/Orders/AllOrdersPage';
import CreateUserPage from './pages/User/CreateUserPage';
import BrigadierOrdersPage from './pages/Brigadier/BrigadierOrdersPage';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min';
import AllBrigadesPage from './pages/Brigade/AllBrigadesPage';
import BrigadeManagePage from './pages/Brigade/BrigadeManagePage';
import HomePage from './components/HomePage/HomePage';
class App extends Component {

    constructor(props) {
        super(props);
        this.state = {
            username: null,
            isLoggedIn: null,
            jwttoken: null,
            email: null,
            image: null
        };
        // this.onLoginSuccess = this.onLoginSuccess.bind(this);
        // this.onLogoutSuccess = this.onLogoutSuccess.bind(this);
    }

    onLoginSuccess = (authState) => {
        ApiService.changeAuthToken(authState.jwttoken);
        localStorage.setItem("username", authState.username);
        localStorage.setItem("jwttoken", authState.jwttoken);
        localStorage.setItem("isLoggedIn", true);
        this.setState({ ...authState, isLoggedIn: true });
        console.log('JWT Token set in onLoginSuccess:', authState.jwttoken);

        return <Redirect to="/index" />
    }
    onLogoutSuccess = () => {
        ApiService.changeAuthToken(null);
        localStorage.removeItem("jwttoken");
        localStorage.removeItem("username");
        localStorage.removeItem("isLoggedIn");
        //console.log(localStorage)
        this.setState({
            isLoggedin: false,
            username: null,
            jwttoken: null
        });
        return <Redirect to="/login" />
    }
    //componentDidMount() {
       // const token = localStorage.getItem('jwttoken');
        //ApiService.changeAuthToken(token);
      //}
      
    
    back() {
        this.props.history.push('/login');
    }
    render() {
        console.log(this.props.time)
        // localStorage.removeItem("jwttoken");
        // localStorage.removeItem("username");
        // localStorage.removeItem("isLoggedIn");

        let links = null;
        const { isLoggedIn } = this.props;

        
        //console.log(this.props)
        // if not logged in
        //if (!AuthenticationService.isUserLoggedIn() ) {
        if (!isLoggedIn) {
            links = (
                <Switch>
                    <Route exact path="/login" component={(props) => <UserLoginPage {...props} onLoginSuccess={this.onLoginSuccess} />} />
                    <Route path="/signup" component={UserSignupPage} />
                    <Route exact path="/" component={(props) => <UserLoginPage {...props} onLoginSuccess={this.onLoginSuccess} />} />
                    <Redirect to="/" />
                </Switch>
            );
        }
        // if logged in
        //if(AuthenticationService.isUserLoggedIn())  {
        if (isLoggedIn) {
            links = (
                <Switch>
                   <AuthenticatedRoute exact path="/index" component={HomePage} isLoggedIn={isLoggedIn} />
                    <AuthenticatedRoute path="/user/:username" component={UserDetailPage} isLoggedIn={isLoggedIn} />
                    <AuthenticatedRoute exact path="/users" component={UsersPage} isLoggedIn={isLoggedIn} roles={['ROLE_ADMIN']} />
                    <AuthenticatedRoute exact path="/orders/brigadier" component={BrigadierOrdersPage} isLoggedIn={isLoggedIn} roles={['ROLE_BRIGADIER']} />
                    <AuthenticatedRoute exact path="/orders/brigadier/active" component={BrigadierOrdersPage} isLoggedIn={isLoggedIn} roles={['ROLE_BRIGADIER']} />
                    <AuthenticatedRoute exact path="/orders/all" component={AllOrdersPage} isLoggedIn={isLoggedIn} roles={['ROLE_ADMIN']}/>               
                    <AuthenticatedRoute path="/orders/:orderId/edit" component={EditOrderPage} isLoggedIn={isLoggedIn} roles={['ROLE_ADMIN']}/>
                    <AuthenticatedRoute exact path="/orders" component={MyOrdersPage} isLoggedIn={isLoggedIn} />
                    <AuthenticatedRoute exact path="/orders/create" component={CreateOrderPage} isLoggedIn={isLoggedIn} />
                    <AuthenticatedRoute exact path="/orders/:orderId" component={OrderDetailPage} isLoggedIn={isLoggedIn} />
                    <AuthenticatedRoute path="/create-user" component={CreateUserPage} isLoggedIn={isLoggedIn} roles={['ROLE_ADMIN']}/>
                    <AuthenticatedRoute exact path="/brigades" component={AllBrigadesPage} isLoggedIn={isLoggedIn} roles={['ROLE_ADMIN']} />
                    <AuthenticatedRoute exact path="/brigade/manage" component={BrigadeManagePage} isLoggedIn={isLoggedIn} roles={['ROLE_BRIGADIER']} />
                    <Redirect to="/index" />
                </Switch>
            );
        }
        return (
            <div style={{width: '100%', padding: 0}}>
                <div className="row">

                    <div className="col-sm-12">
                        <BrowserRouter>
                            <NavbarComponent
                                // isLoggedin={isLoggedin}
                                // username={username}
                                // jwttoken={jwttoken}
                                onLogoutSuccess={this.onLogoutSuccess}
                            />

                            {links}
                        </BrowserRouter>

                    </div>


                    {/* <UserSignupPage /> */}
                    {/* <UserLoginPage />
           */}
                </div>
            </div>
        )
    }
}

const mapStateToProps = (store) => {
    return {
        isLoggedIn: store.isLoggedIn,
        username: store.username,
        jwttoken: store.jwttoken
    };
};

export default connect(mapStateToProps)(App);



