<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"
import { LoaderCircle } from "@lucide/vue"

import TextLink from "@/components/TextLink.vue"
import { Button } from "@/components/ui/button"
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { useI18n } from "@/composables/useI18n"
import AuthBase from "@/layouts/AuthLayout.vue"
import { identityPasswordResets, sessions, users } from "@/routes"

const { t } = useI18n()
</script>

<template>
  <AuthBase
    :title="t('ui.sessions.new.title')"
    :description="t('ui.sessions.new.description')"
  >
    <Head :title="t('ui.sessions.new.log_in')" />

    <Form
      :action="sessions.create()"
      :resetOnSuccess="['password']"
      class="flex flex-col gap-6"
      #default="{ errors, processing }"
    >
      <FieldGroup>
        <Field>
          <FieldLabel for="email">{{ t("ui.sessions.new.email") }}</FieldLabel>
          <Input
            id="email"
            name="email"
            type="email"
            required
            autofocus
            autocomplete="email"
            :placeholder="t('ui.sessions.new.email_placeholder')"
          />
          <FieldError :errors="errors.email" />
        </Field>

        <Field>
          <div class="flex items-center justify-between">
            <FieldLabel for="password">{{
              t("ui.sessions.new.password")
            }}</FieldLabel>
            <TextLink :href="identityPasswordResets.new()" class="text-sm">
              {{ t("ui.sessions.new.forgot_password") }}
            </TextLink>
          </div>
          <Input
            id="password"
            name="password"
            type="password"
            required
            autocomplete="current-password"
            :placeholder="t('ui.sessions.new.password')"
          />
          <FieldError :errors="errors.password" />
        </Field>

        <Button type="submit" class="mt-4 w-full" :disabled="processing">
          <LoaderCircle v-if="processing" class="h-4 w-4 animate-spin" />
          {{ t("ui.sessions.new.log_in") }}
        </Button>
      </FieldGroup>

      <div class="text-muted-foreground text-center text-sm">
        {{ t("ui.sessions.new.no_account") }}
        <TextLink :href="users.new()">{{
          t("ui.sessions.new.sign_up")
        }}</TextLink>
      </div>
    </Form>
  </AuthBase>
</template>
