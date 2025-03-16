<template>
  <div>
    <v-app-bar color="primary" dark app>
      <v-app-bar-title>
        <NuxtLink to="/" class="text-white text-decoration-none">mysite</NuxtLink>
      </v-app-bar-title>

      <v-spacer></v-spacer>

      <!-- Кнопки меню для больших экранов -->
      <div class="d-none d-md-flex">
        <v-btn to="/" variant="text">Главная</v-btn>
        <template v-if="authStore.isAuthenticated">
          <v-btn to="/dashboard" variant="text">Панель управления</v-btn>
          <v-btn to="/patients" variant="text">Пациенты</v-btn>
        </template>
      </div>

      <template v-if="authStore.isAuthenticated">
        <v-menu>
          <template v-slot:activator="{ props }">
            <v-btn v-bind="props" class="ml-2">
              <v-avatar size="32" class="mr-2">
                <v-img
                  v-if="authStore.user?.avatar"
                  :src="authStore.user.avatar"
                  alt="User Avatar"
                ></v-img>
                <v-icon v-else>mdi-account-circle</v-icon>
              </v-avatar>
              {{ authStore.user?.username }}
              <v-icon right>mdi-menu-down</v-icon>
            </v-btn>
          </template>

          <v-list>
            <v-list-item to="/profile">
              <template v-slot:prepend>
                <v-icon>mdi-account-cog</v-icon>
              </template>
              <v-list-item-title>Профиль</v-list-item-title>
            </v-list-item>

            <v-divider></v-divider>

            <v-list-item @click="logout">
              <template v-slot:prepend>
                <v-icon>mdi-logout</v-icon>
              </template>
              <v-list-item-title>Выйти</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </template>
      <template v-else>
        <v-btn to="/login" variant="text">Войти</v-btn>
        <v-btn to="/register" variant="text">Регистрация</v-btn>
      </template>

      <!-- Бургер-меню для мобильных устройств -->
      <v-app-bar-nav-icon
        class="d-md-none"
        @click.stop="drawer = !drawer"
      ></v-app-bar-nav-icon>
    </v-app-bar>

    <!-- Выдвижное меню -->
    <v-navigation-drawer v-model="drawer" temporary>
      <v-list>
        <v-list-item to="/" title="Главная" prepend-icon="mdi-home"></v-list-item>
        <template v-if="authStore.isAuthenticated">
          <v-list-item
            to="/dashboard"
            title="Панель управления"
            prepend-icon="mdi-view-dashboard"
          ></v-list-item>
          <v-list-item
            to="/patients"
            title="Пациенты"
            prepend-icon="mdi-account-group"
          ></v-list-item>
        </template>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <v-container>
        <slot />
      </v-container>
    </v-main>

    <v-footer app class="bg-primary text-center d-flex justify-center" dark>
      <div>Vuetify Nuxt + Django интеграция с OpenAPI &copy; {{ new Date().getFullYear() }}</div>
    </v-footer>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useAuthStore } from "@/stores/auth";
import { useRouter } from "vue-router";

const authStore = useAuthStore();
const router = useRouter();
const drawer = ref(false);

const logout = () => {
  authStore.logout();
  router.push("/");
};
</script>
