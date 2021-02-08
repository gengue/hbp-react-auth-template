import React from "react";
import { Route, Redirect, RouteProps } from "react-router-dom";
import { useAuth } from "./../hooks/useAuth";

function PrivateRoute(props: RouteProps) {
  const { isAuthenticated, loading } = useAuth();
  const { component: Component, ...rest } = props;

  if (loading) {
    return <div>Loading</div>;
  }

  if (isAuthenticated && Component) {
    return <Route {...rest} render={(props) => <Component {...props} />} />;
  } else {
    return <Redirect to="/login" />;
  }
}

export default PrivateRoute;
