<script setup lang="ts">
import { watch } from "vue"

import { Toaster } from "@/components/ui/sonner"
import { useAppearance } from "@/composables/useAppearance"
import { useFlash } from "@/composables/useFlash"
import { useI18n } from "@/composables/useI18n"
import "vue-sonner/style.css"

useFlash()

const { appearance } = useAppearance()
const { locale } = useI18n()

// The server sets <html lang> on the first load; Inertia visits keep the document, so follow changes here.
watch(locale, (value) => (document.documentElement.lang = value))
</script>

<template>
  <slot />
  <Toaster richColors position="bottom-right" :theme="appearance" />
</template>
