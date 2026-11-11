import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { after: { type: Number, default: 8000 } }

  connect() { this.timer = setTimeout(() => this.close(), this.afterValue) }
  close() { this.element.remove() }
  disconnect() { clearTimeout(this.timer) }
}
