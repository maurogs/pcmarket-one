import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, title: String, copied: String }

  async share() {
    if (navigator.share) {
      try { await navigator.share({ title: this.titleValue, url: this.urlValue }) } catch (e) {}
      return
    }
    await navigator.clipboard?.writeText(this.urlValue)
    const original = this.element.innerHTML
    this.element.textContent = this.copiedValue
    setTimeout(() => { this.element.innerHTML = original }, 1800)
  }
}
