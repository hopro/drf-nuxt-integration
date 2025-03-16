import { defineStore } from "pinia";
import type { components } from "~/types/api";

// Используем типы, сгенерированные из OpenAPI
type User = components["schemas"]["UserProfile"];
type Token = components["schemas"]["TokenRefresh"];

interface AuthState {
  user: User | null;
  tokenAccess: string | null;
  tokenRefresh: string | null;
  isAuthenticated: boolean;
}

export const useAuthStore = defineStore("auth", {
  state: (): AuthState => ({
    user: null,
    tokenAccess: null,
    tokenRefresh: null,
    isAuthenticated: false,
  }),

  actions: {
    async login(token: Token) {
      try {
        // Настройки куков для работы в среде разработки
        const accessTokenCookie = useCookie('accessTokenCookie', { 
          secure: process.env.NODE_ENV === 'production', 
          httpOnly: false, 
          path: '/',
          maxAge: 60 * 60 * 24 * 7 // 7 дней
        });
        const refreshTokenCookie = useCookie('refreshTokenCookie', { 
          secure: process.env.NODE_ENV === 'production', 
          httpOnly: false, 
          path: '/',
          maxAge: 60 * 60 * 24 * 30 // 30 дней
        });

        accessTokenCookie.value = token.access;
        refreshTokenCookie.value = token.refresh;

        this.tokenAccess = token.access;
        this.tokenRefresh = token.refresh;
        this.isAuthenticated = true;

        try {
          await this.fetchUser();
          return true;
        } catch (error) {
          // Всё равно возвращаем true, так как логин прошёл успешно
          // Данные пользователя могут быть получены позже
          return true;
        }
      } catch (error) {
        console.error("Ошибка входа:", error);
        return false;
      }
    },

    async fetchUser() {
      const api = useApi();
      try {
        const user: any = await api.getWithString("accounts/users/me/");
        this.user = user;
        this.isAuthenticated = true;
        return user;
      } catch (error) {
        // Не вызываем this.logout() здесь, так как logout должен 
        // вызываться только если обновление токена не удалось
        throw error;
      }
    },

    logout() {
      this.user = null;
      this.tokenAccess = null;
      this.tokenRefresh = null;
      this.isAuthenticated = false;

      const accessTokenCookie = useCookie('accessTokenCookie', { path: '/' });
      const refreshTokenCookie = useCookie('refreshTokenCookie', { path: '/' });
      accessTokenCookie.value = null;
      refreshTokenCookie.value = null;
      navigateTo('/login');
    },

    async initialize() {
      if (process.client) {
        const accessTokenCookie = useCookie('accessTokenCookie', { path: '/' });
        const refreshTokenCookie = useCookie('refreshTokenCookie', { path: '/' });

        if (accessTokenCookie.value && refreshTokenCookie.value) {
          this.tokenAccess = accessTokenCookie.value;
          this.tokenRefresh = refreshTokenCookie.value;

          try {
            await this.fetchUser();
          } catch (error) {
            try {
              await this.refreshToken();
              await this.fetchUser();
            } catch (refreshError) {
              console.error("Ошибка обновления токена:", refreshError);
              this.logout();
            }
          }
        }
      }
    },

    async refreshToken() {
      const api = useApi();
      try {
        const token = await api.refreshToken();
        
        // Обновляем куки при обновлении токена
        const accessTokenCookie = useCookie('accessTokenCookie', { 
          secure: process.env.NODE_ENV === 'production', 
          httpOnly: false, 
          path: '/',
          maxAge: 60 * 60 * 24 * 7 // 7 дней
        });
        const refreshTokenCookie = useCookie('refreshTokenCookie', { 
          secure: process.env.NODE_ENV === 'production', 
          httpOnly: false, 
          path: '/',
          maxAge: 60 * 60 * 24 * 30 // 30 дней
        });
        
        accessTokenCookie.value = token.access;
        refreshTokenCookie.value = token.refresh;
        
        this.tokenAccess = token.access;
        this.tokenRefresh = token.refresh;
        return token;
      } catch (error) {
        console.error("Ошибка обновления токена:", error);
        this.logout();
        throw error;
      }
    },
  },
});
