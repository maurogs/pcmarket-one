import { Controller } from "@hotwired/stimulus"

// Submits the surrounding form; text inputs are debounced. Empty fields are
// disabled for GET forms so URLs stay short and shareable.
export default class extends Controller {
  static values = { delay: { type: Number, default: 350 } }

  connect() {
    this.cleanup = () => {
      if (this.element.method !== "get") return
      this.element.querySelectorAll("input, select").forEach((field) => {
        if (!field.value && field.type !== "checkbox" && field.type !== "radio") field.disabled = true
      })
      requestAnimationFrame(() => this.element.querySelectorAll(":disabled").forEach((field) => { field.disabled = false }))
    }
    this.element.addEventListener("submit", this.cleanup)
  }

  disconnect() {
    clearTimeout(this.timer)
    this.element.removeEventListener("submit", this.cleanup)
  }

  submit() { this.element.requestSubmit() }

  debounced() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.submit(), this.delayValue)
  }
}
