class JwtManager {
  token: string | null = null;
  user: IUser | null = null;
  refreshing: Promise<any> | null = null;

  setToken = (token: string | null) => {
    this.token = token;
  };
  setUser = (user: IUser | null) => {
    this.user = user;
  };
  setRefreshing = (refreshing: Promise<any> | null) => {
    this.refreshing = refreshing;
  };
  getToken = () => this.token;
  getUser = () => this.user;
  getRefreshing = () => this.refreshing;
}

const jwtManager = new JwtManager();
export default jwtManager;
