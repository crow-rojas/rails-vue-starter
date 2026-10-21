import { usePage } from "@inertiajs/vue3"
import { computed } from "vue"

import {
  type Dictionary,
  type TranslateOptions,
  translate,
} from "@/lib/translate"

// Rails sends the "ui" translations of the current locale once (see InertiaController).
export function useI18n() {
  const page = usePage()

  const t = (key: string, options?: TranslateOptions) =>
    translate(
      page.props.translations as Dictionary,
      page.props.locale,
      key,
      options,
    )

  return { t, locale: computed(() => page.props.locale) }
}
