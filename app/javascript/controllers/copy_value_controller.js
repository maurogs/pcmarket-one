import { Controller } from "@hotwired/stimulus"

// Copies the selected template into a target field (e.g. moderation reasons).
export default class extends Controller {
  static targets = ["source", "destination"]

  copy() {
    if (this.sourceTarget.value) this.destinationTarget.value = this.sourceTarget.value
  }
}
