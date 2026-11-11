import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.menuTarget.hidden = false
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.menuTarget.querySelector("a, button")?.focus({ preventScroll: true })
  }

  close() {
    if (!this.hasMenuTarget || this.menuTarget.hidden) return
    this.menuTarget.hidden = true
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  closeOutside(event) {
    if (!this.element.contains(event.target)) this.close()
  }
}
