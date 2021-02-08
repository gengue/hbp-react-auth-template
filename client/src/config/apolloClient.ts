import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";
import { setContext } from "@apollo/client/link/context";
import jwtManager from "./../utils/JwtManager";

const httpLink = createHttpLink({
  uri: "http://localhost:8080/v1/graphql",
});

const authLink = setContext(async (_, { headers }) => {
  const token = jwtManager.getToken();
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    },
  };
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache(),
});

export default client;
