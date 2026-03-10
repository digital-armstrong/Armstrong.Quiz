import { Controller } from "@hotwired/stimulus"

// Добавление вариантов ответа через Turbo Stream (fetch + renderStreamMessage)
export default class extends Controller {
  static targets = ["addButton", "container"]
  static values = { url: String }

  add(event) {
    if (event) event.preventDefault()
    const url = this.urlValue
    if (!url || typeof window.Turbo === "undefined") return

    const nextIndex = this.containerTarget.querySelectorAll("[data-option-row]").length
    const streamUrl = url + (url.includes("?") ? "&" : "?") + "index=" + nextIndex

    fetch(streamUrl, {
      method: "GET",
      headers: { "Accept": "text/vnd.turbo-stream.html" },
      credentials: "same-origin"
    })
      .then((res) => {
        if (!res.ok) throw new Error(res.statusText)
        return res.text()
      })
      .then((html) => {
        window.Turbo.renderStreamMessage(html)
      })
      .catch((err) => console.error("Answer options fetch failed:", err))
  }
}
