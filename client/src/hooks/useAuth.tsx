import React, {
  createContext,
  useCallback,
  useEffect,
  useState,
  useContext,
  FC,
  ReactNode,
} from "react";
import { useHistory } from "react-router-dom";
import axios from "axios";
import jwtManager from "./../utils/JwtManager";

let intvId: NodeJS.Timeout;

function useAuthProvider() {
  const history = useHistory();
  const [user, setUser] = useState<IUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [refreshing, setRefreshing] = useState<Promise<any> | null>(null);
  const [delay, setDelay] = useState<number | null>(null);
  const [error, setError] = useState(null);

  const isAuthenticated = token !== null;

  const login = useCallback(
    async (data: any) => {
      const { email, password } = data;
      setLoading(true);
      console.log("Login...");
      return axios
        .post(
          "http://localhost:3000/auth/login",
          {
            email,
            password,
          },
          { withCredentials: true }
        )
        .then(({ data }) => {
          setToken(data?.jwt_token);
          setUser(data?.user);
          setDelay(data?.jwt_expires_in);
          history.push("/");
        })
        .catch((err) => {
          setError(err?.response?.data);
        })
        .finally(() => {
          setLoading(false);
        });
    },
    [history]
  );

  const logout = useCallback(async () => {
    console.log("Logout...");
    setLoading(true);
    return axios
      .post("http://localhost:3000/auth/logout", {}, { withCredentials: true })
      .then(() => {
        setToken(null);
        setUser(null);
        setDelay(null);
        window.localStorage.setItem("logout", Date.now().toString());
        if (history.location.pathname !== "/login") {
          history.push("/login");
        }
      })
      .catch((err) => {
        setError(err?.response?.data);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [history]);

  const refreshToken = useCallback(async () => {
    console.log("refreshing token");
    const promise = axios
      .get("http://localhost:3000/auth/token/refresh", {
        withCredentials: true,
      })
      .then(({ data }) => {
        setToken(data?.jwt_token);
        setUser(data?.user);
        setDelay(data?.jwt_expires_in);
        if (history.location.pathname === "/login") {
          history.push("/");
        }
        return true;
      })
      .catch((err) => {
        if (err.response.status === 401) {
          logout();
        }
        return false;
      })
      .finally(() => {
        setRefreshing(null);
      });
    setRefreshing(promise);
    await promise;
  }, [logout, history]);

  useEffect(() => {
    if (!token) {
      refreshToken();
    }
  }, [token, refreshToken]);

  const syncLogout = useCallback(
    (event) => {
      if (event.key === "logout") {
        console.log("logged out from storage!");
        history.push("/login");
      }
    },
    [history]
  );

  useEffect(() => {
    if (token && delay && !intvId) {
      console.log("start refresh countdown");
      const DELTA = delay - 60_000; // 1 minute before expiry
      intvId = setInterval(async () => {
        console.log("refresh countdown activated");
        refreshToken();
      }, DELTA);
    }
    return () => clearInterval(intvId);
  }, [token, delay, refreshToken]);

  useEffect(() => {
    window.addEventListener("storage", syncLogout);
    return () => {
      window.removeEventListener("storage", syncLogout);
    };
  }, [syncLogout]);

  // keep sync with jwt manager for 3rd party access
  useEffect(() => {
    jwtManager.setToken(token);
    jwtManager.setUser(user);
    jwtManager.setRefreshing(refreshing);
  }, [token, user, refreshing]);

  return {
    refreshing,
    isAuthenticated,
    login,
    logout,
    user,
    token,
    loading,
    error,
  };
}

export const AuthContext = createContext<AuthContextType>({
  refreshing: null,
  isAuthenticated: false,
  login: async () => {},
  logout: async () => {},
  user: null,
  token: null,
  loading: false,
  error: null,
});

export const AuthProvider: FC<ReactNode> = ({ children }: any) => {
  const auth = useAuthProvider();
  return <AuthContext.Provider value={auth}>{children}</AuthContext.Provider>;
};

export const useAuth = () => useContext(AuthContext);
export default useAuth;
