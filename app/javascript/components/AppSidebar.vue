<script setup lang="ts">
import { Link } from "@inertiajs/vue3"
import { BookOpen, Folder, FolderKanban, LayoutGrid } from "@lucide/vue"
import { computed } from "vue"

import NavFooter from "@/components/NavFooter.vue"
import NavMain from "@/components/NavMain.vue"
import NavUser from "@/components/NavUser.vue"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { useI18n } from "@/composables/useI18n"
import { dashboard, projects } from "@/routes"
import { type NavItem } from "@/types"

import AppLogo from "./AppLogo.vue"

const { t } = useI18n()

const mainNavItems = computed<NavItem[]>(() => [
  {
    title: t("ui.nav.dashboard"),
    href: dashboard.index().url,
    icon: LayoutGrid,
  },
  {
    title: t("ui.nav.projects"),
    href: projects.index().url,
    icon: FolderKanban,
  },
])

const footerNavItems = computed<NavItem[]>(() => [
  {
    title: t("ui.nav.github_repo"),
    href: "https://github.com/crow-rojas/rails-vue-starter",
    icon: Folder,
  },
  {
    title: t("ui.nav.documentation"),
    href: "https://inertia-rails.dev",
    icon: BookOpen,
  },
])
</script>

<template>
  <Sidebar collapsible="icon" variant="inset">
    <SidebarHeader>
      <SidebarMenu>
        <SidebarMenuItem>
          <SidebarMenuButton size="lg" as-child>
            <Link :href="dashboard.index()">
              <AppLogo />
            </Link>
          </SidebarMenuButton>
        </SidebarMenuItem>
      </SidebarMenu>
    </SidebarHeader>

    <SidebarContent>
      <NavMain :items="mainNavItems" />
    </SidebarContent>

    <SidebarFooter>
      <NavFooter :items="footerNavItems" />
      <NavUser />
    </SidebarFooter>
  </Sidebar>
  <slot />
</template>
