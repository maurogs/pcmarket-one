import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  open() {
    this.panelTarget.hidden = false
    document.body.style.overflow = "hidden"
    this.panelTarget.querySelector("button, a")?.focus()
    this.escape = (event) => { if (event.key === "Escape") this.close() }
    document.addEventListener("keydown", this.escape)
  }

  close() {
    this.panelTarget.hidden = true
    document.body.style.overflow = ""
    document.removeEventListener("keydown", this.escape)
  }

  disconnect() { if (this.hasPanelTarget && !this.panelTarget.hidden) this.close() }
}
