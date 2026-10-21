<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"
import { LoaderCircle } from "@lucide/vue"

import TextLink from "@/components/TextLink.vue"
import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { useI18n } from "@/composables/useI18n"
import AuthLayout from "@/layouts/AuthLayout.vue"
import { identityPasswordResets, sessions } from "@/routes"

const { t } = useI18n()
</script>

<template>
  <AuthLayout
    :title="t('ui.identity.password_resets.new.title')"
    :description="t('ui.identity.password_resets.new.description')"
  >
    <Head :title="t('ui.identity.password_resets.new.title')" />

    <div class="space-y-6">
      <Form
        :action="identityPasswordResets.create()"
        #default="{ errors, processing }"
      >
        <Field>
          <FieldLabel for="email">{{
            t("ui.identity.password_resets.new.email")
          }}</FieldLabel>
          <Input
            id="email"
            name="email"
            type="email"
            autocomplete="off"
            autofocus
            :placeholder="
              t('ui.identity.password_resets.new.email_placeholder')
            "
          />
          <FieldError :errors="errors.email" />
        </Field>

        <div class="my-6 flex items-center justify-start">
          <Button class="w-full" :disabled="processing">
            <LoaderCircle v-if="processing" class="h-4 w-4 animate-spin" />
            {{ t("ui.identity.password_resets.new.submit") }}
          </Button>
        </div>
      </Form>

      <div class="text-muted-foreground space-x-1 text-center text-sm">
        <span>{{ t("ui.identity.password_resets.new.return_to") }}</span>
        <TextLink :href="sessions.new()">{{
          t("ui.identity.password_resets.new.log_in")
        }}</TextLink>
      </div>
    </div>
  </AuthLayout>
</template>
