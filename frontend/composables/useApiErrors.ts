interface ApiErrorHandlerOptions {
  error: Ref<string>
  fieldErrors: Ref<Record<string, string[]>>
}

export const useApiErrors = ({ error, fieldErrors }: ApiErrorHandlerOptions) => {
  const handleApiErrors = (responseData: any) => {
    // Очищаем предыдущие ошибки
    error.value = ''
    fieldErrors.value = {}

    if (!responseData) {
      error.value = 'Произошла неизвестная ошибка'
      return
    }

    // Обработка ошибок полей
    Object.entries(responseData).forEach(([field, messages]) => {
      if (field === 'non_field_errors' || field === 'detail') {
        error.value = Array.isArray(messages) ? messages.join('. ') : messages as string
        
      } else {
        fieldErrors.value[field] = Array.isArray(messages) ? messages : [messages as string]
      }
    })
  }

  const resetErrors = () => {
    error.value = ''
    fieldErrors.value = {}
  }

  return {
    handleApiErrors,
    resetErrors
  }
}