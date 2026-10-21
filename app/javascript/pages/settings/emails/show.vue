<script setup lang="ts">
import { Form, Head, Link, usePage } from "@inertiajs/vue3"
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
import { identityEmailVerifications, settingsEmails } from "@/routes"
import type { BreadcrumbItem } from "@/types"

const { t } = useI18n()

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  {
    title: t("ui.settings.emails.breadcrumb"),
    href: settingsEmails.show().url,
  },
])

const page = usePage()
const user = computed(() => page.props.auth.user)
</script>

<template>
  <AppLayout :breadcrumbs="breadcrumbs">
    <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

    <SettingsLayout>
      <div class="space-y-6">
        <HeadingSmall
          :title="t('ui.settings.emails.title')"
          :description="t('ui.settings.emails.description')"
        />

        <Form
          :action="settingsEmails.update()"
          :options="{ preserveScroll: true }"
          :resetOnError="['password_challenge']"
          :resetOnSuccess="['password_challenge']"
          class="space-y-6"
          #default="{ errors, processing, recentlySuccessful }"
        >
          <FieldGroup>
            <Field>
              <FieldLabel for="email">{{
                t("ui.settings.emails.email")
              }}</FieldLabel>

              <Input
                id="email"
                name="email"
                type="email"
                :defaultValue="user.email"
                required
                autocomplete="username"
                :placeholder="t('ui.settings.emails.email')"
              />

              <FieldError :errors="errors.email" />
            </Field>

            <div v-if="!user.verified">
              <p class="text-muted-foreground -mt-4 text-sm">
                {{ t("ui.settings.emails.unverified") }}
                <Link
                  :href="identityEmailVerifications.create()"
                  as="button"
                  class="text-foreground underline decoration-neutral-300 underline-offset-4 transition-colors duration-300 ease-out hover:decoration-current! dark:decoration-neutral-500"
                >
                  {{ t("ui.settings.emails.resend") }}
                </Link>
              </p>
            </div>

            <Field>
              <FieldLabel for="password_challenge">{{
                t("ui.settings.emails.current_password")
              }}</FieldLabel>

              <Input
                id="password_challenge"
                name="password_challenge"
                type="password"
                autocomplete="current-password"
                :placeholder="t('ui.settings.emails.current_password')"
              />

              <FieldError :errors="errors.password_challenge" />
            </Field>
          </FieldGroup>

          <div class="flex items-center gap-4">
            <Button :disabled="processing">{{
              t("ui.settings.emails.save")
            }}</Button>

            <Transition
              enter-active-class="transition ease-in-out"
              enter-from-class="opacity-0"
              leave-active-class="transition ease-in-out"
              leave-to-class="opacity-0"
            >
              <p v-show="recentlySuccessful" class="text-sm text-neutral-600">
                {{ t("ui.settings.emails.saved") }}
              </p>
            </Transition>
          </div>
        </Form>
      </div>
    </SettingsLayout>
  </AppLayout>
</template>
