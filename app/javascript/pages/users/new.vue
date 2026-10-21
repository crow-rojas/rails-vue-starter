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
import { sessions, users } from "@/routes"

const { t } = useI18n()
</script>

<template>
  <AuthBase
    :title="t('ui.users.new.title')"
    :description="t('ui.users.new.description')"
  >
    <Head :title="t('ui.users.new.register')" />

    <Form
      :action="users.create()"
      :resetOnSuccess="['password', 'password_confirmation']"
      disableWhileProcessing
      class="flex flex-col gap-6"
      #default="{ errors, processing }"
    >
      <FieldGroup>
        <Field>
          <FieldLabel for="name">{{ t("ui.users.new.name") }}</FieldLabel>
          <Input
            id="name"
            name="name"
            type="text"
            required
            autofocus
            autocomplete="name"
            :placeholder="t('ui.users.new.name_placeholder')"
          />
          <FieldError :errors="errors.name" />
        </Field>

        <Field>
          <FieldLabel for="email">{{ t("ui.users.new.email") }}</FieldLabel>
          <Input
            id="email"
            name="email"
            type="email"
            required
            autocomplete="email"
            :placeholder="t('ui.users.new.email_placeholder')"
          />
          <FieldError :errors="errors.email" />
        </Field>

        <Field>
          <FieldLabel for="password">{{
            t("ui.users.new.password")
          }}</FieldLabel>
          <Input
            id="password"
            name="password"
            type="password"
            required
            autocomplete="new-password"
            :placeholder="t('ui.users.new.password')"
          />
          <FieldError :errors="errors.password" />
        </Field>

        <Field>
          <FieldLabel for="password_confirmation">{{
            t("ui.users.new.confirm_password")
          }}</FieldLabel>
          <Input
            id="password_confirmation"
            name="password_confirmation"
            type="password"
            required
            autocomplete="new-password"
            :placeholder="t('ui.users.new.confirm_password')"
          />
          <FieldError :errors="errors.password_confirmation" />
        </Field>

        <Button type="submit" class="mt-2 w-full" :disabled="processing">
          <LoaderCircle v-if="processing" class="h-4 w-4 animate-spin" />
          {{ t("ui.users.new.submit") }}
        </Button>
      </FieldGroup>

      <div class="text-muted-foreground text-center text-sm">
        {{ t("ui.users.new.have_account") }}
        <TextLink :href="sessions.new()" class="underline underline-offset-4">{{
          t("ui.users.new.log_in")
        }}</TextLink>
      </div>
    </Form>
  </AuthBase>
</template>
