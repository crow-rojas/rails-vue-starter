<script setup lang="ts">
import { Form, Head, usePage } from "@inertiajs/vue3"
import { computed } from "vue"

import DeleteUser from "@/components/DeleteUser.vue"
import HeadingSmall from "@/components/HeadingSmall.vue"
import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { useI18n } from "@/composables/useI18n"
import AppLayout from "@/layouts/AppLayout.vue"
import SettingsLayout from "@/layouts/settings/Layout.vue"
import { settingsProfiles } from "@/routes"
import { type BreadcrumbItem, type User } from "@/types"

const { t } = useI18n()

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  {
    title: t("ui.settings.profile.breadcrumb"),
    href: settingsProfiles.show().url,
  },
])

const page = usePage()
const user = computed(() => page.props.auth.user as User)
const locales = ["en", "es"]
</script>

<template>
  <AppLayout :breadcrumbs="breadcrumbs">
    <Head :title="t('ui.settings.profile.breadcrumb')" />

    <SettingsLayout>
      <div class="flex flex-col space-y-6">
        <HeadingSmall
          :title="t('ui.settings.profile.title')"
          :description="t('ui.settings.profile.description')"
        />

        <Form
          :action="settingsProfiles.update()"
          :options="{ preserveScroll: true }"
          class="space-y-6"
          #default="{ errors, processing, recentlySuccessful }"
        >
          <Field>
            <FieldLabel for="name">{{
              t("ui.settings.profile.name")
            }}</FieldLabel>
            <Input
              id="name"
              name="name"
              :defaultValue="user.name"
              required
              autocomplete="name"
              :placeholder="t('ui.settings.profile.name_placeholder')"
            />
            <FieldError :errors="errors.name" />
          </Field>

          <Field>
            <FieldLabel for="locale">{{
              t("ui.settings.profile.language")
            }}</FieldLabel>
            <select
              id="locale"
              name="locale"
              :value="user.locale ?? page.props.locale"
              class="border-input dark:bg-input/30 h-9 w-full rounded-md border bg-transparent px-3 text-sm shadow-xs"
            >
              <option v-for="locale in locales" :key="locale" :value="locale">
                {{ t(`ui.locales.${locale}`) }}
              </option>
            </select>
            <FieldError :errors="errors.locale" />
          </Field>

          <div class="flex items-center gap-4">
            <Button :disabled="processing">{{
              t("ui.settings.profile.save")
            }}</Button>

            <Transition
              enter-active-class="transition ease-in-out"
              enter-from-class="opacity-0"
              leave-active-class="transition ease-in-out"
              leave-to-class="opacity-0"
            >
              <p v-show="recentlySuccessful" class="text-sm text-neutral-600">
                {{ t("ui.settings.profile.saved") }}
              </p>
            </Transition>
          </div>
        </Form>
      </div>

      <DeleteUser />
    </SettingsLayout>
  </AppLayout>
</template>
