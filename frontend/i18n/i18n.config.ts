export default defineI18nConfig(() => ({
    legacy: false,
    locale: 'en',
    messages: {
      en: {
        welcome: 'Welcome'
      },
      ru: {
        welcome: 'Добро пожаловать',
        $vuetify: {
          loading: 'Загрузка',
          noDataText: 'Нет данных',
          confirmEdit: {
            cancel: 'Отмена',
            ok: 'Ок',

          },
          dataFooter: {
            itemsPerPageText: 'Элементов на странице:',
            pageText: '{0}-{1} из {2}', //6-10 of 10
            itemsPerPageAll: 'Все',
            firstPage: 'Первая страница',
            prevPage: 'Предыдущая страница',
            nextPage: 'Следующая страница',
            lastPage: 'Последняя страница',
            loadingText: 'Загрузка...',
          },
          datePicker: {
            header: 'Выберите дату',
            title: 'Выберите дату',
            itemsSelected: '{0} выбрано',
          },
          dataIterator: {
            loadingText: 'Загрузка',
          },
          input: {
            clear: 'Очистить',
            prependAction: 'Добавить',
            appendAction: 'Принять',
          },
          open: 'Открыть',
          close: 'Закрыть',
          pagination: {
            ariaLabel: {
              root: 'Навигация по страницам',
              previous: 'Предыдущая страница',
              next: 'Следующая страница',
              first: 'Первая страница',
              last: 'Последняя страница',
              currentPage: 'Текущая страница',
              itemsPerPage: 'Элементов на странице:',
              page: 'Страница {0}',
            },
          },
        },
      }
    }
  }))
  