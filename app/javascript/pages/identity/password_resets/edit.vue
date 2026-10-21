<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"
import { LoaderCircle } from "@lucide/vue"

import { Button } from "@/components/ui/button"
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { useI18n } from "@/composables/useI18n"
import AuthLayout from "@/layouts/AuthLayout.vue"
import { identityPasswordResets } from "@/routes"

interface Props {
  sid: string
  email: string
}

const props = defineProps<Props>()

const { t } = useI18n()
</script>

<template>
  <AuthLayout
    :title="t('ui.identity.password_resets.edit.title')"
    :description="t('ui.identity.password_resets.edit.description')"
  >
    <Head :title="t('ui.identity.password_resets.edit.title')" />

    <Form
      :action="identityPasswordResets.update()"
      :transform="(data) => ({ ...data, sid, email })"
      :resetOnSuccess="['password', 'password_confirmation']"
      #default="{ errors, processing }"
    >
      <FieldGroup>
        <Field>
          <FieldLabel for="email">{{
            t("ui.identity.password_resets.edit.email")
          }}</FieldLabel>
          <Input
            id="email"
            name="email"
            type="email"
            autocomplete="email"
            :defaultValue="props.email"
            readonly
          />
          <FieldError :errors="errors.email" />
        </Field>

        <Field>
          <FieldLabel for="password">{{
            t("ui.identity.password_resets.edit.password")
          }}</FieldLabel>
          <Input
            id="password"
            name="password"
            type="password"
            autocomplete="new-password"
            autofocus
            :placeholder="t('ui.identity.password_resets.edit.password')"
          />
          <FieldError :errors="errors.password" />
        </Field>

        <Field>
          <FieldLabel for="password_confirmation">
            {{ t("ui.identity.password_resets.edit.confirm_password_label") }}
          </FieldLabel>
          <Input
            id="password_confirmation"
            name="password_confirmation"
            type="password"
            autocomplete="new-password"
            :placeholder="
              t('ui.identity.password_resets.edit.confirm_password_placeholder')
            "
          />
          <FieldError :errors="errors.password_confirmation" />
        </Field>

        <Button type="submit" class="mt-4 w-full" :disabled="processing">
          <LoaderCircle v-if="processing" class="h-4 w-4 animate-spin" />
          {{ t("ui.identity.password_resets.edit.title") }}
        </Button>
      </FieldGroup>
    </Form>
  </AuthLayout>
</template>
