<script setup lang="ts">
import { Head, Link } from "@inertiajs/vue3"
import { computed } from "vue"

import { Button } from "@/components/ui/button"
import { useI18n } from "@/composables/useI18n"
import AuthLayout from "@/layouts/AuthLayout.vue"
import { home } from "@/routes"
import type { ErrorsShow } from "@/types"

const props = defineProps<ErrorsShow>()

const { t } = useI18n()

const copy = computed(() => {
  switch (props.status) {
    case 404:
      return {
        title: t("ui.errors.show.not_found.title"),
        description: t("ui.errors.show.not_found.description"),
      }
    case 500:
      return {
        title: t("ui.errors.show.server_error.title"),
        description: t("ui.errors.show.server_error.description"),
      }
    case 503:
      return {
        title: t("ui.errors.show.unavailable.title"),
        description: t("ui.errors.show.unavailable.description"),
      }
    default:
      return {
        title: t("ui.errors.show.other.title", { status: props.status }),
        description: t("ui.errors.show.other.description"),
      }
  }
})
</script>

<template>
  <AuthLayout :title="copy.title" :description="copy.description">
    <Head :title="copy.title" />

    <Button as-child>
      <Link :href="home.index()">{{ t("ui.errors.show.home") }}</Link>
    </Button>
  </AuthLayout>
</template>
