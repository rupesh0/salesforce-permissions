import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { debounce } from "c/utils";
import { exportToCsv } from "c/csvExportUtil";
import searchEntities from "@salesforce/apex/PermissionComparatorController.searchEntities";
import compareEntities from "@salesforce/apex/PermissionComparatorController.compareEntities";
import getPSGList from "@salesforce/apex/PermissionComparatorController.getPSGList";
import getPSGDetail from "@salesforce/apex/PermissionComparatorController.getPSGDetail";

export default class PermissionComparator extends LightningElement {
  // Main view mode: 'COMPARATOR' | 'PSG_INSPECTOR'
  activeMode = "COMPARATOR";

  // --- Entity Comparator State ---
  leftType = "PROFILE";
  leftSearchTerm = "";
  @track leftOptions = [];
  leftSelected = null;
  showLeftDropdown = false;
  isLeftLoading = false;

  rightType = "PERMISSION_SET";
  rightSearchTerm = "";
  @track rightOptions = [];
  rightSelected = null;
  showRightDropdown = false;
  isRightLoading = false;

  // Comparison controls
  activeCategory = "OBJECT";
  activeDiffFilter = "DIFF"; // Default to differences
  rowSearchTerm = "";

  isLoadingComparison = false;
  @track comparisonResult = null;

  // --- PSG Inspector State ---
  @track psgList = [];
  selectedPSGId = "";
  @track psgDetail = null;
  isPSGLoading = false;
  psgSearchTerm = "";

  connectedCallback() {
    this.fetchInitialEntities();
    this.loadPSGList();
  }

  // --- Initial Data Load ---

  async fetchInitialEntities() {
    try {
      const [leftRes, rightRes] = await Promise.all([
        searchEntities({ entityType: this.leftType, searchTerm: "" }),
        searchEntities({ entityType: this.rightType, searchTerm: "" })
      ]);
      this.leftOptions = leftRes || [];
      this.rightOptions = rightRes || [];

      // Auto-select defaults for immediate convenience
      if (this.leftOptions.length > 0 && !this.leftSelected) {
        // Look for Standard User or first
        const stdProf = this.leftOptions.find(
          (o) => o.name === "Standard User"
        );
        this.leftSelected = stdProf || this.leftOptions[0];
      }
      if (this.rightOptions.length > 0 && !this.rightSelected) {
        this.rightSelected = this.rightOptions[0];
      }

      if (this.leftSelected && this.rightSelected) {
        this.runComparison();
      }
    } catch {
      // Ignore initial errors
    }
  }

  async loadPSGList() {
    try {
      const psgs = await getPSGList();
      this.psgList = (psgs || []).map((p) => ({
        label: `${p.masterLabel} (${p.bundledCount} sets)`,
        value: p.id,
        ...p
      }));
      if (this.psgList.length > 0 && !this.selectedPSGId) {
        this.selectedPSGId = this.psgList[0].id;
        this.loadPSGDetail();
      }
    } catch {
      // Ignore
    }
  }

  // --- Mode Switching ---

  handleSwitchMode(event) {
    this.activeMode = event.currentTarget.dataset.mode;
    if (
      this.activeMode === "PSG_INSPECTOR" &&
      this.selectedPSGId &&
      !this.psgDetail
    ) {
      this.loadPSGDetail();
    }
  }

  get isComparatorMode() {
    return this.activeMode === "COMPARATOR";
  }

  get isPSGMode() {
    return this.activeMode === "PSG_INSPECTOR";
  }

  get comparatorModeClass() {
    return `mode-pill ${this.activeMode === "COMPARATOR" ? "active" : ""}`;
  }

  get psgModeClass() {
    return `mode-pill ${this.activeMode === "PSG_INSPECTOR" ? "active" : ""}`;
  }

  // --- Left Entity Handlers ---

  handleLeftTypeSelect(event) {
    this.leftType = event.currentTarget.dataset.type;
    this.leftSelected = null;
    this.leftSearchTerm = "";
    this.searchLeftEntities("");
  }

  handleLeftSearchInput(event) {
    const term = event.target.value;
    this.leftSearchTerm = term;
    this.showLeftDropdown = true;
    this.debounceLeftSearch(term);
  }

  debounceLeftSearch = debounce((term) => {
    this.searchLeftEntities(term);
  }, 300);

