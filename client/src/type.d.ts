interface IUser {
  id: number;
  display_name: string;
  avatar_url: string;
}

type AuthContextType = {
  refreshing: Promise<any> | null;
  login: (data: any) => Promise<any>;
  logout: () => Promise<any>;
  user: IUser | null;
  token: string | null;
  loading: boolean;
  isAuthenticated: boolean;
  error: any;
};
