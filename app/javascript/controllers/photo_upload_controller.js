import { Controller } from "@hotwired/stimulus"

// Previews selected photos client-side and enforces the max count before upload.
export default class extends Controller {
  static targets = ["input", "previews", "error"]
  static values = { max: Number, existing: Number, tooMany: String, tooLarge: String }

  preview() {
    this.previewsTarget.innerHTML = ""
    this.errorTarget.textContent = ""
    const files = Array.from(this.inputTarget.files)
    if (files.length + this.existingValue > this.maxValue) {
      this.errorTarget.textContent = this.tooManyValue
      this.inputTarget.value = ""
      return
    }
    for (const file of files) {
      if (file.size > 10 * 1024 * 1024) {
        this.errorTarget.textContent = this.tooLargeValue
        this.inputTarget.value = ""
        this.previewsTarget.innerHTML = ""
        return
      }
      const figure = document.createElement("figure")
      figure.className = "aspect-square overflow-hidden rounded-xl border border-ink-200 dark:border-ink-700"
      const image = document.createElement("img")
      image.className = "h-full w-full object-cover"
      image.alt = file.name
      image.src = URL.createObjectURL(file)
      image.onload = () => URL.revokeObjectURL(image.src)
      figure.appendChild(image)
      this.previewsTarget.appendChild(figure)
    }
  }
}
