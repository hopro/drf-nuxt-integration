/**
 * Композабл для упрощенной работы с авторизацией
 */
export const useAuth = () => {
  const authStore = useAuthStore();
  const route = useRoute();

  /**
   * Проверяет, авторизован ли пользователь
   */
  const isAuthenticated = computed(() => authStore.isAuthenticated);

  /**
   * Текущий пользователь
   */
  const user = computed(() => authStore.user);

  /**
   * Перенаправление после логина
   */
  const redirectPath = computed(() => {
    return route.query.redirect ? String(route.query.redirect) : '/';
  });

  /**
   * Вход в систему
   */
  const login = async (username: string, password: string) => {
    const api = useApi();
    try {
      const token = await api.postWithString('accounts/token/', { username, password });
      const result = await authStore.login(token);
      return result;
    } catch (error) {
      return false;
    }
  };

  /**
   * Выход из системы
   */
  const logout = () => {
    authStore.logout();
  };

  /**
   * Получение данных пользователя
   */
  const fetchUser = async () => {
    return authStore.fetchUser();
  };

  /**
   * Проверка, имеет ли пользователь определенное разрешение
   */
  const hasPermission = (permission: string) => {
    if (!authStore.user) {
      return false;
    }
    
    // Проверяем наличие permissions в объекте пользователя
    // тип User может не содержать это поле, поэтому используем any
    const userAny = authStore.user as any;
    return userAny.permissions && userAny.permissions.includes(permission);
  };

  return {
    isAuthenticated,
    user,
    redirectPath,
    login,
    logout,
    fetchUser,
    hasPermission
  };
}; 