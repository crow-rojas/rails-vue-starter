import { defineConfig } from "vitest/config"

// Unit tests for plain TypeScript; the app's vite.config.ts needs Rails around it.
export default defineConfig({
  test: { include: ["app/javascript/**/*.test.ts"] },
})
