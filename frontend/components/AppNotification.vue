<template>
  <v-snackbar
    v-model="show"
    :color="notification?.type"
    :timeout="notification?.timeout"
    location="right top"
  >
    {{ notification?.message }}

    <template v-slot:actions>
      <v-btn variant="text" @click="hideNotification"> Закрыть </v-btn>
    </template>
  </v-snackbar>
</template>

<script setup>
const { notification, hideNotification } = useNotification();

const show = computed({
  get: () => !!notification.value,
  set: (value) => {
    if (!value) hideNotification();
  },
});
</script>
