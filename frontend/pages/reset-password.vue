<template>
  <div>
    <v-card max-width="500" class="mx-auto">
      <v-card-title class="text-h5">Восстановление пароля</v-card-title>
      
      <v-card-text>
        <v-alert v-if="error" type="error" class="mb-4">
          {{ error }}
        </v-alert>
        
        <v-alert v-if="success" type="success" class="mb-4">
          {{ success }}
        </v-alert>
        
        <v-form @submit.prevent="handleResetPassword">
          <v-text-field
            v-model="email"
            label="Email"
            type="email"
            required
            prepend-icon="mdi-email"
            variant="outlined"
          ></v-text-field>
          
          <v-btn
            type="submit"
            color="primary"
            block
            :loading="loading"
            class="mt-4"
          >
            {{ loading ? 'Отправка...' : 'Восстановить пароль' }}
          </v-btn>
          
          <div class="text-center mt-4">
            <v-btn
              variant="text"
              color="primary"
              to="/login"
              class="text-none"
            >
              Вернуться к входу
            </v-btn>
          </div>
        </v-form>
      </v-card-text>
    </v-card>
  </div>
</template>

<script setup>
const router = useRouter()
const api = useApi()

const email = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')

const handleResetPassword = async () => {
  loading.value = true
  error.value = ''
  success.value = ''
  
  try {
    await api.postWithString('password-reset/', {
      email: email.value
    })
    
    success.value = 'Инструкции по восстановлению пароля отправлены на ваш email'
    email.value = ''
  } catch (e) {
    error.value = 'Ошибка при отправке запроса на восстановление пароля'
  } finally {
    loading.value = false
  }
}

// Перенаправление, если пользователь уже вошел в систему
onMounted(() => {
  const authStore = useAuthStore()
  if (authStore.isAuthenticated) {
    router.push('/dashboard')
  }
})
</script>