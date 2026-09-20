import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSearchableSObjects from "@salesforce/apex/WhoHasAccessController.getSearchableSObjects";
import getObjectFields from "@salesforce/apex/WhoHasAccessController.getObjectFields";
import searchApexClasses from "@salesforce/apex/WhoHasAccessController.searchApexClasses";
import searchFlows from "@salesforce/apex/WhoHasAccessController.searchFlows";
import getSystemPermissionsList from "@salesforce/apex/WhoHasAccessController.getSystemPermissionsList";
import getUsersWithAccess from "@salesforce/apex/WhoHasAccessController.getUsersWithAccess";
import { exportToCsv } from "c/csvExportUtil";
import { reduceErrors } from "c/utils";

export default class WhoHasAccess extends LightningElement {
  // Category navigation: OBJECT | FIELD | SYSTEM | APEX | FLOW
  activeCategory = "OBJECT";

  // Data Options
  @track sObjectOptions = [];
  @track fieldOptions = [];
  @track systemPermOptions = [];

  // Selections
  selectedSObject = "Account";
  selectedAccessType = "Read";

  selectedFieldSObject = "Account";
  selectedField = "";
  selectedFieldAccessType = "Read";

  selectedSystemPerm = "PermissionsModifyAllData";

  apexSearchTerm = "";
  @track apexSearchResults = [];
  selectedApexClass = "";
  showApexDropdown = false;

  flowSearchTerm = "";
  @track flowSearchResults = [];
  selectedFlow = "";
  showFlowDropdown = false;

  activeUsersOnly = true;

  // Results & Table State
  isLoading = false;
  hasEvaluated = false;
  @track auditResults = null;
  @track allUsers = [];
  userFilterTerm = "";

  // Debounce timers
  apexSearchTimer;
  flowSearchTimer;

  connectedCallback() {
    this.initData();
  }

  async initData() {
    try {
      const [sObjects, sysPerms] = await Promise.all([
        getSearchableSObjects(),
        getSystemPermissionsList()
      ]);
      this.sObjectOptions = sObjects || [];
      this.systemPermOptions = sysPerms || [];

      // Load initial fields for default object
      this.loadFieldsForObject(this.selectedFieldSObject);
      this.loadInitialApexClasses();
      this.loadInitialFlows();
    } catch (err) {
      this.showToast("Initialization Error", reduceErrors(err).join(", "), "error");
    }
  }

  async loadFieldsForObject(sObjName) {
    if (!sObjName) return;
    try {
      const fields = await getObjectFields({ sObjectName: sObjName });
      this.fieldOptions = fields || [];
      if (this.fieldOptions.length > 0) {
        this.selectedField = this.fieldOptions[0].value;
      } else {
        this.selectedField = "";
      }
    } catch (err) {
      this.fieldOptions = [];
      this.selectedField = "";
    }
  }

  async loadInitialApexClasses() {
    try {
      const classes = await searchApexClasses({ searchTerm: "" });
      this.apexSearchResults = classes || [];
      if (this.apexSearchResults.length > 0) {
        this.selectedApexClass = this.apexSearchResults[0].value;
        this.apexSearchTerm = this.apexSearchResults[0].value;
      }
    } catch {
      this.apexSearchResults = [];
    }
  }

  async loadInitialFlows() {
    try {
      const flows = await searchFlows({ searchTerm: "" });
      this.flowSearchResults = flows || [];
      if (this.flowSearchResults.length > 0) {
        this.selectedFlow = this.flowSearchResults[0].value;
        this.flowSearchTerm = this.flowSearchResults[0].value;
      }
    } catch {
      this.flowSearchResults = [];
    }
  }

  // --- Getters ---

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

  get objectPillClass() {
    return `category-pill ${this.isObjectCategory ? "active" : ""}`;
  }

  get fieldPillClass() {
    return `category-pill ${this.isFieldCategory ? "active" : ""}`;
  }

  get systemPillClass() {
    return `category-pill ${this.isSystemCategory ? "active" : ""}`;
  }

  get apexPillClass() {
    return `category-pill ${this.isApexCategory ? "active" : ""}`;
  }

  get flowPillClass() {
    return `category-pill ${this.isFlowCategory ? "active" : ""}`;
  }

