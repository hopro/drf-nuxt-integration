<template>
  <div>
    <v-card class="mb-6">
      <v-card-title class="text-h4">Добро пожаловать в Vuetify Nuxt + Django интеграцию</v-card-title>
      <v-card-text>
        <p>Это демонстрация интеграции Vuetify Nuxt фронтенда с Django REST Framework бэкендом с использованием OpenAPI для генерации типов.</p>
      </v-card-text>
    </v-card>
    
    <div v-if="authStore.isAuthenticated">
      <v-card>
        <v-card-title class="text-h5">Добро пожаловать, {{ authStore.user?.username }}</v-card-title>
        <v-card-actions>
          <v-btn color="primary" to="/dashboard" prepend-icon="mdi-view-dashboard">
            Перейти в панель управления
          </v-btn>
          <v-btn color="secondary" to="/patients" prepend-icon="mdi-account-group" class="ml-2">
            Управление пациентами
          </v-btn>
        </v-card-actions>
      </v-card>
    </div>
    <div v-else>
      <v-card>
        <v-card-title class="text-h5">Начало работы</v-card-title>
        <v-card-actions>
          <v-btn color="primary" to="/login" prepend-icon="mdi-login">
            Войти
          </v-btn>
          <v-btn color="secondary" to="/register" prepend-icon="mdi-account-plus" class="ml-2">
            Зарегистрироваться
          </v-btn>
        </v-card-actions>
      </v-card>
    </div>
        <!-- Добавляем компонент Blog -->
        <div class="mt-6"><AppBlog /></div>
      
  </div>
</template>

<script setup>
const authStore = useAuthStore()
</script>