  async searchLeftEntities(term) {
    this.isLeftLoading = true;
    try {
      this.leftOptions = await searchEntities({
        entityType: this.leftType,
        searchTerm: term
      });
    } catch {
      this.leftOptions = [];
    } finally {
      this.isLeftLoading = false;
    }
  }

  handleLeftFocus() {
    this.showLeftDropdown = true;
  }

  handleLeftBlur() {
    debounce(() => {
      this.showLeftDropdown = false;
    }, 200)();
  }

  handleLeftSelect(event) {
    const id = event.currentTarget.dataset.id;
    this.leftSelected = this.leftOptions.find((o) => o.id === id);
    this.showLeftDropdown = false;
    this.runComparison();
  }

  handleLeftClear() {
    this.leftSelected = null;
    this.leftSearchTerm = "";
    this.comparisonResult = null;
    this.searchLeftEntities("");
  }

  // --- Right Entity Handlers ---

  handleRightTypeSelect(event) {
    this.rightType = event.currentTarget.dataset.type;
    this.rightSelected = null;
    this.rightSearchTerm = "";
    this.searchRightEntities("");
  }

  handleRightSearchInput(event) {
    const term = event.target.value;
    this.rightSearchTerm = term;
    this.showRightDropdown = true;
    this.debounceRightSearch(term);
  }

  debounceRightSearch = debounce((term) => {
    this.searchRightEntities(term);
  }, 300);

  async searchRightEntities(term) {
    this.isRightLoading = true;
    try {
      this.rightOptions = await searchEntities({
        entityType: this.rightType,
        searchTerm: term
      });
    } catch {
      this.rightOptions = [];
    } finally {
      this.isRightLoading = false;
    }
  }

  handleRightFocus() {
    this.showRightDropdown = true;
  }

  handleRightBlur() {
    debounce(() => {
      this.showRightDropdown = false;
    }, 200)();
  }

  handleRightSelect(event) {
    const id = event.currentTarget.dataset.id;
    this.rightSelected = this.rightOptions.find((o) => o.id === id);
    this.showRightDropdown = false;
    this.runComparison();
  }

  handleRightClear() {
    this.rightSelected = null;
    this.rightSearchTerm = "";
    this.comparisonResult = null;
    this.searchRightEntities("");
  }

  handleSwapEntities() {
    const tempType = this.leftType;
    const tempSelected = this.leftSelected;
    this.leftType = this.rightType;
    this.leftSelected = this.rightSelected;
    this.rightType = tempType;
    this.rightSelected = tempSelected;
    this.runComparison();
  }

  // --- Comparison Execution ---

  async runComparison() {
    if (!this.leftSelected || !this.rightSelected) return;

    this.isLoadingComparison = true;
    try {
      const data = await compareEntities({
        leftType: this.leftSelected.entityType,
        leftId: this.leftSelected.id,
        rightType: this.rightSelected.entityType,
        rightId: this.rightSelected.id,
        category: this.activeCategory
      });
      this.comparisonResult = data;
    } catch (error) {
      this.showToast(
        "Comparison Error",
        error.body ? error.body.message : error.message,
        "error"
      );
      this.comparisonResult = null;
    } finally {
      this.isLoadingComparison = false;
    }
  }

  handleCategorySelect(event) {
    this.activeCategory = event.currentTarget.dataset.category;
    this.rowSearchTerm = "";
    this.runComparison();
  }

  handleDiffFilterSelect(event) {
    this.activeDiffFilter = event.currentTarget.dataset.filter;
  }

  handleRowSearchChange(event) {
    this.rowSearchTerm = event.target.value.toLowerCase();
  }

  // --- Getters for Filters & Rows ---

  get filteredComparisonRows() {
    if (!this.comparisonResult || !this.comparisonResult.rows) return [];
    return this.comparisonResult.rows
      .filter((row) => {
        // Diff filter
        if (this.activeDiffFilter === "DIFF") {
          if (row.diffStatus === "IDENTICAL") return false;
        } else if (this.activeDiffFilter === "LEFT_ONLY") {
          if (row.diffStatus !== "LEFT_ONLY") return false;
        } else if (this.activeDiffFilter === "RIGHT_ONLY") {
          if (row.diffStatus !== "RIGHT_ONLY") return false;
        } else if (this.activeDiffFilter === "IDENTICAL") {
          if (row.diffStatus !== "IDENTICAL") return false;
        }

        // Text search filter
        if (this.rowSearchTerm) {
          return (
            row.itemLabel.toLowerCase().includes(this.rowSearchTerm) ||
            row.itemKey.toLowerCase().includes(this.rowSearchTerm) ||
            row.leftAccess.toLowerCase().includes(this.rowSearchTerm) ||
            row.rightAccess.toLowerCase().includes(this.rowSearchTerm)
          );
        }
        return true;
      })
      .map((row) => ({
        ...row,
        badgeClass: `diff-badge ${row.diffStatus.toLowerCase()}`,
        badgeLabel: this.getDiffLabel(row.diffStatus)
      }));
  }

