<template>
  <div>
    <v-card>
      <v-card-title class="text-h4">Панель управления</v-card-title>

      <v-card-text>
        <v-row>
          <!-- HTTP Requests Stats -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>HTTP Запросы</v-card-title>
              <v-card-text style="height: 300px">
                <Bar
                  v-if="httpRequestsData.datasets[0].data.some((v) => v > 0)"
                  :data="httpRequestsData"
                  :options="chartOptions"
                />
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Request Latency -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>Время обработки запросов</v-card-title>
              <v-card-text style="height: 300px">
                <Line
                  v-if="latencyData.datasets[0].data.length > 0"
                  :data="latencyData"
                  :options="chartOptions"
                />
              </v-card-text>
            </v-card>
          </v-col>

          <!-- GC Stats -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>Сборка мусора (GC)</v-card-title>
              <v-card-text style="height: 300px">
                <Doughnut
                  v-if="gcData.datasets[0].data.some((v) => v > 0)"
                  :data="gcData"
                  :options="chartOptions"
                />
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Request Methods -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>Методы запросов по представлениям</v-card-title>
              <v-card-text style="height: 300px">
                <Pie
                  v-if="requestMethodsData.datasets[0].data.some((v) => v > 0)"
                  :data="requestMethodsData"
                  :options="chartOptions"
                />
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <!-- Metrics Table -->
        <v-card class="mt-4">
          <v-card-title>Детальные метрики</v-card-title>
          <v-card-text>
            <v-table>
              <thead>
                <tr>
                  <th>Метрика</th>
                  <th>Значение</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Всего запросов</td>
                  <td>{{ metrics.totalRequests }}</td>
                </tr>
                <tr>
                  <td>Среднее время ответа</td>
                  <td>{{ metrics.avgLatency.toFixed(3) }} сек</td>
                </tr>
                <tr>
                  <td>Успешные запросы</td>
                  <td>{{ metrics.successfulRequests }}</td>
                </tr>
                <tr>
                  <td>Объекты собранные GC</td>
                  <td>{{ metrics.gcObjectsCollected }}</td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-card-text>
    </v-card>
  </div>
</template>

<script setup>
import { Bar, Line, Doughnut, Pie } from "vue-chartjs";
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  LineElement,
  PointElement,
  ArcElement,
} from "chart.js";

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  LineElement,
  PointElement,
  ArcElement
);

definePageMeta({
  middleware: ["auth"],
});

const api = useApi();
const metrics = ref({
  totalRequests: 0,
  avgLatency: 0,
  successfulRequests: 0,
  gcObjectsCollected: 0,
});

// Chart Options
const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: "top",
    },
  },
};

// HTTP Requests Data
const httpRequestsData = ref({
  labels: ["До middleware", "После middleware", "Ответы"],
  datasets: [
    {
      label: "Количество запросов",
      data: [0, 0, 0],
      backgroundColor: [
        "rgba(255, 99, 132, 0.5)",
        "rgba(54, 162, 235, 0.5)",
        "rgba(75, 192, 192, 0.5)",
      ],
    },
  ],
});

// Latency Data
const latencyData = ref({
  labels: ["0.01", "0.025", "0.05", "0.075", "0.1", "0.25", "0.5", "0.75", "1.0"],
  datasets: [
    {
      label: "Время обработки (сек)",
      data: [],
      borderColor: "rgb(75, 192, 192)",
      tension: 0.1,
    },
  ],
});

// GC Data
const gcData = ref({
  labels: ["Generation 0", "Generation 1", "Generation 2"],
  datasets: [
    {
      label: "Объекты",
      data: [0, 0, 0],
      backgroundColor: [
        "rgba(255, 99, 132, 0.5)",
        "rgba(54, 162, 235, 0.5)",
        "rgba(75, 192, 192, 0.5)",
      ],
    },
  ],
});

