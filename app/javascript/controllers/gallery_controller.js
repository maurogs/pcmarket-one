import { Controller } from "@hotwired/stimulus"

// Scroll-snap gallery with thumbnails, arrows and keyboard support.
export default class extends Controller {
  static targets = ["track", "thumb", "counter"]

  connect() {
    this.index = 0
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) this.select(Number(entry.target.dataset.index), false)
      })
    }, { root: this.trackTarget, threshold: 0.6 })
    this.slides.forEach((slide) => this.observer.observe(slide))
  }

  disconnect() { this.observer?.disconnect() }

  get slides() { return Array.from(this.trackTarget.children) }

  next() { this.go(this.index + 1) }
  previous() { this.go(this.index - 1) }
  show(event) { this.go(Number(event.currentTarget.dataset.index)) }

  keydown(event) {
    if (event.key === "ArrowRight") this.next()
    if (event.key === "ArrowLeft") this.previous()
  }

  go(index) {
    const count = this.slides.length
    const target = (index + count) % count
    this.slides[target]?.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "start" })
    this.select(target, true)
  }

  select(index) {
    this.index = index
    this.thumbTargets.forEach((thumb, i) => thumb.setAttribute("aria-current", i === index ? "true" : "false"))
    if (this.hasCounterTarget) this.counterTarget.textContent = `${index + 1} / ${this.slides.length}`
  }
}