  getDiffLabel(status) {
    if (status === "IDENTICAL") return "Identical";
    if (status === "DIFFERENT") return "Different";
    if (status === "LEFT_ONLY") return "Left Only";
    if (status === "RIGHT_ONLY") return "Right Only";
    return status;
  }

  get totalComparedCount() {
    return this.comparisonResult ? this.comparisonResult.totalItems : 0;
  }

  get diffCount() {
    return this.comparisonResult ? this.comparisonResult.differentCount : 0;
  }

  get leftOnlyCount() {
    return this.comparisonResult ? this.comparisonResult.leftOnlyCount : 0;
  }

  get rightOnlyCount() {
    return this.comparisonResult ? this.comparisonResult.rightOnlyCount : 0;
  }

  get identicalCount() {
    return this.comparisonResult ? this.comparisonResult.identicalCount : 0;
  }

  // Category pill active states
  get isObjectCategory() {
    return this.activeCategory === "OBJECT";
  }
  get isFieldCategory() {
    return this.activeCategory === "FIELD";
  }
  get isSystemCategory() {
    return this.activeCategory === "SYSTEM";
  }
  get isApexCategory() {
    return this.activeCategory === "APEX";
  }
  get isFlowCategory() {
    return this.activeCategory === "FLOW";
  }

  get objectCategoryClass() {
    return `filter-pill ${this.isObjectCategory ? "active" : ""}`;
  }
  get fieldCategoryClass() {
    return `filter-pill ${this.isFieldCategory ? "active" : ""}`;
  }
  get systemCategoryClass() {
    return `filter-pill ${this.isSystemCategory ? "active" : ""}`;
  }
  get apexCategoryClass() {
    return `filter-pill ${this.isApexCategory ? "active" : ""}`;
  }
  get flowCategoryClass() {
    return `filter-pill ${this.isFlowCategory ? "active" : ""}`;
  }

  // Diff pill active states
  get allDiffClass() {
    return `filter-pill ${this.activeDiffFilter === "ALL" ? "active" : ""}`;
  }
  get diffOnlyClass() {
    return `filter-pill diff-pill ${this.activeDiffFilter === "DIFF" ? "active" : ""}`;
  }
  get leftOnlyClass() {
    return `filter-pill ${this.activeDiffFilter === "LEFT_ONLY" ? "active" : ""}`;
  }
  get rightOnlyClass() {
    return `filter-pill ${this.activeDiffFilter === "RIGHT_ONLY" ? "active" : ""}`;
  }
  get identicalDiffClass() {
    return `filter-pill ${this.activeDiffFilter === "IDENTICAL" ? "active" : ""}`;
  }

  // Left entity type pill classes
  get isLeftProfile() {
    return this.leftType === "PROFILE";
  }
  get isLeftPS() {
    return this.leftType === "PERMISSION_SET";
  }
  get isLeftPSG() {
    return this.leftType === "PERMISSION_SET_GROUP";
  }
  get leftProfilePillClass() {
    return `entity-type-pill ${this.isLeftProfile ? "active" : ""}`;
  }
  get leftPSPillClass() {
    return `entity-type-pill ${this.isLeftPS ? "active" : ""}`;
  }
  get leftPSGPillClass() {
    return `entity-type-pill ${this.isLeftPSG ? "active" : ""}`;
  }

  // Right entity type pill classes
  get isRightProfile() {
    return this.rightType === "PROFILE";
  }
  get isRightPS() {
    return this.rightType === "PERMISSION_SET";
  }
  get isRightPSG() {
    return this.rightType === "PERMISSION_SET_GROUP";
  }
  get rightProfilePillClass() {
    return `entity-type-pill ${this.isRightProfile ? "active" : ""}`;
  }
  get rightPSPillClass() {
    return `entity-type-pill ${this.isRightPS ? "active" : ""}`;
  }
  get rightPSGPillClass() {
    return `entity-type-pill ${this.isRightPSG ? "active" : ""}`;
  }

