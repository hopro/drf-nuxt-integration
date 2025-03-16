<template>
  <div class="max-w-md mx-auto mt-8">
    <DataForm
      title="Регистрация"
      :fields="fields"
      :initial-data="formData"
      :loading="loading"
      :error="error"
      :field-errors="fieldErrors"
      :submit-button-text="loading ? 'Регистрация...' : 'Зарегистрироваться'"
      :show-cancel="false"
      :show-reset="false"
      @submit="handleRegister"
    >
      <template #additional-fields>
        <div class="text-center mt-4">
          <v-btn variant="text" color="primary" to="/login" class="text-none">
            Уже есть аккаунт? Войти
          </v-btn>
        </div>
      </template>
    </DataForm>
  </div>
</template>

<script setup>
import * as yup from "yup";

const router = useRouter();
const api = useApi();
const { showNotification } = useNotification();

const loading = ref(false);
const error = ref("");
const fieldErrors = ref({});

const { handleApiErrors, resetErrors } = useApiErrors({ error, fieldErrors });

const formData = ref({
  username: "",
  email: "",
  password: "",
  password_confirm: "",
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
    validation: yup
      .string()
      .required("Имя пользователя обязательно")
      .min(3, "Минимум 3 символа")
      .max(150, "Максимум 150 символов"),
  },
  {
    key: "email",
    label: "Email",
    type: "text",
    required: true,
    cols: 12,
    sm: 12,
    md: 12,
    prepend: "mdi-email",
    validation: yup
      .string()
      .required("Email обязателен")
      .email("Введите корректный email"),
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
    validation: yup
      .string()
      .required("Пароль обязателен")
      .min(8, "Минимум 8 символов")
      .matches(/[a-z]/, "Должен содержать строчные буквы")
      .matches(/[A-Z]/, "Должен содержать заглавные буквы")
      .matches(/[0-9]/, "Должен содержать цифры"),
  },
  {
    key: "password_confirm",
    label: "Подтверждение пароля",
    type: "password",
    required: true,
    cols: 12,
    sm: 12,
    md: 12,
    prepend: "mdi-lock-check",
    validation: yup
      .string()
      .required("Подтверждение пароля обязательно")
      .oneOf([yup.ref("password")], "Пароли должны совпадать"),
  },
];

const handleRegister = async (data) => {
  loading.value = true;
  resetErrors();

  try {
    await api.postWithString("accounts/register/", data);
    showNotification({
      message: "Регистрация успешно завершена! Теперь вы можете войти в систему.",
      type: "success",
    });
    router.push("/login");
  } catch (err) {
    if (err.response?.data) {
      handleApiErrors(err.response.data);
    } else {
      error.value = "Произошла ошибка при регистрации. Попробуйте позже.";
    }
  } finally {
    loading.value = false;
  }
};

// Перенаправление, если пользователь уже вошел в систему
onMounted(() => {
  const authStore = useAuthStore();
  if (authStore.isAuthenticated) {
    router.push("/dashboard");
  }
});
</script>
