<template>
  <div class="max-w-md mx-auto mt-8">
    <DataForm
      title="Вход"
      :fields="fields"
      :initial-data="formData"
      :loading="loading"
      :error="error"
      :field-errors="fieldErrors"
      :submit-button-text="loading ? 'Вход...' : 'Вход'"
      :show-cancel="false"
      :show-reset="false"
      @submit="handleLogin"
    >
      <template #additional-fields>
        <div class="text-center mt-4">
          <v-btn variant="text" color="primary" to="/register" class="text-none">
            Нет аккаунта? Зарегистрироваться
          </v-btn>
        </div>
        <div class="text-center mt-4">
          <v-btn variant="text" color="primary" to="/reset-password" class="text-none">
            Забыли пароль? Восстановить
          </v-btn>
        </div>
      </template>
    </DataForm>
  </div>
</template>

<script setup>
import * as yup from "yup";

const router = useRouter();
const { showNotification } = useNotification();
const auth = useAuth();

const loading = ref(false);
const error = ref("");
const fieldErrors = ref({});

const { handleApiErrors, resetErrors } = useApiErrors({ error, fieldErrors });

const formData = ref({
  username: "",
  password: "",
});

// Определение полей формы с расширенной валидацией
const fields = [
  {
    key: "username",
    label: "Имя пользователя",
    type: "text",
    required: true,
    cols: 12,
    sm: 12,
    md: 12,
    prepend: "mdi-account",
    validation: yup.string().required("Имя пользователя обязательно"),
  },
  {
    key: "password",
    label: "Пароль",
    type: "password",
    required: true,
    cols: 12,
    sm: 12,
    md: 12,
    prepend: "mdi-lock",
    validation: yup.string().required("Пароль обязателен"),
  },
];

const handleLogin = async (data) => {
  loading.value = true;
  resetErrors();

  try {
    const success = await auth.login(data.username, data.password);
    
    if (success) {
      showNotification({
        message: "Авторизация успешна.",
        type: "success",
      });
      
      // Перенаправление на страницу редиректа (если она есть) или на главную
      router.push(auth.redirectPath.value);
    } else {
      error.value = "Не удалось войти в систему. Пожалуйста, проверьте введенные данные.";
    }
  } catch (err) {
    if (err.response?.data) {
      handleApiErrors(err.response.data);
    } else {
      error.value = "Произошла ошибка при входе. Попробуйте позже.";
    }
    handleApiErrors(err.response?.data || {});
  } finally {
    loading.value = false;
  }
};

// Перенаправление, если пользователь уже вошел в систему
onMounted(() => {
  if (auth.isAuthenticated.value) {
    router.push(auth.redirectPath.value);
  }
});
</script>
