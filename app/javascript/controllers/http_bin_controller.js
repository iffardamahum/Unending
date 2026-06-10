import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "endpointUrl", "testRuleSelect" ]

  copyEndpointUrl() {
    if (!this.hasEndpointUrlTarget) return
    const url = this.endpointUrlTarget.textContent.trim()
    this.copyToClipboard(url, "URL copied!")
  }

  copyQuickUrl() {
    let url = ""
    if (this.hasTestRuleSelectTarget && this.testRuleSelectTarget.value) {
      url = this.testRuleSelectTarget.value
    } else if (this.hasEndpointUrlTarget) {
      url = this.endpointUrlTarget.textContent.trim()
    }
    if (url) {
      this.copyToClipboard(url, "URL copied!")
    }
  }

  copyCurl() {
    if (!this.hasEndpointUrlTarget) return
    const url = this.endpointUrlTarget.textContent.trim()
    const curl = `curl -X POST "${url}/your-path" \\\n  -H "Content-Type: application/json" \\\n  -d '{"key": "value"}'`
    this.copyToClipboard(curl, "cURL copied!")
  }

  testSelectedRule() {
    if (this.hasTestRuleSelectTarget && this.testRuleSelectTarget.value) {
      window.open(this.testRuleSelectTarget.value, "_blank")
    }
  }

  copyToClipboard(text, successMsg) {
    navigator.clipboard.writeText(text)
      .then(() => {
        this.showToast(successMsg)
      })
      .catch(err => {
        console.error("Failed to copy: ", err)
      })
  }

  showToast(msg) {
    const t = document.createElement("div")
    t.textContent = msg
    const isDark = document.documentElement.dataset.theme !== "light"
    Object.assign(t.style, {
      position: "fixed", bottom: "1.5rem", right: "1.5rem",
      background: isDark ? "#0f0f18" : "#1a1a2e",
      border: "1px solid " + (isDark ? "#2a2a40" : "#3a3a5a"),
      color: "#f5f5fa", fontSize: "13px", padding: "10px 18px",
      borderRadius: "10px", boxShadow: "0 8px 32px rgba(0,0,0,.6)",
      zIndex: "9999", transition: "opacity .3s"
    })
    document.body.appendChild(t)
    setTimeout(() => { t.style.opacity = "0"; setTimeout(() => t.remove(), 300); }, 2200)
  }
}
