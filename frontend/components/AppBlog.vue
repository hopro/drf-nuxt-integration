<template>
  <div>
      <v-card-title>
      Новости
      <v-spacer></v-spacer>
    </v-card-title>
    <v-card v-for="post in posts" :key="post.id" class="mb-4">
      <v-card-title>{{ post.title }}</v-card-title>
      <v-card-text>
        <div class="d-flex align-center mb-2">
          <v-avatar size="40" class="mr-2">
            <img :src="post.author.avatar" alt="Avatar" />
          </v-avatar>
          <span>{{ post.author.username }}</span>
        </div>
        <div>{{ post.content }}</div>
      </v-card-text>
      <v-card-actions>
        <v-btn color="primary" @click="viewPost(post.id)">Читать далее</v-btn>
      </v-card-actions>
    </v-card>
    <v-pagination
      v-model="currentPage"
      :length="totalPages"
      :total-visible="5"
      @update:modelValue="fetchPosts"
    ></v-pagination>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'

const posts = ref([])
const api = useApi()
const currentPage = ref(1)
const totalPages = ref(1)

const fetchPosts = async () => {
  try {
    const queryParams = new URLSearchParams();
    queryParams.append("page", currentPage.value);

    const response = await api.getWithString(`blog/posts/?${queryParams.toString()}`)
    posts.value = response.results
    totalPages.value = Math.ceil(response.count / 10)
  } catch (error) {
    console.error('Ошибка при загрузке постов:', error)
  }
}

const viewPost = (id) => {
  // Логика для просмотра поста
  console.log('Просмотр поста с ID:', id)
}

onMounted(fetchPosts)
</script>