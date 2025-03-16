<template>
  <v-card>
    <v-card-title>
      {{ title }}
      <v-spacer></v-spacer>
      <slot name="title-actions"></slot>
    </v-card-title>

    <v-card-text>
      <Form
        ref="form"
        :validation-schema="schema"
        :initial-values="formValues"
        @submit="onSubmit"
        v-slot="{ errors: formErrors, meta }"
      >
        <v-alert v-if="error || nonFieldErrors.length" type="error" class="mb-4">
          {{ error || nonFieldErrors.join(". ") }}
        </v-alert>

        <v-row>
          <template v-for="(field, index) in fields" :key="index">
            <v-col :cols="field.cols || 12" :sm="field.sm || 6" :md="field.md || 4">
              <Field :name="field.key" v-slot="{ field: veeField, errors, errorMessage }">
                <!-- Текстовое поле -->
                <v-text-field
                  v-if="field.type === 'text'"
                  v-bind="veeField"
                  :label="field.label"
                  :hint="field.hint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  variant="outlined"
                  density="comfortable"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                ></v-text-field>

                <!-- Числовое поле -->
                <v-text-field
                  v-else-if="field.type === 'number'"
                  v-bind="veeField"
                  type="number"
                  :label="field.label"
                  :hint="field.hint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  variant="outlined"
                  density="comfortable"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                ></v-text-field>

                <!-- Телефонное поле с маской -->
                <PhoneInput
                  v-if="field.type === 'phone'"
                  v-bind="veeField"
                  :label="field.label"
                  variant="outlined"
                  density="comfortable"
                  :model-value="formValues[field.key]"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :prepend-icon="field.prepend"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  @update:model-value="updateField(field.key, $event)"
                />

                <!-- Автокомплит для связанных полей -->
                <ForeignKeyAutocomplete
                  v-else-if="field.type === 'autocomplete'"
                  v-bind="veeField.value"
                  :label="field.label"
                  :hint="field.hint"
                  :item-title="field.itemTitle"
                  :item-value="field.itemValue"
                  :model-value="formValues[field.key]"
                  :related-model="field.endpoint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  @update:model-value="updateField(field.key, $event)"
                >
                </ForeignKeyAutocomplete>

                <!-- Поле для пароля -->
                <v-text-field
                  v-else-if="field.type === 'password'"
                  v-bind="veeField"
                  :label="field.label"
                  :hint="field.hint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                  :type="showPassword ? 'text' : 'password'"
                  variant="outlined"
                  density="comfortable"
                  @click:append="showPassword = !showPassword"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                ></v-text-field>

                <!-- Выпадающий список -->
                <v-select
                  v-else-if="field.type === 'select'"
                  v-bind="veeField"
                  :label="field.label"
                  :items="field.items"
                  :hint="field.hint"
                  item-title="display_name"
                  item-value="value"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  variant="outlined"
                  density="comfortable"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                ></v-select>

                <!-- Чекбокс -->
                <v-checkbox
                  v-else-if="field.type === 'checkbox'"
                  v-bind="veeField"
                  :label="field.label"
                  :hint="field.hint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  hide-details="auto"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                ></v-checkbox>

                <!-- Дата -->
                <v-text-field
                  v-else-if="field.type === 'date'"
                  v-bind="veeField"
                  type="date"
                  :label="field.label"
                  :hint="field.hint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  variant="outlined"
                  density="comfortable"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                ></v-text-field>

                <!-- Текстовая область -->
                <v-textarea
                  v-else-if="field.type === 'textarea'"
                  v-bind="veeField"
                  :label="field.label"
                  :hint="field.hint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :prepend-icon="field.prepend"
                  variant="outlined"
                  density="comfortable"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                  auto-grow
                ></v-textarea>

                <!-- Радио кнопки -->
                <v-radio-group
                  v-else-if="field.type === 'radio'"
                  v-bind="veeField"
                  :label="field.label"
                  :hint="field.hint"
                  :error-messages="errorMessage || fieldErrors[field.key]"
                  :required="field.required"
                  :readonly="field.readonly || readonly"
                  :model-value="formValues[field.key]"
                  @update:model-value="updateField(field.key, $event)"
                >
                  <v-radio
                    v-for="option in field.options"
                    :key="option.value"
                    :label="option.label"
                    :value="option.value"
                  ></v-radio>
                </v-radio-group>

                <!-- Слот для кастомных полей -->
                <slot
                  v-else-if="field.type === 'custom'"
                  :name="`field-${field.key}`"
                  :field="field"
                  :model-value="veeField.value"
                  :error-message="errorMessage || formErrors[field.key]"
                  @update:model-value="veeField.handleChange"
                ></slot>
              </Field>
            </v-col>
          </template>
        </v-row>

        <slot name="additional-fields"></slot>

        <v-card-actions class="pt-4">
          <v-spacer></v-spacer>
          <slot name="actions">
            <v-btn
              v-if="showCancel"
              variant="outlined"
              color="grey"
              @click="$emit('cancel')"
              :disabled="loading"
            >
              Отмена
            </v-btn>
            <v-btn
              v-if="showReset"
              variant="outlined"
              color="warning"
              class="ml-2"
              @click="resetForm"
              :disabled="loading"
            >
              Сбросить
            </v-btn>
            <v-btn
              type="submit"
              v-if="!readonly"
              color="primary"
              class="ml-2"
              :loading="loading"
            >
              {{ submitButtonText }}
            </v-btn>
          </slot>
        </v-card-actions>
      </Form>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { Form, Field } from "vee-validate";
