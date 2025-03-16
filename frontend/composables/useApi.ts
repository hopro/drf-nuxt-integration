import type { paths } from "~/types/api";

export const useApi = () => {
  const config = useRuntimeConfig();

  const csrfToken = ref<string | null>(null);

  const accessTokenCookie = useCookie('accessTokenCookie', { 
    path: '/',
    secure: process.env.NODE_ENV === 'production', 
    httpOnly: false
  });
  const refreshTokenCookie = useCookie('refreshTokenCookie', { 
    path: '/',
    secure: process.env.NODE_ENV === 'production', 
    httpOnly: false
  });

  const getCsrfToken = async () => {
    if (!csrfToken.value) {
      const res = await fetch(`${config.public.apiBase}/csrf/`, {
        credentials: "include",
      });
      const data = await res.json();
      if (!res.ok) {
        const error = new Error('API Error');
        throw error;
      }
      csrfToken.value = data.csrfToken;
    }
    return csrfToken.value;
  };

  const fetchData = async <T>(endpoint: string, options: any = {}, retryCount = 0) => {

    const authStore = useAuthStore()
    try {
    // Определяем заголовки в зависимости от типа данных
    const headers: Record<string, string> = {
      ...options.headers,
    };

      // Важно! Не устанавливаем Content-Type для FormData
      // Браузер автоматически установит правильный заголовок с boundary
      if (!(options.body instanceof FormData)) {
        headers["Content-Type"] = "application/json";
      }

      // Используем токен из куки или из стора - смотрим оба места
      const accessToken = accessTokenCookie.value || authStore.tokenAccess;
      if (accessToken) {
        headers["Authorization"] = `Bearer ${accessToken}`;
      }

      // Добавляем CSRF-токен, если метод изменяет данные
      if (["POST", "PUT", "DELETE"].includes(options.method)) {
        const csrfToken = await getCsrfToken();
        if (csrfToken) {
          headers["X-CSRFToken"] = csrfToken;
        }
      }

      // Убедимся что endpoint правильно сформирован
      const url = endpoint.startsWith('http') 
        ? endpoint 
        : `${config.public.apiBase}/${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}`;

      const response = await fetch(url, {
        ...options,
        headers,
        credentials: "include",
      });

      // Если получили 401, пробуем обновить токен и повторить запрос
      if (response.status === 401 && retryCount < 1) {
        const refreshToken = refreshTokenCookie.value || authStore.tokenRefresh;
        
        if (!refreshToken) {
          throw new Error('Failed to refresh token: No refresh token available');
        }
        
        try {
          // Пробуем обновить токен
          const tokenResponse = await fetch(`${config.public.apiBase}/accounts/token/refresh/`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ refresh: refreshToken }),
          });
          
          if (!tokenResponse.ok) {
            throw new Error('Failed to refresh token: Invalid response');
          }
          
          const tokenData = await tokenResponse.json();
          
          // Обновляем токены в cookies и store
          accessTokenCookie.value = tokenData.access;
          authStore.tokenAccess = tokenData.access;
          
          // Повторяем исходный запрос с новым токеном
          return fetchData(endpoint, options, retryCount + 1);
        } catch (refreshError) {
          authStore.logout();
          throw new Error('Failed to refresh token');
        }
      }

      const text = await response.text();
      
      if (!response.ok) {
        let errorData;
        try {
          errorData = JSON.parse(text); // Пробуем разобрать JSON
        } catch {
          errorData = { detail: text }; // Если не JSON, то просто передаем текст ошибки
        }
        throw { response: { data: errorData } }; // Бросаем объект, похожий на Axios-ответ
      }
      try {
        return text ? JSON.parse(text) : null;
      } catch {        
        return text; // Возвращаем текст, если он не является допустимым JSON
      }
    } catch (error: Error | any) {
      console.error("API request failed:", error, endpoint, options);
      throw error;
    }
  };

  return {
    // Type-safe API methods using OpenAPI generated types
    get: <
      P extends keyof paths,
      M extends "get" extends keyof paths[P] ? "get" : never
    >(
      path: P
    ) => fetchData(path.toString(), {}),

    post: <
      P extends keyof paths,
      M extends "post" extends keyof paths[P] ? "post" : never,
      B extends paths[P][M] extends {
        requestBody: { content: { "application/json": infer D } };
      }
        ? D
        : never
    >(
      path: P,
      data: B
    ) =>
      fetchData(path.toString(), {
        method: "POST",
        body: JSON.stringify(data),
      }),
    put: <
      P extends keyof paths,
      M extends "put" extends keyof paths[P] ? "put" : never,
      B extends paths[P][M] extends {
        requestBody: { content: { "application/json": any } };
      }
        ? paths[P][M]["requestBody"]["content"]["application/json"]
        : never
    >(
      path: P,
      data: B
    ) =>
      fetchData(path.toString(), {
        method: "PUT",
        body: JSON.stringify(data),
      }),

    delete: <
      P extends keyof paths &
        keyof {
          [K in keyof paths as "delete" extends keyof paths[K]
            ? K
            : never]: any;
        }
    >(
      path: P
    ) =>
      fetchData(path.toString(), {
        method: "DELETE",
      }),

    refreshToken: async () => {
      const refreshToken = refreshTokenCookie.value;
      if (!refreshToken) {
        throw new Error('No refresh token available');
      }
      
      const result = await fetchData('accounts/token/refresh/', {
        method: 'POST',
        body: JSON.stringify({ refresh: refreshToken }),
      });
      
      return result;
    },
    // Fallback methods for when you need to use strings (less type-safe)
    getWithString: <T>(endpoint: string) => fetchData<T>(endpoint, {}),
    postWithString: <T, B>(endpoint: string, data: B) =>
      fetchData<T>(endpoint, {
        method: "POST",
        body: JSON.stringify(data),
      }),
    putWithString: <T, B>(endpoint: string, data: B) =>
      fetchData<T>(endpoint, {
        method: "PUT",
        body: JSON.stringify(data),
      }),
    putFormData: <T>(endpoint: string, formData: FormData) =>
      fetchData<T>(endpoint, {
        method: "PUT",
        body: formData, // Отправляем FormData напрямую
      }),
    deleteWithString: <T>(endpoint: string) =>
      fetchData<T>(endpoint, {
        method: "DELETE",
      }),
  };
};
