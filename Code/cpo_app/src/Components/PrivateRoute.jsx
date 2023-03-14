import React, {useContext} from 'react';
import { Navigate } from 'react-router-dom';
import AuthContext from "../Contexts/AuthContext.jsx";

/**
    This code exports a functional React component "PrivateRoute" that 
    makes use of the "useContext" hook to access the "AuthContext" 
    context in the application. The component takes in a single prop 
    "children" that represents the contents of the route.
    The component checks the "auth.success" property in the 
    context to determine whether the user is authenticated or 
    not. If the user is authenticated, it returns the "children" 
    prop, otherwise, it returns a "Navigate" component that redirects 
    the user to the "/login" route
 */
const PrivateRoute = ({ children }) => {
    const { auth } = useContext(AuthContext);
    return (
        auth.success ? children : <Navigate to="/login"/>
    );
};

export default PrivateRoute;
