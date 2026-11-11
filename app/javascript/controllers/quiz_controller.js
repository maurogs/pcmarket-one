import { Controller } from "@hotwired/stimulus"

// PC Finder: one question at a time, results are a normal GET form submit.
export default class extends Controller {
  static targets = ["step", "next", "submit", "progress", "back"]
  static values = { maxGames: { type: Number, default: 3 } }

  connect() {
    this.current = 0
    this.render()
  }

  next() {
    if (this.current < this.stepTargets.length - 1) {
      this.current += 1
      this.render()
    }
  }

  back() {
    if (this.current > 0) {
      this.current -= 1
      this.render()
    }
  }

  limitGames(event) {
    const checked = this.element.querySelectorAll("input[name='games[]']:checked")
    if (checked.length > this.maxGamesValue) event.target.checked = false
  }

  render() {
    const last = this.current === this.stepTargets.length - 1
    this.stepTargets.forEach((step, index) => { step.hidden = index !== this.current })
    this.nextTarget.hidden = last
    this.submitTarget.hidden = !last
    this.backTarget.hidden = this.current === 0
    this.progressTarget.style.width = `${((this.current + 1) / this.stepTargets.length) * 100}%`
  }
}
