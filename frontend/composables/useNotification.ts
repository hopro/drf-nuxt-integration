import { ref } from 'vue'

interface Notification {
  message: string
  type: 'success' | 'error' | 'info' | 'warning'
  timeout?: number
}

const notification = ref<Notification | null>(null)
const timeout = ref<NodeJS.Timeout | null>(null)

export const useNotification = () => {
  const showNotification = (options: Notification) => {
    // Очищаем предыдущий таймер, если он есть
    if (timeout.value) {
      clearTimeout(timeout.value)
    }

    notification.value = {
      message: options.message,
      type: options.type,
      timeout: options.timeout || 5000
    }

    // Устанавливаем таймер для скрытия уведомления
    timeout.value = setTimeout(() => {
      notification.value = null
    }, notification.value.timeout)
  }

  const hideNotification = () => {
    notification.value = null
    if (timeout.value) {
      clearTimeout(timeout.value)
    }
  }

  return {
    notification,
    showNotification,
    hideNotification
  }
}