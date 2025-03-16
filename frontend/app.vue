<template>
  <v-app>
    <ClientOnly>
      <template #fallback>
        <div class="d-flex justify-center align-center" style="height: 100vh;">
          <v-progress-circular indeterminate color="primary" size="64" :active="true"></v-progress-circular>
        </div>
      </template>
      
      <NuxtLayout v-if="authInitialized">
        <NuxtPage />
        <AppNotification />
      </NuxtLayout>
      
      <div v-else class="d-flex justify-center align-center loader-container" style="height: 100vh;">
        <v-progress-circular indeterminate color="primary" size="64" :active="isClient"></v-progress-circular>
      </div>
    </ClientOnly>
  </v-app>
</template>

<script setup>
const authStore = useAuthStore();
const authInitialized = ref(false);
const isClient = ref(false);

// Установка флага клиентского рендеринга для активации анимаций
onMounted(() => {
  isClient.value = true;
  initializeAuth();
});

// Инициализация аутентификации перед рендерингом компонентов
async function initializeAuth() {
  try {
    await authStore.initialize();
  } catch (error) {
    console.error('Ошибка инициализации аутентификации:', error);
  } finally {
    authInitialized.value = true;
  }
}
</script>

<style>
/* Гарантирует анимацию на клиентской стороне */
.loader-container .v-progress-circular__overlay {
  animation: v-progress-circular-rotate 1.4s linear infinite;
  transform-origin: center center;
  transition: all 0.2s ease-in-out;
}

@keyframes v-progress-circular-rotate {
  100% {
    transform: rotate(360deg);
  }
}
</style>
