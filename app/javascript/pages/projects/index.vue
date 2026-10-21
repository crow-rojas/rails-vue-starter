<script setup lang="ts">
import { Head, Link } from "@inertiajs/vue3"
import { computed } from "vue"

import { Button } from "@/components/ui/button"
import { useI18n } from "@/composables/useI18n"
import AppLayout from "@/layouts/AppLayout.vue"
import { projects as projectsRoutes } from "@/routes"
import type { BreadcrumbItem, ProjectsIndex } from "@/types"

defineProps<ProjectsIndex>()

const { t } = useI18n()

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { title: t("ui.projects.index.title"), href: projectsRoutes.index().url },
])
</script>

<template>
  <Head :title="t('ui.projects.index.title')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-4 p-4">
      <div class="flex items-center justify-between">
        <h1 class="text-xl font-semibold">
          {{ t("ui.projects.index.title") }}
        </h1>
        <Button as-child>
          <Link :href="projectsRoutes.new()">
            {{ t("ui.projects.index.new") }}
          </Link>
        </Button>
      </div>

      <p v-if="projects.length === 0" class="text-muted-foreground text-sm">
        {{ t("ui.projects.index.empty") }}
      </p>
      <ul v-else class="divide-y rounded-xl border">
        <li v-for="project in projects" :key="project.id">
          <Link
            :href="projectsRoutes.show(project.id)"
            class="hover:bg-muted block px-4 py-3"
          >
            {{ project.name }}
          </Link>
        </li>
      </ul>
    </div>
  </AppLayout>
</template>
