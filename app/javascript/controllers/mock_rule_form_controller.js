import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "statusInput", "statusHint",
    "priorityInput",
    "rateLimitType", "rateLimitHeaderField", "rateLimitHeaderInput",
    "hintIp", "hintApikey", "hintBoth", "hintHeaderName",
    "headersContainer", "headersJsonInput", "emptyState"
  ]

  static values = {
    headers: Object
  }

  STATUS_LABELS = {
    200: "OK", 201: "Created", 202: "Accepted", 204: "No Content", 206: "Partial Content",
    301: "Moved Permanently", 302: "Found", 304: "Not Modified",
    400: "Bad Request", 401: "Unauthorized", 403: "Forbidden", 404: "Not Found",
    405: "Method Not Allowed", 408: "Request Timeout", 409: "Conflict", 410: "Gone",
    422: "Unprocessable Entity", 429: "Too Many Requests",
    500: "Internal Server Error", 502: "Bad Gateway", 503: "Service Unavailable", 504: "Gateway Timeout"
  }

  STATUS_COLORS = { 2: "#4ade80", 3: "#93c5fd", 4: "#fbbf24", 5: "#f87171" }

  connect() {
    // Initial setup
    if (this.hasStatusInputTarget) {
      this.updateStatusHint()
    }
    if (this.hasRateLimitTypeTarget) {
      this.toggleRateLimitHint()
    }
    
    // Load initial headers
    if (this.hasHeadersContainerTarget) {
      this.loadInitialHeaders()
    }
  }

  /* ── Status Code Hint ── */
  updateStatusHint() {
    if (!this.hasStatusHintTarget) return
    
    const val = this.statusInputTarget.value
    const code = parseInt(val, 10)
    
    if (!code || code < 100 || code > 599) {
      this.statusHintTarget.innerHTML = ""
      return
    }
    
    const tier = Math.floor(code / 100)
    const color = this.STATUS_COLORS[tier] || "var(--mp-faint)"
    const label = this.STATUS_LABELS[code] || `${tier}xx`
    
    this.statusHintTarget.innerHTML =
      `<span style="color:${color};font-weight:600;">${code}</span>` +
      `<span style="color:var(--mp-faint);"> – ${label}</span>`
  }

  /* ── Priority Stepper ── */
  stepPriority(event) {
    event.preventDefault()
    const delta = parseInt(event.params.delta || "0", 10)
    if (this.hasPriorityInputTarget) {
      const currentVal = parseInt(this.priorityInputTarget.value || "0", 10)
      this.priorityInputTarget.value = Math.max(0, currentVal + delta)
    }
  }

  /* ── Rate Limit Hint + Toggles ── */
  toggleRateLimitHint() {
    const val = this.rateLimitTypeTarget.value
    
    if (this.hasHintIpTarget) this.hintIpTarget.style.display = (!val || val === "ip") ? "block" : "none"
    if (this.hasHintApikeyTarget) this.hintApikeyTarget.style.display = val === "api_key" ? "block" : "none"
    if (this.hasHintBothTarget) this.hintBothTarget.style.display = val === "both" ? "block" : "none"

    const needsHeader = val === "api_key" || val === "both"
    if (this.hasRateLimitHeaderFieldTarget) {
      this.rateLimitHeaderFieldTarget.style.display = needsHeader ? "block" : "none"
    }
    if (this.hasRateLimitHeaderInputTarget) {
      this.rateLimitHeaderInputTarget.required = needsHeader
      if (!needsHeader) this.rateLimitHeaderInputTarget.value = ""
    }
    
    this.updateHeaderHints()
  }

  updateHeaderHints() {
    if (!this.hasRateLimitHeaderInputTarget) return
    const val = this.rateLimitHeaderInputTarget.value.trim() || "…"
    this.hintHeaderNameTargets.forEach(el => el.textContent = val)
  }

  /* ── Response Headers Management ── */
  loadInitialHeaders() {
    // Clear container
    this.headersContainerTarget.innerHTML = ""
    
    const headers = this.headersValue
    if (headers && typeof headers === 'object') {
      Object.entries(headers).forEach(([key, value]) => {
        this.addHeaderRow(key, value, true)
      })
    }
    this.toggleEmptyState()
  }

  addHeader(event) {
    event.preventDefault()
    this.addHeaderRow("", "", true)
    this.toggleEmptyState()
    this.syncHeaders()
  }

  removeHeader(event) {
    event.preventDefault()
    const btn = event.currentTarget
    const row = btn.closest("[data-row-id]")
    if (row) {
      row.remove()
      this.toggleEmptyState()
      this.syncHeaders()
    }
  }

  addHeaderRow(key = "", value = "", enabled = true) {
    const id = "mrfrow_" + Date.now() + "_" + Math.floor(Math.random() * 1000)
    const row = document.createElement("div")
    row.dataset.rowId = id
    row.style.cssText = "display:grid;grid-template-columns:18px 1fr 1fr 32px;gap:8px;align-items:center;"
    
    row.innerHTML = `
      <input type="checkbox" class="mrf-h-enabled" ${enabled ? "checked" : ""}
             data-action="change->mock-rule-form#syncHeaders"
             style="width:13px;height:13px;accent-color:#8b5cf6;cursor:pointer;flex-shrink:0;">
      <input type="text" class="mrf-h-key" placeholder="Header-Name" value="${this.mrfEsc(key)}"
             data-action="input->mock-rule-form#syncHeaders"
             style="background:#17172a;border:1px solid #2a2a40;border-radius:6px;padding:5px 9px;font-size:11px;font-family:Menlo,Consolas,monospace;color:#f5f5fa;outline:none;width:100%;box-sizing:border-box;transition:border-color .15s,box-shadow .15s;"
             onfocus="this.style.borderColor='#8b5cf6';this.style.boxShadow='0 0 0 3px rgba(139,92,246,.15)';"
             onblur="this.style.borderColor='#2a2a40';this.style.boxShadow='none';">
      <input type="text" class="mrf-h-value" placeholder="value" value="${this.mrfEsc(value)}"
             data-action="input->mock-rule-form#syncHeaders"
             style="background:#17172a;border:1px solid #2a2a40;border-radius:6px;padding:5px 9px;font-size:11px;font-family:Menlo,Consolas,monospace;color:#f5f5fa;outline:none;width:100%;box-sizing:border-box;transition:border-color .15s,box-shadow .15s;"
             onfocus="this.style.borderColor='#8b5cf6';this.style.boxShadow='0 0 0 3px rgba(139,92,246,.15)';"
             onblur="this.style.borderColor='#2a2a40';this.style.boxShadow='none';">
      <button type="button" data-action="click->mock-rule-form#removeHeader" title="Remove"
              style="background:none;border:none;padding:4px;cursor:pointer;color:#55556a;line-height:1;border-radius:4px;display:flex;align-items:center;justify-content:center;width:28px;height:28px;transition:color .15s,background .15s;"
              onmouseover="this.style.color='#f87171';this.style.background='rgba(248,113,113,.1)';"
              onmouseout="this.style.color='#55556a';this.style.background='none';">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/></svg>
      </button>`
      
    this.headersContainerTarget.appendChild(row)
  }

  syncHeaders() {
    if (!this.hasHeadersContainerTarget || !this.hasHeadersJsonInputTarget) return
    
    const rows = this.headersContainerTarget.querySelectorAll("[data-row-id]")
    const result = {}
    
    rows.forEach(row => {
      const enabled = row.querySelector(".mrf-h-enabled").checked
      const key = row.querySelector(".mrf-h-key").value.trim()
      const value = row.querySelector(".mrf-h-value").value.trim()
      if (enabled && key) result[key] = value
    })
    
    this.headersJsonInputTarget.value = JSON.stringify(result)
  }

  toggleEmptyState() {
    if (!this.hasHeadersContainerTarget || !this.hasEmptyStateTarget) return
    const count = this.headersContainerTarget.querySelectorAll("[data-row-id]").length
    this.emptyStateTarget.style.display = count === 0 ? "block" : "none"
  }

  mrfEsc(str) {
    return String(str || "")
      .replace(/&/g, "&amp;").replace(/"/g, "&quot;")
      .replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }

  setHeaderPreset(key, value) {
    if (!this.hasHeadersContainerTarget) return
    
    const rows = this.headersContainerTarget.querySelectorAll("[data-row-id]")
    for (const row of rows) {
      const kInput = row.querySelector(".mrf-h-key")
      if (kInput && kInput.value.toLowerCase() === key.toLowerCase()) {
        row.querySelector(".mrf-h-value").value = value
        row.querySelector(".mrf-h-enabled").checked = true
        this.syncHeaders()
        return
      }
    }
    
    this.addHeaderRow(key, value, true)
    this.toggleEmptyState()
    this.syncHeaders()
  }
}
