import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "panel", "binBtn" ]

  connect() {
    // Resize bindings
    this.onResize = this.resize.bind(this)
    this.onStopResize = this.stopResize.bind(this)
  }

  /* ── Prevent event from bubbling up to the rule row filter ── */
  stopPropagation(event) {
    event.stopPropagation()
  }

  /* ── Bin Switcher ── */
  selectBin(event) {
    event.preventDefault()
    const binId = event.currentTarget.dataset.binId

    // Toggle active class on bin buttons
    this.binBtnTargets.forEach(btn => {
      btn.classList.toggle("active", btn.dataset.binId === binId)
    })

    // Toggle active class on panels
    this.panelTargets.forEach(panel => {
      panel.classList.toggle("active", panel.dataset.binId === binId)
    })
  }

  /* ── Rule Filter ── */
  filterByRule(event) {
    event.preventDefault()
    const ruleRow = event.currentTarget
    const ruleId = ruleRow.dataset.ruleId
    const label = ruleRow.dataset.ruleLabel

    // Find the enclosing panel
    const panel = ruleRow.closest('[data-dashboard-explorer-target="panel"]')
    if (!panel) return

    const filterBar = panel.querySelector(".db-filter-bar")
    const filterLabel = panel.querySelector('[id^="db-filter-label-"]')

    // Toggle off if same rule clicked again
    if (ruleRow.classList.contains("selected")) {
      this.clearPanelFilter(panel)
      return
    }

    // Highlight selected rule row and unhighlight others
    panel.querySelectorAll(".db-rule-row").forEach(r => r.classList.remove("selected"))
    ruleRow.classList.add("selected")

    // Filter request rows
    let count = 0
    panel.querySelectorAll(".db-req-row").forEach(r => {
      const match = String(r.dataset.matchedRule) === String(ruleId)
      r.classList.toggle("hidden", !match)
      if (match) count++
    })

    // Show filter bar
    if (filterBar) {
      filterBar.classList.add("visible")
    }
    if (filterLabel) {
      filterLabel.textContent = `${count} request${count === 1 ? '' : 's'} matched "${label}"`
    }
  }

  clearFilter(event) {
    event.preventDefault()
    const panel = event.currentTarget.closest('[data-dashboard-explorer-target="panel"]')
    if (panel) {
      this.clearPanelFilter(panel)
    }
  }

  clearPanelFilter(panel) {
    panel.querySelectorAll(".db-rule-row").forEach(r => r.classList.remove("selected"))
    panel.querySelectorAll(".db-req-row").forEach(r => r.classList.remove("hidden"))
    
    const filterBar = panel.querySelector(".db-filter-bar")
    if (filterBar) {
      filterBar.classList.remove("visible")
    }
  }

  /* ── Resizable divider ── */
  initResize(event) {
    event.preventDefault()
    const divider = event.currentTarget
    
    const panel = divider.closest('[data-dashboard-explorer-target="panel"]')
    if (!panel) return

    // Find cols container and left col inside this panel
    const colsEl = panel.querySelector(".db-cols")
    const leftCol = panel.querySelector(".db-col-rules")

    if (!colsEl || !leftCol) return

    this.activeDivider = divider
    this.activeLeftCol = leftCol
    this.activeColsEl = colsEl
    
    this.startX = event.clientX
    this.startWidth = leftCol.offsetWidth

    divider.classList.add("dragging")
    document.body.style.cursor = "col-resize"
    document.body.style.userSelect = "none"

    document.addEventListener("mousemove", this.onResize)
    document.addEventListener("mouseup", this.onStopResize)
  }

  resize(event) {
    if (!this.activeLeftCol || !this.activeColsEl) return
    
    const delta = event.clientX - this.startX
    const maxWidth = this.activeColsEl.offsetWidth - 160
    const newWidth = Math.min(Math.max(this.startWidth + delta, 120), maxWidth)
    
    this.activeLeftCol.style.width = newWidth + "px"
    this.activeLeftCol.style.flex = "none"
  }

  stopResize() {
    if (this.activeDivider) {
      this.activeDivider.classList.remove("dragging")
    }
    
    document.body.style.cursor = ""
    document.body.style.userSelect = ""
    
    document.removeEventListener("mousemove", this.onResize)
    document.removeEventListener("mouseup", this.onStopResize)
    
    this.activeDivider = null
    this.activeLeftCol = null
    this.activeColsEl = null
  }
}
