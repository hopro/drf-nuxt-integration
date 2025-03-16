<template>
  <v-text-field
    ref="input"
    v-model="inputValue"
    :label="label"
    :error-messages="errorMessage"
    :prepend-icon="prependIcon"
    variant="outlined"
    density="comfortable"
  />
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount, computed } from "vue";
import IMask from "imask";

const props = defineProps({
  modelValue: String,
  label: String,
  errorMessage: String,
  prependIcon: String,
});

const emit = defineEmits(["update:modelValue"]);
const input = ref(null);
let maskInstance = null;

const inputValue = computed({
  get: () => props.modelValue || "",
  set: (value) => {
    if (maskInstance) {
      maskInstance.value = formatPhone(value);
      maskInstance.updateValue();
    }
    emit("update:modelValue", formatPhone(value));
  },
});

const maskOptions = {
  mask: "+{7} (000) 000-00-00",
  lazy: false,
  placeholderChar: "_",
};

onMounted(() => {
  if (input.value) {
    const element = input.value.$el.querySelector("input");
    maskInstance = IMask(element, maskOptions);
    maskInstance.value = formatPhone(props.modelValue);
    maskInstance.updateValue();

    maskInstance.on("accept", () => {
      emit("update:modelValue", maskInstance.value);
    });
  }
});

watch(
  () => props.modelValue,
  (newValue) => {
    if (maskInstance && newValue !== maskInstance.value) {
      maskInstance.value = formatPhone(newValue);
      maskInstance.updateValue();
    }
  }
);

onBeforeUnmount(() => {
  if (maskInstance) {
    maskInstance.destroy();
  }
});

function formatPhone(value) {
  if (!value) return "";
  return value.startsWith("8") ? "+7" + value.slice(1) : value;
}
</script>
