import React, { FC } from "react";
import { RouteComponentProps } from "react-router-dom";
import { gql, useQuery } from "@apollo/client";
import useAuth from "./../hooks/useAuth";

const GET_USERS = gql`
  query GetUsers {
    users {
      id
      display_name
      avatar_url
      account {
        email
      }
    }
  }
`;

export const Home: FC<RouteComponentProps> = () => {
  const { user, logout } = useAuth();
  const { loading, error, data } = useQuery(GET_USERS);

  if (loading) return <div>Loading...</div>;
  if (error) return <div style={{ color: "red" }}>Error! {error.message}</div>;

  return (
    <div>
      <h1>Home</h1>
      <h3>Welcome {user?.display_name}</h3>
      <br />
      <b>List of users</b>
      <ul>
        {data.users.map((u: IUser) => (
          <li key={u.id}>
            <div>ID: {u.id}</div>
            <div>Name: {u.display_name}</div>
          </li>
        ))}
      </ul>

      <button onClick={logout}>Logout</button>
    </div>
  );
};

export default Home;
