<script setup lang="ts">
import { ref, watch } from "vue"

import AppSidebar from "@/components/AppSidebar.vue"
import AppSidebarHeader from "@/components/AppSidebarHeader.vue"
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar"
import * as storage from "@/lib/storage"
import type { BreadcrumbItem } from "@/types"

withDefaults(defineProps<{ breadcrumbs?: BreadcrumbItem[] }>(), {
  breadcrumbs: () => [],
})

const isOpen = ref(storage.getItem("sidebar") !== "false")

watch(isOpen, (open) => {
  storage.setItem("sidebar", String(open))
})
</script>

<template>
  <SidebarProvider :default-open="isOpen" v-model:open="isOpen">
    <AppSidebar />
    <SidebarInset class="overflow-x-hidden">
      <AppSidebarHeader :breadcrumbs="breadcrumbs" />
      <slot />
    </SidebarInset>
  </SidebarProvider>
</template>
