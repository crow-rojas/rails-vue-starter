<script setup lang="ts">
import { Form, Link } from "@inertiajs/vue3"

import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { useI18n } from "@/composables/useI18n"
import { projects } from "@/routes"
import type { Project } from "@/types"

const props = defineProps<{ project?: Project }>()

const { t } = useI18n()
</script>

<template>
  <Form
    :action="
      props.project ? projects.update(props.project.id) : projects.create()
    "
    disableWhileProcessing
    class="flex max-w-xl flex-col gap-6"
    #default="{ errors, processing }"
  >
    <Field>
      <FieldLabel for="name">{{ t("ui.projects.form.name") }}</FieldLabel>
      <Input
        id="name"
        name="name"
        required
        autofocus
        :defaultValue="props.project?.name"
        :placeholder="t('ui.projects.form.name_placeholder')"
      />
      <FieldError :errors="errors.name" />
    </Field>

    <div class="flex items-center gap-4">
      <Button :disabled="processing">{{ t("ui.projects.form.save") }}</Button>
      <Link
        :href="
          props.project ? projects.show(props.project.id) : projects.index()
        "
        class="text-muted-foreground text-sm"
      >
        {{ t("ui.projects.form.cancel") }}
      </Link>
    </div>
  </Form>
</template>
