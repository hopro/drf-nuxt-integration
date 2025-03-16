<template>
  <div>
    <v-row>
      <v-col cols="12" md="4">
        <v-card>
          <v-card-text class="text-center">
            <v-avatar size="150" class="mb-4">
              <v-img
                v-if="formData.avatar"
                :src="formData.avatar"
                alt="User Avatar"
              ></v-img>
              <v-icon v-else size="150" color="grey-lighten-1">mdi-account-circle</v-icon>
            </v-avatar>
            <v-file-input
              v-model="avatarFile"
              accept="image/*"
              label="Изменить аватар"
              prepend-icon="mdi-camera"
              variant="outlined"
              density="comfortable"
              hide-details
              class="mb-4"
              @update:model-value="handleAvatarChange"
            ></v-file-input>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="8">
        <DataForm
          title="Профиль пользователя"
          :fields="fields"
          :initial-data="formData"
          :loading="loading"
          :error="error"
          :field-errors="fieldErrors"
          :submit-button-text="loading ? 'Сохранение...' : 'Сохранить'"
          @submit="handleSubmit"
        />
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import * as yup from "yup";

definePageMeta({
  middleware: ["auth"],
});

const api = useApi();
const { showNotification } = useNotification();

const loading = ref(false);
const error = ref("");
const fieldErrors = ref({});
const avatarFile = ref(null);

const { handleApiErrors, resetErrors } = useApiErrors({ error, fieldErrors });

const formData = ref({
  username: "",
  email: "",
  bith_date: "",
  mobile_phone: "",
  avatar: null,
  address: "",
  comment: "",
});

const fields = [
  {
    key: "username",
    label: "Имя пользователя",
    type: "text",
    required: true,
    readonly: true,
    cols: 12,
    sm: 6,
    md: 6,
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
    sm: 6,
    md: 6,
    prepend: "mdi-email",
    validation: yup
      .string()
      .required("Email обязателен")
      .matches(
        /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
        "Введите корректный email"
      ),
  },
  {
    key: "bith_date",
    label: "Дата рождения",
    type: "date",
    cols: 12,
    sm: 6,
    md: 6,
    prepend: "mdi-calendar",
  },
  {
    key: "mobile_phone",
    label: "Мобильный телефон",
    type: "phone",
    prepend: "mdi-phone",
    cols: 12,
    sm: 6,
    md: 6,
    validation: yup
      .string()
      .required("Телефон обязателен")
      .matches(
        /^\+7\s?\(\d{3}\)\s?\d{3}[-\s]?\d{2}[-\s]?\d{2}$/,
        "Введите корректный номер телефона"
      ),
  },
  {
    key: "address",
    label: "Адрес",
    type: "text",
    cols: 12,
    sm: 12,
    md: 12,
    prepend: "mdi-map-marker",
  },
  {
    key: "comment",
    label: "Комментарий",
    type: "textarea",
    cols: 12,
    sm: 12,
    md: 12,
    prepend: "mdi-comment",
  },
];

// Загрузка данных профиля
const fetchProfile = async () => {
  loading.value = true;
  try {
    const data = await api.getWithString("accounts/users/me/");
    formData.value = data;
  } catch (err) {
    error.value = "Ошибка при загрузке профиля";
  } finally {
    loading.value = false;
  }
};

// Обработка изменения аватара
const handleAvatarChange = async (file) => {
  if (!file) return;

  const formDataToSend = new FormData();
  for (const key in formData.value) {
    if (formData.value[key] !== null && formData.value[key] !== undefined) {
      if (key === "avatar" && typeof formData.value.avatar === "string") {
        continue; // Пропускаем, если avatar — строка (URL)
      }
      formDataToSend.append(key, formData.value[key]);
    }
  }

  formDataToSend.append("avatar", file);

  try {
    const response = await api.putFormData("accounts/users/me/", formDataToSend);
    formData.value.avatar = response.avatar;
    showNotification({
      message: "Аватар успешно обновлен",
      type: "success",
    });
  } catch (err) {
    showNotification({
      message: "Ошибка при загрузке аватара",
      type: "error",
    });
  }
};
 
// Обработка отправки формы
const handleSubmit = async (data) => {
  loading.value = true;
  resetErrors();
  const formDataToSend = new FormData();

  for (const key in data) {
    if (data[key] === null || data[key] === undefined) continue;
    if (key === "avatar" && typeof data.avatar === "string") continue;
    formDataToSend.append(key, data[key]);
  }

  try {
    await api.putFormData("accounts/users/me/", formDataToSend);
    showNotification({
      message: "Профиль успешно обновлен",
      type: "success",
    });
  } catch (err) {
    showNotification({
      message: "Произошла ошибка при обновлении профиля",
      type: "error",
    });
    if (err.response?.data) {
      handleApiErrors(err.response.data);
    } else {
      error.value = "Произошла ошибка при обновлении профиля";
    }
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchProfile();
});
</script>
