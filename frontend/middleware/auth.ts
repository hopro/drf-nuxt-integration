export default defineNuxtRouteMiddleware(async (to, from) => {
  // Если страница логина или регистрации, пропускаем проверку
  if (to.path === '/login' || to.path === '/register' || to.path === '/reset-password') {
    return;
  }

  const authStore = useAuthStore()
  const accessTokenCookie = useCookie('accessTokenCookie')
  const refreshTokenCookie = useCookie('refreshTokenCookie')

  // Проверяем аутентификацию
  // Если пользователь не аутентифицирован, пытаемся инициализировать
  if (!authStore.isAuthenticated) {
    try {
      // Не вызываем повторно initialize здесь, так как это уже сделано в app.vue
      // Просто проверяем результат
      
      // Если пользователь все еще не аутентифицирован,
      // перенаправляем на страницу входа
      if (!authStore.isAuthenticated) {
        // Указываем параметр редиректа для возврата после авторизации
        const redirectPath = to.fullPath !== '/login' ? to.fullPath : undefined;
        const loginPath = redirectPath ? `/login?redirect=${encodeURIComponent(redirectPath)}` : '/login';
        return navigateTo(loginPath);
      }
    } catch (error) {
      // В случае ошибки перенаправляем на страницу входа
      const redirectPath = to.fullPath !== '/login' ? to.fullPath : undefined;
      const loginPath = redirectPath ? `/login?redirect=${encodeURIComponent(redirectPath)}` : '/login';
      return navigateTo(loginPath);
    }
  }
  
  // Если у нас есть пользователь и он аутентифицирован, продолжаем
  return;
})