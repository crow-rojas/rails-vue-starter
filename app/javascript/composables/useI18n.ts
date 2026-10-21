import { usePage } from "@inertiajs/vue3"
import { I18n, type TranslateOptions } from "i18n-js"
import { computed } from "vue"

// Rails sends the "ui" translations of the current locale once (see InertiaController);
// i18n-js reads them with Rails semantics: %{name} interpolation and one/other plurals.
export function useI18n() {
  const page = usePage()

  const i18n = computed(() => {
    const instance = new I18n({ [page.props.locale]: page.props.translations })
    instance.locale = page.props.locale
    return instance
  })

  const t = (key: string, options?: TranslateOptions) =>
    i18n.value.t(key, options)

  return { t, locale: computed(() => page.props.locale) }
}
