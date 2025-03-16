<template>
  <div>
    <v-card class="mb-4">
      <v-card-title class="d-flex align-center">
        {{ title }}
        <v-spacer></v-spacer>
        <v-text-field
          v-model="search"
          append-icon="mdi-magnify"
          label="Поиск"
          single-line
          hide-details
          density="compact"
          class="ml-2"
          style="max-width: 300px"
        ></v-text-field>
      </v-card-title>

      <v-card-text>
        <v-row v-if="showFilters" class="mb-3">
          <v-col cols="12">
            <v-expansion-panels variant="accordion">
              <v-expansion-panel>
                <v-expansion-panel-title>
                  <div class="d-flex align-center">
                    <v-icon class="mr-2">mdi-filter</v-icon>
                    Фильтры
                  </div>
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                  <DataForm
                    :fields="filters"
                    submit-button-text="Поиск"
                    @submit="applyFilters"
                    @cancel="showFilters = false"
                  >
                  </DataForm>
                </v-expansion-panel-text>
              </v-expansion-panel>
            </v-expansion-panels>
          </v-col>
        </v-row>

        <v-data-table-server
          v-model:items-per-page="itemsPerPage"
          v-model:page="currentPage"
          v-model:sort-by="sortDataBy"
          :headers="headers"
          :items="items"
          :items-length="totalItems"
          :loading="loading"
          hover
          class="elevation-1"
        >
          <template v-slot:loading>
            <v-skeleton-loader
              type="table-row"
              class="my-2"
              v-for="n in 5"
              :key="n"
            ></v-skeleton-loader>
          </template>

          <template v-for="slot in Object.keys($slots)" v-slot:[slot]="slotProps">
            <slot :name="slot" v-bind="slotProps"></slot>
          </template>

          <template v-slot:item.actions="{ item }">
            <slot name="item-actions" :item="item">
              <v-icon size="small" class="mr-2" @click="$emit('edit', item)">
                mdi-pencil
              </v-icon>
              <v-icon size="small" @click="$emit('delete', item)"> mdi-delete </v-icon>
            </slot>
          </template>
        </v-data-table-server>
      </v-card-text>
    </v-card>
  </div>
</template>

<script setup>
import DataForm from "~/components/DataForm.vue";
const props = defineProps({
  title: {
    type: String,
    default: "Данные",
  },
  headers: {
    type: Array,
    required: true,
  },
  items: {
    type: Array,
    default: () => [],
  },
  loading: {
    type: Boolean,
    default: false,
  },
  totalItems: {
    type: Number,
    default: 0,
  },
  filters: {
    type: Array,
    default: () => [],
  },
  showFilters: {
    type: Boolean,
    default: true,
  },
  apiEndpoint: {
    type: String,
    default: "",
  },
});

const emit = defineEmits([
  "page-change",
  "filter-change",
  "edit",
  "delete",
  "update:options",
]);

const search = ref("");
const currentPage = ref(1);
const itemsPerPage = ref(10);
const activeFilters = ref({});
const sortDataBy = ref([]);

// Инициализация фильтров
onMounted(() => {
  resetFilters();
});

function resetFilters() {
  const newFilters = {};
  props.filters.forEach((filter) => {
    newFilters[filter.key] = filter.default || null;
  });
  activeFilters.value = newFilters;
}

function applyFilters(formData) {
  activeFilters.value = formData;
  emit("filter-change", activeFilters.value);
  currentPage.value = 1;
}

function handlePageChange() {
  emit("page-change", {
    page: currentPage.value,
    page_size: itemsPerPage.value,
    ordering: sortDataBy.value
      .map((item) => (item.order === "desc" ? `-${item.key}` : item.key))
      .join(","),
  });
}

watch([itemsPerPage, currentPage, sortDataBy], () => {
  handlePageChange();
});
</script>
