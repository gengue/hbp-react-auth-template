import * as React from "react";
import { render, RenderOptions } from "@testing-library/react";
import { ApolloProvider } from "@apollo/client";
import { AuthProvider } from "./hooks/useAuth";
import apolloClient from "./config/apolloClient";

const AllProviders = ({ children }: { children?: React.ReactNode }) => (
  <ApolloProvider client={apolloClient}>
    <AuthProvider>{children}</AuthProvider>
  </ApolloProvider>
);

const customRender = (ui: React.ReactElement, options?: RenderOptions) =>
  render(ui, { wrapper: AllProviders, ...options });

export { customRender as render };