  get leftTagClass() {
    return `entity-tag ${this.leftSelected ? this.leftSelected.entityType.toLowerCase() : ""}`;
  }
  get rightTagClass() {
    return `entity-tag ${this.rightSelected ? this.rightSelected.entityType.toLowerCase() : ""}`;
  }

  // --- PSG Inspector Handlers ---

  handlePSGChange(event) {
    this.selectedPSGId = event.detail.value;
    this.loadPSGDetail();
  }

  async loadPSGDetail() {
    if (!this.selectedPSGId) return;
    this.isPSGLoading = true;
    try {
      this.psgDetail = await getPSGDetail({ psgId: this.selectedPSGId });
    } catch (error) {
      this.showToast(
        "Error loading PSG",
        error.body ? error.body.message : error.message,
        "error"
      );
      this.psgDetail = null;
    } finally {
      this.isPSGLoading = false;
    }
  }

  handlePSGSearchChange(event) {
    this.psgSearchTerm = event.target.value.toLowerCase();
  }

  get filteredMutingImpactRows() {
    if (!this.psgDetail || !this.psgDetail.mutingImpactRows) return [];
    return this.psgDetail.mutingImpactRows
      .filter((row) => {
        if (!this.psgSearchTerm) return true;
        return (
          row.objectName.toLowerCase().includes(this.psgSearchTerm) ||
          row.bundledSources.toLowerCase().includes(this.psgSearchTerm) ||
          row.bundledAccess.toLowerCase().includes(this.psgSearchTerm) ||
          row.effectiveAccess.toLowerCase().includes(this.psgSearchTerm)
        );
      })
      .map((row) => ({
        ...row,
        badgeClass: `muting-badge ${row.isMuted ? "muted" : "active"}`,
        badgeLabel: row.isMuted ? "MUTED" : "ACTIVE"
      }));
  }

  // --- CSV Export Handler ---

  handleExportCsv() {
    const dateStr = new Date().toISOString().slice(0, 10);

    if (this.isComparatorMode) {
      if (!this.comparisonResult || !this.filteredComparisonRows.length) {
        this.showToast(
          "Export Notice",
          "No comparison data to export.",
          "info"
        );
        return;
      }
      const leftName = this.leftSelected ? this.leftSelected.label : "Left";
      const rightName = this.rightSelected ? this.rightSelected.label : "Right";
      const columns = [
        { label: "Item / Permission", fieldName: "itemLabel" },
        { label: "Key / API Name", fieldName: "itemKey" },
        { label: "Category", fieldName: "category" },
        { label: "Diff Status", fieldName: "diffStatus" },
        { label: `${leftName} (Left Access)`, fieldName: "leftAccess" },
        { label: `${rightName} (Right Access)`, fieldName: "rightAccess" }
      ];
      const rows = this.filteredComparisonRows;
      const fileName = `Comparison_${this.activeCategory}_${dateStr}.csv`;
      exportToCsv(columns, rows, fileName);
      this.showToast(
        "Export Successful",
        `Exported ${rows.length} rows to ${fileName}`,
        "success"
      );
    } else {
      if (!this.psgDetail || !this.filteredMutingImpactRows.length) {
        this.showToast("Export Notice", "No PSG data to export.", "info");
        return;
      }
      const columns = [
        { label: "Object Name", fieldName: "objectName" },
        { label: "Bundled Access", fieldName: "bundledAccess" },
        { label: "Contributing Permission Sets", fieldName: "bundledSources" },
        { label: "Muting Status", fieldName: "statusBadge" },
        { label: "Muted Permissions", fieldName: "mutedPermissions" },
        { label: "Effective Access", fieldName: "effectiveAccess" }
      ];
      const rows = this.filteredMutingImpactRows;
      const fileName = `PSGMuting_${this.psgDetail.developerName}_${dateStr}.csv`;
      exportToCsv(columns, rows, fileName);
      this.showToast(
        "Export Successful",
        `Exported ${rows.length} rows to ${fileName}`,
        "success"
      );
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant
      })
    );
  }
}
