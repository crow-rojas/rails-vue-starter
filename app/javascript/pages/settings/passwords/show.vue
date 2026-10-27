<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"
import { computed } from "vue"

import HeadingSmall from "@/components/HeadingSmall.vue"
import { Button } from "@/components/ui/button"
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { useI18n } from "@/composables/useI18n"
import AppLayout from "@/layouts/AppLayout.vue"
import SettingsLayout from "@/layouts/settings/Layout.vue"
import { settingsPasswords } from "@/routes"
import { type BreadcrumbItem } from "@/types"

const { t } = useI18n()

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  {
    title: t("ui.settings.passwords.breadcrumb"),
    href: settingsPasswords.show().url,
  },
])
</script>

<template>
  <AppLayout :breadcrumbs="breadcrumbs">
    <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

    <SettingsLayout>
      <div class="space-y-6">
        <HeadingSmall
          :title="t('ui.settings.passwords.title')"
          :description="t('ui.settings.passwords.description')"
        />

        <Form
          class="space-y-6"
          :action="settingsPasswords.update()"
          :options="{ preserveScroll: true }"
          resetOnError
          resetOnSuccess
          #default="{ errors, processing }"
        >
          <FieldGroup>
            <Field>
              <FieldLabel for="password_challenge">{{
                t("ui.settings.passwords.current_password")
              }}</FieldLabel>
              <Input
                id="password_challenge"
                name="password_challenge"
                type="password"
                autocomplete="current-password"
                :placeholder="t('ui.settings.passwords.current_password')"
              />
              <FieldError :errors="errors.password_challenge" />
            </Field>

            <Field>
              <FieldLabel for="password">{{
                t("ui.settings.passwords.new_password")
              }}</FieldLabel>
              <Input
                id="password"
                name="password"
                type="password"
                autocomplete="new-password"
                :placeholder="t('ui.settings.passwords.new_password')"
              />
              <FieldError :errors="errors.password" />
            </Field>

            <Field>
              <FieldLabel for="password_confirmation">
                {{ t("ui.settings.passwords.confirm_password") }}
              </FieldLabel>
              <Input
                id="password_confirmation"
                name="password_confirmation"
                type="password"
                autocomplete="new-password"
                :placeholder="t('ui.settings.passwords.confirm_password')"
              />
              <FieldError :errors="errors.password_confirmation" />
            </Field>
          </FieldGroup>

          <div class="flex items-center gap-4">
            <Button :disabled="processing">{{
              t("ui.settings.passwords.save")
            }}</Button>
          </div>
        </Form>
      </div>
    </SettingsLayout>
  </AppLayout>
</template>
