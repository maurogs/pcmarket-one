import { Controller } from "@hotwired/stimulus"

// Keeps the thread scrolled to the newest message, styles the viewer's own
// messages (broadcast HTML is identical for both participants) and resets the composer.
export default class extends Controller {
  static targets = ["messages", "input", "form"]
  static values = { userId: Number }

  connect() {
    this.decorate()
    this.observer = new MutationObserver(() => this.decorate())
    this.observer.observe(this.messagesTarget, { childList: true })
  }

  disconnect() { this.observer?.disconnect() }

  decorate() {
    this.messagesTarget.querySelectorAll("[data-sender-id]").forEach((element) => {
      element.dataset.own = String(Number(element.dataset.senderId) === this.userIdValue)
    })
    this.messagesTarget.querySelectorAll("[data-visible-to]").forEach((element) => {
      element.hidden = Number(element.dataset.visibleTo) !== this.userIdValue
    })
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  reset(event) {
    if (event.detail.success) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey && !event.isComposing) {
      event.preventDefault()
      if (this.inputTarget.value.trim()) this.formTarget.requestSubmit()
    }
  }
}
