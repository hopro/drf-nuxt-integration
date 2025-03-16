<template>
  <div>
    <v-card class="mb-4">
      <v-card-title class="text-h5">Пациенты</v-card-title>
      <v-card-text>
        <p>Управление данными пациентов</p>
      </v-card-text>
      <v-card-actions>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="navigateTo('/patients/create')"
        >
          Добавить пациента
        </v-btn>
      </v-card-actions>
    </v-card>

    <DataTable
      title="Список пациентов"
      :headers="headers"
      :items="patients"
      :loading="loading"
      :total-items="totalItems"
      :filters="filters"
      @page-change="handlePageChange"
      @filter-change="handleFilterChange"
      @edit="editPatient"
      @delete="confirmDelete"
    >
      <template v-slot:item.category="{ item }">
        <v-chip :color="getCategoryColor(item.category)" text-color="white" size="small">
          {{ item.category }}
        </v-chip>
      </template>

      <template v-slot:item.date_of_birth="{ item }">
        {{ formatDate(item.date_of_birth) }}
      </template>
    </DataTable>

    <!-- Диалог подтверждения удаления -->
    <v-dialog v-model="deleteDialog" max-width="500px">
      <v-card>
        <v-card-title class="text-h5">Подтверждение</v-card-title>
        <v-card-text>
          Вы действительно хотите удалить пациента {{ selectedPatient?.surname }}
          {{ selectedPatient?.name }}? Это действие нельзя отменить.
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="grey" variant="text" @click="deleteDialog = false">Отмена</v-btn>
          <v-btn
            color="error"
            variant="text"
            @click="deletePatient"
            :loading="deleteLoading"
            >Удалить</v-btn
          >
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import DataTable from "~/components/DataTable.vue";

definePageMeta({
  middleware: ["auth"],
});

const api = useApi();
const router = useRouter();

// Состояние данных
const patients = ref([]);
const loading = ref(false);
const totalItems = ref<any>(0);
const currentPage = ref<any>(1);
const itemsPerPage = ref<any>(10);
const sortDataBy = ref();
const searchItems = ref([]);
// const filters = ref({});

// Состояние удаления
const deleteDialog = ref(false);
const selectedPatient = ref<any>(null);
const deleteLoading = ref(false);

// Заголовки таблицы
const headers = [
  { title: "ID", key: "id", sortable: true },
  { title: "Фамилия", key: "surname", sortable: true },
  { title: "Имя", key: "name", sortable: true },
  { title: "Отчество", key: "patronymic", sortable: true },
  { title: "Дата рождения", key: "date_of_birth", sortable: true },
  { title: "Возраст", key: "age", sortable: true },
  { title: "Категория", key: "category", sortable: true },
  { title: "Участок", key: "uchastok_name", sortable: true },
  { title: "Действия", key: "actions", sortable: false },
];

// Фильтры
// const filters_ = ref([
//   { key: "name", label: "Имя", type: "text", default: "" },
//   { key: "surname", label: "Фамилия", type: "text", default: "" },
//   {
//     key: "category",
//     label: "Категория",
//     type: "select",
//     options: [
//       { title: "Все", value: "" },
//       { title: "Пенсионер", value: "Пенсионер" },
//       { title: "Ребенок", value: "Ребенок" },
//       { title: "Взрослый", value: "Взрослый" },
//     ],
//     default: "",
//   },
//   { key: "uchastok", label: "Участок", type: "text", default: "" },
// ]);

// Поля фильтров
const filters = [
  {
    key: "surname",
    label: "Фамилия",
    type: "text",
    cols: 12,
    sm: 6,
    md: 4,
  },
  {
    key: "name",
    label: "Имя",
    type: "text",
    cols: 12,
    sm: 6,
    md: 4,
  },
  { key: "patronymic", label: "Отчество", type: "text", cols: 12, sm: 6, md: 4 },
  {
    key: "date_of_birth",
    label: "Дата рождения",
    type: "date",
    cols: 12,
    sm: 6,
    md: 4,
  },
  { key: "date_of_death", label: "Дата смерти", type: "date", cols: 12, sm: 6, md: 4 },
  { key: "phone", label: "Телефон", type: "phone", cols: 12, sm: 6, md: 4 },
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
  },
];

// Загрузка данных
onMounted(() => {
  fetchPatients();
});

async function fetchPatients() {
  loading.value = true;
  try {
    const queryParams = new URLSearchParams();
    queryParams.append("page", currentPage.value);
    queryParams.append("page_size", itemsPerPage.value);
    queryParams.append("ordering", sortDataBy.value);

    // Добавление фильтров в запрос
    for (const [key, value] of Object.entries(searchItems.value)) {
      if (value) {
        queryParams.append(key, value);
      }
    }

    const response = await api.getWithString(
      `gp4_analitika/patients/?${queryParams.toString()}`
    );
    patients.value = response.results;
    totalItems.value = response.count;
  } catch (error) {
    console.error("Ошибка при загрузке пациентов:", error);
  } finally {
    loading.value = false;
  }
}

// Обработчики событий
function handlePageChange({ page, page_size, ordering }: any) {
  currentPage.value = page;
  itemsPerPage.value = page_size;
  sortDataBy.value = ordering;
  fetchPatients();
}

function handleFilterChange(newFilters: any) {
  console.log("handleFilterChange", newFilters);

  searchItems.value = newFilters;
  currentPage.value = 1;
  fetchPatients();
}

function editPatient(item: any) {
  router.push(`/patients/${item.id}`);
}

function confirmDelete(item: any) {
  selectedPatient.value = item;
  deleteDialog.value = true;
}

async function deletePatient() {
  if (!selectedPatient.value) return;

  deleteLoading.value = true;
  try {
    await api.deleteWithString(`gp4_analitika/patients/${selectedPatient.value.id}/`);
    deleteDialog.value = false;
    deleteDialog.value = false;
    fetchPatients();
  } catch (error) {
    console.error("Ошибка при удалении пациента:", error);
  } finally {
    deleteLoading.value = false;
  }
}

// Вспомогательные функции
function getCategoryColor(category: any) {
  switch (category) {
    case "Пенсионер":
      return "blue";
    case "Ребенок":
      return "green";
    case "Взрослый":
      return "purple";
    default:
      return "grey";
  }
}

function formatDate(dateString: any) {
  if (!dateString) return "";
  const date = new Date(dateString);
  return new Intl.DateTimeFormat("ru-RU").format(date);
}
</script>
