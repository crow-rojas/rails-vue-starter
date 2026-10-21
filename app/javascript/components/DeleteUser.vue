<script setup lang="ts">
import { Form } from "@inertiajs/vue3"

import HeadingSmall from "@/components/HeadingSmall.vue"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { useI18n } from "@/composables/useI18n"
import { users } from "@/routes"

const { t } = useI18n()

// The shadcn Input exposes no focus(), so reach the element by id.
const focusPassword = () =>
  document.getElementById("password_challenge")?.focus()
</script>

<template>
  <div class="space-y-6">
    <HeadingSmall
      :title="t('ui.delete_user.title')"
      :description="t('ui.delete_user.description')"
    />
    <div
      class="space-y-4 rounded-lg border border-red-100 bg-red-50 p-4 dark:border-red-200/10 dark:bg-red-700/10"
    >
      <div class="relative space-y-0.5 text-red-600 dark:text-red-100">
        <p class="font-medium">{{ t("ui.delete_user.warning") }}</p>
        <p class="text-sm">
          {{ t("ui.delete_user.caution") }}
        </p>
      </div>
      <Dialog>
        <DialogTrigger as-child>
          <Button variant="destructive">{{ t("ui.delete_user.title") }}</Button>
        </DialogTrigger>
        <DialogContent>
          <Form
            :action="users.destroy()"
            :options="{ preserveScroll: true }"
            :onError="focusPassword"
            resetOnSuccess
            className="space-y-6"
            #default="{ resetAndClearErrors, processing, errors }"
          >
            <DialogHeader class="space-y-3">
              <DialogTitle>{{ t("ui.delete_user.confirm_title") }}</DialogTitle>
              <DialogDescription>
                {{ t("ui.delete_user.confirm_description") }}
              </DialogDescription>
            </DialogHeader>

            <Field>
              <FieldLabel for="password_challenge" class="sr-only">
                {{ t("ui.delete_user.password") }}
              </FieldLabel>
              <Input
                id="password_challenge"
                type="password"
                name="password_challenge"
                :placeholder="t('ui.delete_user.password')"
              />
              <FieldError :errors="errors.password_challenge" />
            </Field>

            <DialogFooter class="gap-2">
              <DialogClose as-child>
                <Button variant="secondary" @click="resetAndClearErrors">
                  {{ t("ui.delete_user.cancel") }}
                </Button>
              </DialogClose>

              <Button
                type="submit"
                variant="destructive"
                :disabled="processing"
              >
                {{ t("ui.delete_user.title") }}
              </Button>
            </DialogFooter>
          </Form>
        </DialogContent>
      </Dialog>
    </div>
  </div>
</template>
