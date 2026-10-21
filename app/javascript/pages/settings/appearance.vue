<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
import { computed } from "vue"

import AppearanceTabs from "@/components/AppearanceTabs.vue"
import HeadingSmall from "@/components/HeadingSmall.vue"
import { useI18n } from "@/composables/useI18n"
import AppLayout from "@/layouts/AppLayout.vue"
import SettingsLayout from "@/layouts/settings/Layout.vue"
import { settingsAppearance } from "@/routes"
import { type BreadcrumbItem } from "@/types"

const { t } = useI18n()

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  {
    title: t("ui.settings.appearance.title"),
    href: settingsAppearance().url,
  },
])
</script>

<template>
  <AppLayout :breadcrumbs="breadcrumbs">
    <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

    <SettingsLayout>
      <div class="space-y-6">
        <HeadingSmall
          :title="t('ui.settings.appearance.title')"
          :description="t('ui.settings.appearance.description')"
        />
        <AppearanceTabs />
      </div>
    </SettingsLayout>
  </AppLayout>
</template>
