<script setup lang="ts">
import { Link, usePage } from "@inertiajs/vue3"
import { computed } from "vue"

import Heading from "@/components/Heading.vue"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { useI18n } from "@/composables/useI18n"
import {
  settingsAppearance,
  settingsEmails,
  settingsPasswords,
  settingsProfiles,
  settingsSessions,
} from "@/routes"
import { type NavItem } from "@/types"

const { t } = useI18n()

const sidebarNavItems = computed<NavItem[]>(() => [
  {
    title: t("ui.layouts.settings.profile"),
    href: settingsProfiles.show().url,
  },
  {
    title: t("ui.layouts.settings.email"),
    href: settingsEmails.show().url,
  },
  {
    title: t("ui.layouts.settings.password"),
    href: settingsPasswords.show().url,
  },
  {
    title: t("ui.layouts.settings.sessions"),
    href: settingsSessions.index().url,
  },
  {
    title: t("ui.layouts.settings.appearance"),
    href: settingsAppearance().url,
  },
])

const page = usePage()
</script>

<template>
  <div class="px-4 py-6">
    <Heading
      :title="t('ui.layouts.settings.title')"
      :description="t('ui.layouts.settings.description')"
    />

    <div class="flex flex-col lg:flex-row lg:space-x-12">
      <aside class="w-full max-w-xl lg:w-48">
        <nav class="flex flex-col space-y-1 space-x-0">
          <Button
            v-for="item in sidebarNavItems"
            :key="item.href"
            variant="ghost"
            :class="[
              'w-full justify-start',
              { 'bg-muted': page.url === item.href },
            ]"
            as-child
          >
            <Link :href="item.href">
              {{ item.title }}
            </Link>
          </Button>
        </nav>
      </aside>

      <Separator class="my-6 lg:hidden" />

      <div class="flex-1 md:max-w-2xl">
        <section class="max-w-xl space-y-12">
          <slot />
        </section>
      </div>
    </div>
  </div>
</template>
