import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { autoClose: { type: Number, default: 10000 } }

  connect() {
    this.autoCloseMs = this.autoCloseValue
    if (this.autoCloseMs > 0) {
      this.timeoutId = setTimeout(() => this.dismiss(), this.autoCloseMs)
    }
  }

  disconnect() {
    if (this.timeoutId) clearTimeout(this.timeoutId)
  }

  dismiss() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
    this.element.style.opacity = "0"
    this.element.style.transform = "translateX(100%)"
    setTimeout(() => this.element.remove(), 300)
  }
}
