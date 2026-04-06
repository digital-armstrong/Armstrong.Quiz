import { Controller } from "@hotwired/stimulus"

// Параллакс для декоративных слоёв при прокрутке экранов с scroll-snap
export default class extends Controller {
  static targets = ["scroller", "layer"]

  connect() {
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.onScroll = () => {
      if (this._frame) return
      this._frame = requestAnimationFrame(() => {
        this._frame = null
        this.applyParallax()
      })
    }
    if (!this.reducedMotion) {
      this.scrollerTarget.addEventListener("scroll", this.onScroll, { passive: true })
    }
    this.applyParallax()
  }

  disconnect() {
    if (!this.reducedMotion) {
      this.scrollerTarget.removeEventListener("scroll", this.onScroll)
    }
    if (this._frame) cancelAnimationFrame(this._frame)
  }

  applyParallax() {
    if (this.reducedMotion) return
    const el = this.scrollerTarget
    const scrollTop = el.scrollTop

    this.layerTargets.forEach((layer) => {
      const section = layer.closest("[data-about-section]")
      if (!section) return
      const speedY = Number.parseFloat(layer.dataset.speed ?? "0.25")
      const speedX = Number.parseFloat(layer.dataset.speedX ?? "0")
      const offsetTop = section.offsetTop
      // Смещение слоя относительно «якоря» секции — чем дальше скролл, тем сильнее эффект
      const rel = scrollTop - offsetTop
      const y = rel * speedY
      const x = rel * speedX
      layer.style.transform = `translate3d(${x}px, ${y}px, 0)`
    })
  }
}
