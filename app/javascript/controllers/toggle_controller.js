import { Controller } from "@hotwired/stimulus"

// Generic show/hide, e.g. the mobile filter sheet or "show more" option lists.
export default class extends Controller {
  static targets = ["content", "button"]
  static values = { lockScroll: Boolean }

  toggle() {
    const willShow = this.contentTargets.some((element) => element.hidden)
    this.contentTargets.forEach((element) => { element.hidden = !willShow })
    this.buttonTargets.forEach((button) => button.setAttribute("aria-expanded", willShow ? "true" : "false"))
    if (this.lockScrollValue) document.body.style.overflow = willShow ? "hidden" : ""
  }

  hide() {
    this.contentTargets.forEach((element) => { element.hidden = true })
    if (this.lockScrollValue) document.body.style.overflow = ""
  }
}
