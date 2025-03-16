<template>
  <div>
    <v-btn
      class="mb-4"
      prepend-icon="mdi-arrow-left"
      variant="text"
      @click="router.back()"
    >
      Назад к списку
    </v-btn>

    <DataForm
      :title="
        isNewPatient
          ? 'Добавление пациента'
          : `Пациент: ${patient.surname} ${patient.name}`
      "
      :fields="fields"
      :initial-data="patient"
      :loading="loading"
      :error="error"
      :field-errors="fieldErrors"
      :readonly="viewMode"
      :submit-button-text="isNewPatient ? 'Создать' : 'Сохранить'"
      @submit="savePatient"
      @cancel="router.back()"
    >
      <template #title-actions>
        <v-btn
          v-if="!isNewPatient && viewMode"
          color="primary"
          variant="text"
          prepend-icon="mdi-pencil"
          @click="viewMode = false"
        >
          Редактировать
        </v-btn>
        <v-btn
          v-if="!isNewPatient && !viewMode"
          color="grey"
          variant="text"
          prepend-icon="mdi-eye"
          @click="viewMode = true"
        >
          Просмотр
        </v-btn>
      </template>
    </DataForm>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import DataForm from "~/components/DataForm.vue";
import * as yup from "yup";

const route = useRoute();
const router = useRouter();
const api = useApi();
const fieldErrors = ref({});

// Состояние
const patient = ref({
  uchastok_name: "",
  uchastok_code: "",
  name: "",
  surname: "",
  patronymic: "",
  date_of_birth: null,
  date_of_death: null,
  age: 0,
  address: "",
  phone: "",
  snils: "",
  MO_prikrepl: "",
  lgota: "",
  category: "",
  ychastok: null,
});
const loading = ref(false);
const error = ref("");
const viewMode = ref(true);
const uchastki = ref([]);

const { handleApiErrors, resetErrors } = useApiErrors({ error, fieldErrors });
const { showNotification } = useNotification();

// Вычисляемые свойства
const isNewPatient = computed(() => route.params.id === "create");

// Поля формы
const fields = [
  {
    key: "surname",
    label: "Фамилия",
    type: "text",
    cols: 12,
    required: true,
    sm: 6,
    md: 4,
  },
  {
    key: "name",
    label: "Имя",
    type: "text",
    cols: 12,
    required: true,
    sm: 6,
    md: 4,
  },
  { key: "patronymic", label: "Отчество", type: "text", cols: 12, sm: 6, md: 4 },
  {
    key: "date_of_birth",
    label: "Дата рождения",
    type: "date",
    cols: 12,
    required: true,
    sm: 6,
    md: 4,
  },
  {
    key: "date_of_death",
    label: "Дата смерти",
    type: "date",
    cols: 12,
    sm: 6,
    md: 4,
    validation: yup.string().nullable().notRequired(),
  },
  { key: "age", label: "Возраст", type: "number", cols: 12, sm: 6, md: 4 },
  { key: "address", label: "Адрес", type: "text", cols: 12, sm: 12, md: 8 },
  {
    key: "phone",
    label: "Телефон",
    type: "phone",
    cols: 12,
    sm: 6,
    md: 4,
    validation: yup.string().nullable().notRequired(),
  },
  { key: "snils", label: "СНИЛС", type: "text", cols: 12, sm: 6, md: 4 },
  { key: "MO_prikrepl", label: "МО прикрепления", type: "text", cols: 12, sm: 6, md: 4 },
  { key: "lgota", label: "Льгота", type: "text", cols: 12, sm: 6, md: 4 },
  {
    key: "category",
    label: "Категория",
    type: "select",
    cols: 12,
    sm: 6,
    md: 4,
    items: [
      {
        value: "Пенсионер",
        display_name: "Пенсионер",
      },
      {
        value: "Работающий",
        display_name: "Работающий",
      },
      {
        value: "Студент",
        display_name: "Студент",
      },
      {
        value: "Школьник",
        display_name: "Школьник",
      },
      {
        value: "Инвалид",
        display_name: "Инвалид",
      },
      {
        value: "Все записи",
        display_name: "",
      },
    ],
  },
  {
    key: "ychastok",
    label: "Участок",
    type: "autocomplete",
    cols: 12,
    sm: 6,
    md: 4,
    endpoint: "gp4_analitika/uchastki/",
    itemTitle: "name",
    itemValue: "id",
    validation: yup.string().nullable().notRequired(),
  },
  {
    key: "uchastok_name",
    label: "Название участка",
    type: "text",
    cols: 12,
    sm: 6,
    md: 4,
  },
  { key: "uchastok_code", label: "Код участка", type: "text", cols: 12, sm: 6, md: 4 },
];

// Загрузка данных
onMounted(async () => {
  if (!isNewPatient.value) {
    await fetchPatient();
  } else {
    viewMode.value = false;
  }

  await fetchUchastki();
});

async function fetchPatient() {
  loading.value = true;
  resetErrors();
  try {
    const data = await api.getWithString(`gp4_analitika/patients/${route.params.id}/`);
    patient.value = data;
  } catch (err) {
    error.value = "Ошибка при загрузке данных пациента";
    console.error(err);
  } finally {
    loading.value = false;
  }
}

async function fetchUchastki() {
  try {
    const data = await api.getWithString("gp4_analitika/uchastki/");
    uchastki.value = data.results || [];
  } catch (err) {
    console.error("Ошибка при загрузке участков:", err);
  }
}

async function savePatient(formData: any) {
  loading.value = true;
  error.value = "";
  resetErrors();

  try {
    if (isNewPatient.value) {
      await api.postWithString("gp4_analitika/patients/", formData);
      showNotification({
        message: "Пациент добавлен!",
        type: "success",
      });
      router.push("/patients");
    } else {
      await api.putWithString(`gp4_analitika/patients/${route.params.id}/`, formData);
      viewMode.value = true;
      showNotification({
        message: "Данные по пациенту обновлены!",
        type: "success",
      });
      await fetchPatient(); // Перезагрузка данных
    }
  } catch (err: any) {
    if (err.response?.data) {
      handleApiErrors(err.response.data);
    } else {
      error.value = "Произошла ошибка. Попробуйте позже.";
    }
    showNotification({
      message: "Ошибка сохранения данных",
      type: "error",
    });
  } finally {
    loading.value = false;
  }
}
</script>