  get objectAccessOptions() {
    return [
      { label: "Read", value: "Read" },
      { label: "Create", value: "Create" },
      { label: "Edit", value: "Edit" },
      { label: "Delete", value: "Delete" },
      { label: "View All", value: "ViewAll" },
      { label: "Modify All", value: "ModifyAll" }
    ];
  }

  get fieldAccessOptions() {
    return [
      { label: "Read Only", value: "Read" },
      { label: "Edit (Read/Write)", value: "Edit" }
    ];
  }

  get displayedUsers() {
    if (!this.allUsers) return [];
    if (!this.userFilterTerm) return this.allUsers;
    const term = this.userFilterTerm.toLowerCase();
    return this.allUsers.filter((u) => {
      return (
        (u.name && u.name.toLowerCase().includes(term)) ||
        (u.username && u.username.toLowerCase().includes(term)) ||
        (u.profileName && u.profileName.toLowerCase().includes(term)) ||
        (u.department && u.department.toLowerCase().includes(term)) ||
        (u.primarySource && u.primarySource.toLowerCase().includes(term))
      );
    });
  }

  get hasResults() {
    return this.hasEvaluated && this.auditResults && this.displayedUsers.length > 0;
  }

  get isExportDisabled() {
    return !this.hasResults;
  }

  get hasNoResults() {
    return this.hasEvaluated && (!this.displayedUsers || this.displayedUsers.length === 0);
  }

  get displayedUsersCount() {
    return this.displayedUsers.length;
  }

  // --- Event Handlers: Category Selection ---

  handleSelectCategory(event) {
    const cat = event.currentTarget.dataset.category;
    if (cat) {
      this.activeCategory = cat;
    }
  }

  // --- Event Handlers: Form Inputs ---

  handleObjectChange(event) {
    this.selectedSObject = event.detail.value;
  }

  handleAccessTypeChange(event) {
    this.selectedAccessType = event.detail.value;
  }

  handleFieldObjectChange(event) {
    this.selectedFieldSObject = event.detail.value;
    this.loadFieldsForObject(this.selectedFieldSObject);
  }

  handleFieldChange(event) {
    this.selectedField = event.detail.value;
  }

  handleFieldAccessTypeChange(event) {
    this.selectedFieldAccessType = event.detail.value;
  }

  handleSystemPermChange(event) {
    this.selectedSystemPerm = event.detail.value;
  }

  handleApexSearchInput(event) {
    const term = event.target.value;
    this.apexSearchTerm = term;
    this.showApexDropdown = true;
    clearTimeout(this.apexSearchTimer);
    this.apexSearchTimer = setTimeout(async () => {
      try {
        const classes = await searchApexClasses({ searchTerm: term });
        this.apexSearchResults = classes || [];
      } catch {
        this.apexSearchResults = [];
      }
    }, 300);
  }

  handleSelectApexClass(event) {
    const className = event.currentTarget.dataset.name;
    this.selectedApexClass = className;
    this.apexSearchTerm = className;
    this.showApexDropdown = false;
  }

  handleApexFocus() {
    this.showApexDropdown = true;
  }

  handleApexBlur() {
    setTimeout(() => {
      this.showApexDropdown = false;
    }, 250);
  }

  handleFlowSearchInput(event) {
    const term = event.target.value;
    this.flowSearchTerm = term;
    this.showFlowDropdown = true;
    clearTimeout(this.flowSearchTimer);
    this.flowSearchTimer = setTimeout(async () => {
      try {
        const flows = await searchFlows({ searchTerm: term });
        this.flowSearchResults = flows || [];
      } catch {
        this.flowSearchResults = [];
      }
    }, 300);
  }

  handleSelectFlow(event) {
    const flowName = event.currentTarget.dataset.name;
    this.selectedFlow = flowName;
    this.flowSearchTerm = flowName;
    this.showFlowDropdown = false;
  }

  handleFlowFocus() {
    this.showFlowDropdown = true;
  }

  handleFlowBlur() {
    setTimeout(() => {
      this.showFlowDropdown = false;
    }, 250);
  }

  handleActiveUsersToggle(event) {
    this.activeUsersOnly = event.target.checked;
  }

  handleTableFilter(event) {
    this.userFilterTerm = event.target.value;
  }

  // --- Action: Run Audit Search ---