// Request Methods Data
const requestMethodsData = ref({
  labels: ["GET", "POST", "PUT", "DELETE"],
  datasets: [
    {
      label: "Запросы",
      data: [0, 0, 0, 0],
      backgroundColor: [
        "rgba(255, 99, 132, 0.5)",
        "rgba(54, 162, 235, 0.5)",
        "rgba(75, 192, 192, 0.5)",
        "rgba(255, 206, 86, 0.5)",
      ],
    },
  ],
});

// Parse Prometheus metrics format
const parsePrometheusMetrics = (text) => {
  const metrics = {};
  const lines = text.split("\n");

  for (const line of lines) {
    if (line && !line.startsWith("#")) {
      const [key, value] = line.split(" ");
      if (key && value) {
        // Extract metric name and labels
        const match = key.match(/^([^{]+)({[^}]+})?$/);
        if (match) {
          const metricName = match[1];
          const labels = match[2];

          if (!metrics[metricName]) {
            metrics[metricName] = {};
          }

          if (labels) {
            // Parse labels if present
            const labelMatch = labels.match(/\{([^}]+)\}/);
            if (labelMatch) {
              const labelStr = labelMatch[1];
              metrics[metricName][labelStr] = parseFloat(value);
            }
          } else {
            // No labels, just store the value
            metrics[metricName] = parseFloat(value);
          }
        }
      }
    }
  }
  return metrics;
};

// Fetch metrics data
const fetchMetrics = async () => {
  try {
    const response = await fetch(`${useRuntimeConfig().public.apiBase}/metrics/`);
    const text = await response.text();
    const data = parsePrometheusMetrics(text);

    // Update metrics
    metrics.value = {
      totalRequests: data.django_http_requests_before_middlewares_total || 0,
      avgLatency:
        data.django_http_requests_latency_including_middlewares_seconds_sum /
          data.django_http_requests_latency_including_middlewares_seconds_count || 0,
      successfulRequests: data.django_http_responses_before_middlewares_total || 0,
      gcObjectsCollected:
        (data.python_gc_objects_collected_total?.['generation="0"'] || 0) +
        (data.python_gc_objects_collected_total?.['generation="1"'] || 0) +
        (data.python_gc_objects_collected_total?.['generation="2"'] || 0),
    };

    // Update HTTP Requests chart
    httpRequestsData.value.datasets[0].data = [
      data.django_http_requests_before_middlewares_total || 0,
      data.django_http_requests_before_middlewares_total || 0,
      data.django_http_responses_before_middlewares_total || 0,
    ];

    // Update Latency chart
    const latencyBuckets = {};
    Object.entries(data).forEach(([key, value]) => {
      if (key === "django_http_requests_latency_including_middlewares_seconds_bucket") {
        Object.entries(value).forEach(([label, count]) => {
          const match = label.match(/le="([^"]+)"/);
          if (match) {
            latencyBuckets[match[1]] = count;
          }
        });
      }
    });

    latencyData.value.datasets[0].data = latencyData.value.labels.map(
      (label) => latencyBuckets[label] || 0
    );

    // Update GC chart
    gcData.value.datasets[0].data = [
      data.python_gc_objects_collected_total?.['generation="0"'] || 0,
      data.python_gc_objects_collected_total?.['generation="1"'] || 0,
      data.python_gc_objects_collected_total?.['generation="2"'] || 0,
    ];

    // Update Request Methods chart
    const methodCounts = {
      GET: 0,
      POST: 0,
      PUT: 0,
      DELETE: 0,
    };

    Object.entries(data).forEach(([key, value]) => {
      if (key === "django_http_requests_total_by_method_total") {
        Object.entries(value).forEach(([label, count]) => {
          const match = label.match(/method="([^"]+)"/);
          if (match && match[1] in methodCounts) {
            methodCounts[match[1]] = count;
          }
        });
      }
    });

    requestMethodsData.value.datasets[0].data = Object.values(methodCounts);
  } catch (error) {
    console.error("Error fetching metrics:", error);
  }
};

// Fetch metrics on mount and every 30 seconds
onMounted(() => {
  fetchMetrics();
  const interval = setInterval(fetchMetrics, 30000);
  onUnmounted(() => clearInterval(interval));
});
</script>
