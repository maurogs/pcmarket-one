import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values = { max: Number }

  connect() { this.update() }

  update() {
    const length = this.inputTarget.value.length
    this.counterTarget.textContent = `${length} / ${this.maxValue}`
    this.counterTarget.classList.toggle("text-red-600", length > this.maxValue)
  }
}
