export type Dictionary = { [key: string]: string | Dictionary }
export type TranslateOptions = Record<string, string | number> & {
  count?: number
}

// Rails I18n semantics in the browser: dotted keys, %{name} placeholders, and plural forms picked
// by Intl.PluralRules from `count`, using zero only when the key defines it and other as the fallback.
export function translate(
  dictionary: Dictionary,
  locale: string,
  key: string,
  options: TranslateOptions = {},
): string {
  let value: string | Dictionary | undefined = dictionary
  for (const part of key.split(".")) {
    value = typeof value === "object" ? value[part] : undefined
  }

  if (typeof value === "object" && options.count !== undefined) {
    const forms: Dictionary = value
    const category = new Intl.PluralRules(locale).select(options.count)
    value =
      (options.count === 0 ? forms.zero : undefined) ??
      forms[category] ??
      forms.other
  }

  if (typeof value !== "string")
    return `[missing "${locale}.${key}" translation]`

  return value.replace(/%\{(\w+)\}/g, (placeholder, name: string) =>
    name in options ? String(options[name]) : placeholder,
  )
}
