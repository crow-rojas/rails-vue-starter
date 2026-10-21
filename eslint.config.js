import skipFormatting from "@vue/eslint-config-prettier/skip-formatting"
import {
  defineConfigWithVueTs,
  vueTsConfigs,
} from "@vue/eslint-config-typescript"
import importPlugin from "eslint-plugin-import-x"
import pluginVue from "eslint-plugin-vue"

export default defineConfigWithVueTs(
  {
    name: "app/files-to-lint",
    files: ["app/javascript/**/*.{ts,mts,tsx,vue}"],
  },
  {
    ignores: [
      "app/javascript/components/ui/**",
      "app/javascript/routes/**",
      "app/javascript/types/serializers/**",
    ],
  },

  pluginVue.configs["flat/essential"],
  vueTsConfigs.recommended,
  {
    ...importPlugin.flatConfigs.recommended,
    ...importPlugin.flatConfigs.typescript,
    settings: { "import-x/resolver": { typescript: {} } },
    rules: {
      "vue/multi-word-component-names": "off",
      "vue/no-bare-strings-in-template": "error",
      "import-x/order": [
        "error",
        {
          pathGroups: [
            {
              pattern: "@/**",
              group: "external",
              position: "after",
            },
          ],
          "newlines-between": "always",
          named: true,
          alphabetize: { order: "asc" },
        },
      ],
      "import-x/first": "error",
      "import-x/extensions": [
        "error",
        "always",
        {
          js: "never",
          jsx: "never",
          ts: "never",
          tsx: "never",
          mts: "never",
        },
      ],
      "@typescript-eslint/consistent-type-imports": "error",
    },
  },
  {
    name: "app/no-suppressions",
    linterOptions: { noInlineConfig: true },
    rules: {
      "@typescript-eslint/ban-ts-comment": [
        "error",
        {
          "ts-expect-error": true,
          "ts-ignore": true,
          "ts-nocheck": true,
        },
      ],
    },
  },
  skipFormatting,
)
