import { Controller } from "@hotwired/stimulus"

const SLIDE_MS = 500
const HOLD_MS = 5000

export default class extends Controller {
  static targets = ["track", "image"]
  static values = {
    images: Array,
    interval: { type: Number, default: 5000 }
  }

  connect() {
    this.index = 0
    this.currentPanel = 0
    this.holdTimeout = null
    this.advanceTimeout = null
    if (!this.hasTrackTarget || !this.hasImageTarget || !this.hasImagesValue || this.imagesValue.length === 0) return

    const imgs = this.imageTargets
    if (imgs.length < 2) return

    imgs[0].src = this.imagesValue[0]
    imgs[1].src = this.imagesValue[1 % this.imagesValue.length]
    this.updateTrack(0)

    this.boundOnTransitionEnd = this.onTransitionEnd.bind(this)
    this.trackTarget.addEventListener("transitionend", this.boundOnTransitionEnd)

    this.scheduleAdvance()
  }

  disconnect() {
    this.stop()
    if (this.holdTimeout) clearTimeout(this.holdTimeout)
    if (this.advanceTimeout) clearTimeout(this.advanceTimeout)
    if (this.trackTarget) this.trackTarget.removeEventListener("transitionend", this.boundOnTransitionEnd)
  }

  scheduleAdvance() {
    this.advanceTimeout = setTimeout(() => this.advance(), this.intervalValue)
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
    if (this.holdTimeout) {
      clearTimeout(this.holdTimeout)
      this.holdTimeout = null
    }
    if (this.advanceTimeout) {
      clearTimeout(this.advanceTimeout)
      this.advanceTimeout = null
    }
  }

  advance() {
    const count = this.imagesValue.length
    if (count < 2) return

    this.advanceTimeout = null
    const nextIndex = (this.index + 1) % count
    const nextPanel = 1 - this.currentPanel

    this.trackTarget.style.transition = `transform ${SLIDE_MS}ms ease-out`
    this.imageTargets[nextPanel].src = this.imagesValue[nextIndex]
    this.updateTrack(-50)
    this.nextIndex = nextIndex
  }

  onTransitionEnd() {
    if (this.nextIndex == null) return

    this.holdTimeout = setTimeout(() => {
      this.holdTimeout = null
      this.index = this.nextIndex
      this.nextIndex = null

      this.trackTarget.style.transition = "none"
      this.updateTrack(0)

      const imgs = this.imageTargets
      const count = this.imagesValue.length
      this.currentPanel = 0
      imgs[0].src = this.imagesValue[this.index]
      imgs[1].src = this.imagesValue[(this.index + 1) % count]

      requestAnimationFrame(() => {
        this.trackTarget.style.transition = `transform ${SLIDE_MS}ms ease-out`
      })

      this.scheduleAdvance()
    }, HOLD_MS)
  }

  updateTrack(percent) {
    this.trackTarget.style.transform = `translateX(${percent}%)`
  }
}

