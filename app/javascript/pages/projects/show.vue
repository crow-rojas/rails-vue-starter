<script setup lang="ts">
import { Head, Link } from "@inertiajs/vue3"
import { computed } from "vue"

import { Button } from "@/components/ui/button"
import { useI18n } from "@/composables/useI18n"
import AppLayout from "@/layouts/AppLayout.vue"
import { projects as projectsRoutes } from "@/routes"
import type { BreadcrumbItem, ProjectsShow } from "@/types"

const props = defineProps<ProjectsShow>()

const { t, locale } = useI18n()

const confirmDelete = () => window.confirm(t("ui.projects.show.confirm_delete"))

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { title: t("ui.projects.index.title"), href: projectsRoutes.index().url },
  {
    title: props.project.name,
    href: projectsRoutes.show(props.project.id).url,
  },
])
</script>

<template>
  <Head :title="project.name" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-4 p-4">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-xl font-semibold">{{ project.name }}</h1>
          <p class="text-muted-foreground text-sm">
            {{
              t("ui.projects.show.created_at", {
                date: new Date(project.created_at).toLocaleDateString(locale),
              })
            }}
          </p>
        </div>
        <div class="flex gap-2">
          <Button variant="outline" as-child>
            <Link :href="projectsRoutes.edit(project.id)">
              {{ t("ui.projects.show.edit") }}
            </Link>
          </Button>
          <Button variant="destructive" as-child>
            <Link
              :href="projectsRoutes.destroy(project.id)"
              as="button"
              :onBefore="confirmDelete"
            >
              {{ t("ui.projects.show.delete") }}
            </Link>
          </Button>
        </div>
      </div>
    </div>
  </AppLayout>
</template>
