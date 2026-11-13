import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.onScroll = () => { this.buttonTarget.hidden = window.scrollY < 800 }
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()
  }

  disconnect() { window.removeEventListener("scroll", this.onScroll) }
}
