import { Controller } from "@hotwired/stimulus"

// Hover/focus opens a panel on desktop; a short delay avoids flicker when moving the pointer.
export default class extends Controller {
  static targets = ["item", "trigger", "panel"]

  open(event) {
    clearTimeout(this.timer)
    const item = event.currentTarget.closest("[data-mega-menu-target='item']")
    this.timer = setTimeout(() => this.show(item), event.type === "focus" ? 0 : 120)
  }

  show(item) {
    this.itemTargets.forEach((element) => {
      const active = element === item
      const panel = element.querySelector("[data-mega-menu-target='panel']")
      const trigger = element.querySelector("[data-mega-menu-target='trigger']")
      if (panel) panel.hidden = !active
      trigger?.setAttribute("aria-expanded", active && panel ? "true" : "false")
    })
  }

  close() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.show(null), 150)
  }

  disconnect() { clearTimeout(this.timer) }
}
