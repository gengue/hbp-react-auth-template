import React, { FC } from "react";
import { RouteComponentProps } from "react-router-dom";
import useForm from "./../hooks/useForm";
import useAuth from "./../hooks/useAuth";

export const Login: FC<RouteComponentProps> = () => {
  const { values, handleChange } = useForm({
    initialValues: {
      email: "",
      password: "",
    },
  });

  const { login, error } = useAuth();

  const handleLogin = async (e: React.FormEvent<HTMLElement>) => {
    e.preventDefault();
    await login(values);
  };

  return (
    <div>
      <h1>Login</h1>
      <div>
        {error && <span style={{ color: "red" }}>{error?.data?.message}</span>}
      </div>

      <form onSubmit={handleLogin}>
        <input
          type="email"
          placeholder="Email"
          name="email"
          value={values.email}
          onChange={handleChange}
        />
        <input
          type="password"
          placeholder="Password"
          name="password"
          value={values.password}
          onChange={handleChange}
        />
        <button type="submit">Login</button>
      </form>
    </div>
  );
};

export default Login;
