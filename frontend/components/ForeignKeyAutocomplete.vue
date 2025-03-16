<template>
  <v-autocomplete
    v-model="selectedValue"
    :items="foreignKeyItems"
    :item-title="itemTitle"
    :item-value="itemValue"
    variant="outlined"
    density="comfortable"
    clear-on-select
    :loading="loading"
    :search-input.sync="search"
    @update:search="onSearch"
    @update:menu="onMenuOpen"
  >
    <template v-slot:append-item>
      <v-divider />
      <v-list-item :disabled="!hasMoreData" @click="loadMore" class="text-center">
        Загрузить еще...
      </v-list-item>
    </template>
  </v-autocomplete>
</template>

<script setup lang="ts">
const props = defineProps<{
  modelValue: any;
  relatedModel: string;
  itemTitle: string;
  itemValue: string;
}>();

const emit = defineEmits(["update:modelValue", "search", "blur", "input", "change"]);

const api = useApi();
const selectedValue = ref(props.modelValue);
const foreignKeyItems = ref<any>([]);
const loading = ref(false);
const page = ref(1);
const hasMoreData = ref(true);
const isLoaded = ref(false);
const filterParams = ref("");
const search = ref("");
const relatedModelValue = ref(props.relatedModel);

async function fetchForeignKeyItems() {
  loading.value = true;
  const response = await api.getWithString(
    relatedModelValue.value + `?page=${page.value}&name=${filterParams.value}`
  );
  if (response.next) {
    hasMoreData.value = true;
  } else {
    hasMoreData.value = false;
  }
  foreignKeyItems.value = [...response.results];
  loading.value = false;
}

const onSearch = async (query: string) => {
  emit("search", query);
  filterParams.value = query;
  page.value = 1;
  await fetchForeignKeyItems();
};

const onMenuOpen = async (isOpen: boolean) => {
  if (isOpen && !isLoaded.value) {
    await fetchForeignKeyItems();
    isLoaded.value = true;
    hasMoreData.value = true;
  }
};

const loadMore = async () => {
  if (!hasMoreData.value) return;
  page.value++;
  await fetchForeignKeyItems();
};

watch(selectedValue, (newValue) => {
  emit("update:modelValue", newValue);
});

watch(
  () => props.modelValue,
  (newVal) => {
    selectedValue.value = newVal;
  }
);

onMounted(async () => {
  await fetchForeignKeyItems();
});
</script>
