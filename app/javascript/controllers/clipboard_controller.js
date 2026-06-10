import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source" ]
  static values = {
    text: String,
    message: { type: String, default: "Copied!" }
  }

  copy(event) {
    event.preventDefault()
    
    // Determine the text to copy:
    // 1. Value from data-clipboard-text-value
    // 2. Attribute from data-clipboard-text on the clicked element
    // 3. Text content or value from the source target
    let content = ""
    if (this.hasTextValue) {
      content = this.textValue
    } else if (event.currentTarget.dataset.clipboardText) {
      content = event.currentTarget.dataset.clipboardText
    } else if (this.hasSourceTarget) {
      content = this.sourceTarget.value || this.sourceTarget.textContent
    }

    if (!content) return

    navigator.clipboard.writeText(content.trim())
      .then(() => {
        const message = event.currentTarget.dataset.clipboardMessage || this.messageValue
        this.showToast(message)
      })
      .catch((err) => {
        console.error("Failed to copy text: ", err)
      })
  }

  showToast(msg) {
    const t = document.createElement("div")
    t.textContent = msg
    const isDark = document.documentElement.dataset.theme !== "light"
    Object.assign(t.style, {
      position: "fixed",
      bottom: "1.5rem",
      right: "1.5rem",
      background: isDark ? "#0f0f18" : "#1a1a2e",
      border: "1px solid " + (isDark ? "#2a2a40" : "#3a3a5a"),
      color: "#f5f5fa",
      fontSize: "13px",
      padding: "10px 18px",
      borderRadius: "10px",
      boxShadow: "0 8px 32px rgba(0,0,0,.6)",
      zIndex: "9999",
      transition: "opacity .3s"
    })
    document.body.appendChild(t)
    setTimeout(() => {
      t.style.opacity = "0"
      setTimeout(() => t.remove(), 300)
    }, 2200)
  }
}
