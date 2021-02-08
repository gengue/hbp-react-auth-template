import React, { FC, ReactNode } from "react";
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import { ApolloProvider } from "@apollo/client";

import PrivateRoute from "./components/PrivateRoute";
import { AuthProvider } from "./hooks/useAuth";
import apolloClient from "./config/apolloClient";
import Home from "./views/Home";
import Login from "./views/Login";

export const App: FC<ReactNode> = () => {
  return (
    <ApolloProvider client={apolloClient}>
      <Router>
        <AuthProvider>
          <Switch>
            <PrivateRoute path="/" exact component={Home} />
            <Route path="/login" exact component={Login} />
          </Switch>
        </AuthProvider>
      </Router>
    </ApolloProvider>
  );
};