import * as yup from "yup";

const api = useApi();

const props = defineProps({
  title: {
    type: String,
    default: "Форма",
  },
  fields: {
    type: Array,
    required: true,
  },
  initialData: {
    type: Object,
    default: () => ({}),
  },
  loading: {
    type: Boolean,
    default: false,
  },
  error: {
    type: String,
    default: "",
  },
  fieldErrors: {
    type: Object,
    default: () => ({}),
  },
  readonly: {
    type: Boolean,
    default: false,
  },
  showCancel: {
    type: Boolean,
    default: true,
  },
  showReset: {
    type: Boolean,
    default: true,
  },
  submitButtonText: {
    type: String,
    default: "Сохранить",
  },
});

const emit = defineEmits(["submit", "cancel", "update:model-value"]);

const form = ref(null);
const showPassword = ref(false);
const nonFieldErrors = ref([]);

// Создаем схему валидации на основе полей
const schema = computed(() => {
  const schemaObject = {};

  props.fields.forEach((field) => {
    let fieldSchema = yup.mixed();

    if (field.required) {
      // fieldSchema = fieldSchema.required(field.label + " обязательно");
      fieldSchema = yup.string().required(field.label + " обязательно");
    }

    if (field.type === "email") {
      fieldSchema = yup.string().email("Неверный формат email");
    }

    if (field.type === "number") {
      fieldSchema = yup.number().typeError("Должно быть числом");
    }

    if (field.type === "phone") {
      fieldSchema = yup
        .string()
        .matches(
          /^\+7\s?\(\d{3}\)\s?\d{3}[-\s]?\d{2}[-\s]?\d{2}$/,
          "Введите корректный номер телефона"
        );
    }

    if (field.validation) {
      fieldSchema = field.validation;
    }

    schemaObject[field.key] = fieldSchema;
  });

  return yup.object().shape(schemaObject);
});

// Обработка отправки формы
const onSubmit = () => {
  emit("submit", formValues.value);
};

// Сброс формы
function resetForm() {
  if (form.value) {
    form.value.resetForm();
  }
  nonFieldErrors.value = [];
}

// Обработка ошибок API
watch(
  () => props.fieldErrors,
  (newErrors) => {
    if (newErrors) {
      // Обработка non_field_errors
      if (newErrors.non_field_errors) {
        nonFieldErrors.value = Array.isArray(newErrors.non_field_errors)
          ? newErrors.non_field_errors
          : [newErrors.non_field_errors];
      } else {
        nonFieldErrors.value = [];
      }
    }
  },
  { deep: true }
);

const formValues = ref({ ...props.initialData });

watch(
  () => props.initialData,
  (newData) => {
    if (form.value) {
      form.value.resetForm({ values: newData });
      formValues.value = { ...newData };
    }
  },
  { deep: true, immediate: true }
);

const updateField = (key, value) => {
  formValues.value[key] = value;
};
</script>
