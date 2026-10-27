<script setup lang="ts">
import { Link, usePage } from "@inertiajs/vue3"

import {
  SidebarGroup,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { useI18n } from "@/composables/useI18n"
import { type NavItem } from "@/types"

defineProps<{
  items: NavItem[]
}>()

const page = usePage()
const { t } = useI18n()

// A resource's nav item stays active on its own pages: /projects/1/edit, /projects?page=2.
const isActive = (href: string) =>
  page.url === href ||
  page.url.startsWith(`${href}/`) ||
  page.url.startsWith(`${href}?`)
</script>

<template>
  <SidebarGroup class="px-2 py-0">
    <SidebarGroupLabel>{{ t("ui.nav.platform") }}</SidebarGroupLabel>
    <SidebarMenu>
      <SidebarMenuItem v-for="item in items" :key="item.title">
        <SidebarMenuButton
          as-child
          :is-active="isActive(item.href)"
          :tooltip="item.title"
        >
          <Link :href="item.href">
            <component :is="item.icon" />
            <span>{{ item.title }}</span>
          </Link>
        </SidebarMenuButton>
      </SidebarMenuItem>
    </SidebarMenu>
  </SidebarGroup>
</template>
