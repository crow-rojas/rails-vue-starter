<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
import { computed } from "vue"

import ProjectForm from "@/components/projects/ProjectForm.vue"
import { useI18n } from "@/composables/useI18n"
import AppLayout from "@/layouts/AppLayout.vue"
import { projects as projectsRoutes } from "@/routes"
import type { BreadcrumbItem } from "@/types"

const { t } = useI18n()

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { title: t("ui.projects.index.title"), href: projectsRoutes.index().url },
  { title: t("ui.projects.new.title"), href: "" },
])
</script>

<template>
  <Head :title="t('ui.projects.new.title')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4">
      <h1 class="text-xl font-semibold">{{ t("ui.projects.new.title") }}</h1>
      <ProjectForm />
    </div>
  </AppLayout>
</template>