  async handleSearchAccess() {
    let target = "";
    let access = "";

    if (this.isObjectCategory) {
      target = this.selectedSObject;
      access = this.selectedAccessType;
    } else if (this.isFieldCategory) {
      target = this.selectedField;
      access = this.selectedFieldAccessType;
    } else if (this.isSystemCategory) {
      target = this.selectedSystemPerm;
      access = "Enabled";
    } else if (this.isApexCategory) {
      target = this.selectedApexClass || this.apexSearchTerm;
      access = "Execute";
    } else if (this.isFlowCategory) {
      target = this.selectedFlow || this.flowSearchTerm;
      access = "Run Flow";
    }

    if (!target) {
      this.showToast("Target Required", "Please select or search a valid target to audit.", "warning");
      return;
    }

    this.isLoading = true;
    try {
      const response = await getUsersWithAccess({
        category: this.activeCategory,
        targetName: target,
        accessType: access,
        activeUsersOnly: this.activeUsersOnly
      });

      this.auditResults = response;

      // Enhance users with badge classes and keys
      this.allUsers = (response.users || []).map((u, idx) => {
        const enhancedSources = (u.sources || []).map((s, sIdx) => {
          let badgeClass = "source-badge source-badge-ps";
          if (s.sourceType === "Profile") {
            badgeClass = "source-badge source-badge-profile";
          } else if (s.sourceType === "Permission Set Group") {
            badgeClass = "source-badge source-badge-psg";
          } else if (s.sourceType.includes("System Permission")) {
            badgeClass = "source-badge source-badge-sys";
          }
          return {
            ...s,
            key: `${u.userId}_src_${sIdx}`,
            badgeClass
          };
        });

        return {
          ...u,
          key: u.userId || `user_${idx}`,
          statusBadgeClass: u.isActive ? "slds-badge slds-theme_success" : "slds-badge slds-theme_shade",
          statusLabel: u.isActive ? "Active" : "Inactive",
          sources: enhancedSources
        };
      });

      this.hasEvaluated = true;
    } catch (err) {
      this.showToast("Audit Failed", reduceErrors(err).join(", "), "error");
    } finally {
      this.isLoading = false;
    }
  }

  // --- Action: Universal CSV Export ---

  handleExportCsv() {
    const usersToExport = this.displayedUsers && this.displayedUsers.length
      ? this.displayedUsers
      : this.allUsers;

    if (!usersToExport || !usersToExport.length) {
      this.showToast("No Data", "There are no records to export.", "info");
      return;
    }

    const columns = [
      { label: "User Name", fieldName: "name" },
      { label: "Username", fieldName: "username" },
      { label: "Profile", fieldName: "profileName" },
      { label: "Status", fieldName: "statusLabel" },
      { label: "Role", fieldName: "userRole" },
      { label: "Department", fieldName: "department" },
      { label: "Title", fieldName: "title" },
      { label: "Permission Category", fieldName: "category" },
      { label: "Target", fieldName: "targetName" },
      { label: "Access Level", fieldName: "accessType" },
      { label: "Grant Sources", fieldName: "grantSourcesFormatted" },
      { label: "Total Sources", fieldName: "totalSourcesCount" }
    ];

    const category = this.auditResults ? this.auditResults.category : this.activeCategory;
    const target = this.auditResults ? this.auditResults.targetName : "";
    const access = this.auditResults ? this.auditResults.accessType : "";

    const exportRows = usersToExport.map((u) => {
      const allSourcesText = (u.sources || [])
        .map((s) => `${s.sourceType}: ${s.sourceName} (${s.reason})`)
        .join(" | ");
      return {
        ...u,
        statusLabel: u.isActive ? "Active" : "Inactive",
        category: category,
        targetName: target,
        accessType: access,
        grantSourcesFormatted: allSourcesText || u.primarySource
      };
    });

    const categoryClean = (category || "audit").toLowerCase().replace(/[^a-zA-Z0-9_-]/g, "_");
    const targetClean = (target || "target").replace(/[^a-zA-Z0-9_-]/g, "_");
    const dateStr = new Date().toISOString().slice(0, 10);
    const fileName = `WhoHasAccess_${categoryClean}_${targetClean}_${dateStr}.csv`;

    exportToCsv(columns, exportRows, fileName);
    this.showToast("Export Successful", `Exported ${exportRows.length} user records to ${fileName}`, "success");
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