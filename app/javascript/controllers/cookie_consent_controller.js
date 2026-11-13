import { Controller } from "@hotwired/stimulus"

// Stores consent for 6 months as required by most EU regulators. Only strictly
// necessary cookies are set before consent.
const COOKIE = "cookie_consent"

export default class extends Controller {
  static targets = ["banner", "details", "analytics", "marketing", "customizeButton", "saveButton"]

  connect() {
    if (!this.read()) this.bannerTarget.hidden = false
  }

  reopen() {
    const consent = this.read() || {}
    this.analyticsTarget.checked = !!consent.analytics
    this.marketingTarget.checked = !!consent.marketing
    this.bannerTarget.hidden = false
    this.customize()
  }

  customize() {
    this.detailsTarget.hidden = false
    this.customizeButtonTarget.hidden = true
    this.saveButtonTarget.hidden = false
  }

  acceptAll() { this.store({ analytics: true, marketing: true }) }
  rejectAll() { this.store({ analytics: false, marketing: false }) }
  save() { this.store({ analytics: this.analyticsTarget.checked, marketing: this.marketingTarget.checked }) }

  store(choice) {
    const value = encodeURIComponent(JSON.stringify({ ...choice, necessary: true, at: new Date().toISOString(), v: 1 }))
    document.cookie = `${COOKIE}=${value}; max-age=${60 * 60 * 24 * 180}; path=/; SameSite=Lax${location.protocol === "https:" ? "; Secure" : ""}`
    this.bannerTarget.hidden = true
    this.dispatch("changed", { detail: choice })
  }

  read() {
    const match = document.cookie.split("; ").find((row) => row.startsWith(`${COOKIE}=`))
    try { return match ? JSON.parse(decodeURIComponent(match.split("=")[1])) : null } catch (e) { return null }
  }
}
