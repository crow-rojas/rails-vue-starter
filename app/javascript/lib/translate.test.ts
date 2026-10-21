import { describe, expect, it } from "vitest"

import { translate } from "./translate"

const dictionary = {
  ui: {
    greeting: "Hello, %{name}",
    projects: { one: "%{count} project", other: "%{count} projects" },
    tasks: { zero: "No tasks", one: "One task", other: "%{count} tasks" },
  },
}

describe("translate", () => {
  it("reads a dotted key and interpolates Rails-style placeholders", () => {
    expect(translate(dictionary, "en", "ui.greeting", { name: "Ada" })).toBe(
      "Hello, Ada",
    )
  })

  it("leaves a placeholder without a value as it is", () => {
    expect(translate(dictionary, "en", "ui.greeting")).toBe("Hello, %{name}")
  })

  it("picks the plural form for the count", () => {
    expect(translate(dictionary, "en", "ui.projects", { count: 1 })).toBe(
      "1 project",
    )
    expect(translate(dictionary, "en", "ui.projects", { count: 3 })).toBe(
      "3 projects",
    )
  })

  it("uses zero only when the key defines it, like Rails", () => {
    expect(translate(dictionary, "en", "ui.tasks", { count: 0 })).toBe(
      "No tasks",
    )
    expect(translate(dictionary, "en", "ui.projects", { count: 0 })).toBe(
      "0 projects",
    )
  })

  it("falls back to other for plural categories Rails does not define", () => {
    expect(translate(dictionary, "es", "ui.projects", { count: 1000000 })).toBe(
      "1000000 projects",
    )
  })

  it("makes a missing key visible", () => {
    expect(translate(dictionary, "en", "ui.nope")).toBe(
      '[missing "en.ui.nope" translation]',
    )
    expect(translate(dictionary, "en", "ui.projects")).toBe(
      '[missing "en.ui.projects" translation]',
    )
  })
})
