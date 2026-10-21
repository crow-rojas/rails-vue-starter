import type { FlashData, SharedProps } from "@/types"

declare module "@inertiajs/core" {
  export interface InertiaConfig {
    sharedPageProps: SharedProps & {
      locale: string
      translations: Record<string, unknown>
    }
    flashDataType: FlashData
    errorValueType: string[]
  }
}
