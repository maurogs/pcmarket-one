import { Controller } from "@hotwired/stimulus"

// Generic show/hide, e.g. the mobile filter sheet or "show more" option lists.
// With a class value it toggles that class instead of the hidden attribute, so
// responsive utilities (e.g. "max-lg:hidden") keep working on larger screens.
export default class extends Controller {
  static targets = ["content", "button"]
  static values = { lockScroll: Boolean, class: String }

  toggle() {
    const willShow = this.contentTargets.some((element) => this.isHidden(element))
    this.contentTargets.forEach((element) => this.setHidden(element, !willShow))
    this.buttonTargets.forEach((button) => button.setAttribute("aria-expanded", willShow ? "true" : "false"))
    if (this.lockScrollValue) document.body.style.overflow = willShow ? "hidden" : ""
  }

  hide() {
    this.contentTargets.forEach((element) => this.setHidden(element, true))
    if (this.lockScrollValue) document.body.style.overflow = ""
  }

  isHidden(element) {
    return this.classValue ? element.classList.contains(this.classValue) : element.hidden
  }

  setHidden(element, hidden) {
    if (this.classValue) element.classList.toggle(this.classValue, hidden)
    else element.hidden = hidden
  }
}
