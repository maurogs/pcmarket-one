import { Controller } from "@hotwired/stimulus"

// Shows the seller what the buyer pays and the estimated payout after fees.
export default class extends Controller {
  static targets = ["price", "payout"]
  static values = { feePercent: Number, minFee: Number, currency: String, locale: String }

  connect() { this.update() }

  update() {
    const price = parseFloat((this.priceTarget.value || "0").replace(",", ".")) || 0
    let fee = 0
    if (this.feePercentValue > 0 && price > 0) fee = Math.min(price, Math.max(price * this.feePercentValue / 100, this.minFeeValue / 100))
    const format = new Intl.NumberFormat(this.localeValue, { style: "currency", currency: this.currencyValue })
    this.payoutTarget.textContent = format.format(Math.max(price - fee, 0))
  }
}
