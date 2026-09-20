import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSecurityHealthSummary from "@salesforce/apex/SecurityAdvisorController.getSecurityHealthSummary";
import { exportToCsv } from "c/csvExportUtil";

export default class SecurityAdvisor extends LightningElement {
  @track summary = null;
  isLoading = true;

  // Active view tab: 'CRITICAL' | 'DORMANT' | 'INACTIVE' | 'REDUNDANT'
  activeTab = "CRITICAL";
  searchTerm = "";

  // Detail Modal for Affected Users
  isModalOpen = false;
  selectedFinding = null;
  modalSearchTerm = "";

  connectedCallback() {
    this.loadSecuritySummary();
  }

  async loadSecuritySummary() {
    this.isLoading = true;
    try {
      const data = await getSecurityHealthSummary();
      this.summary = data;
    } catch (error) {
      this.showToast(
        "Error Loading Security Data",
        error.body ? error.body.message : error.message,
        "error"
      );
    } finally {
      this.isLoading = false;
    }
  }

  handleRefresh() {
    this.loadSecuritySummary();
  }

  // --- Tab Navigation ---

  handleTabClick(event) {
    this.activeTab = event.currentTarget.dataset.tab;
    this.searchTerm = "";
  }

  handleKpiClick(event) {
    const tab = event.currentTarget.dataset.tab;
    if (tab) {
      this.activeTab = tab;
      this.searchTerm = "";
    }
  }

  handleSearchChange(event) {
    this.searchTerm = event.target.value.toLowerCase();
  }

  // --- Getters for Computed UI Elements ---

  get isCriticalTab() {
    return this.activeTab === "CRITICAL";
  }

  get isDormantTab() {
    return this.activeTab === "DORMANT";
  }

  get isInactiveTab() {
    return this.activeTab === "INACTIVE";
  }

  get isRedundantTab() {
    return this.activeTab === "REDUNDANT";
  }

  get criticalTabClass() {
    return `nav-pill ${this.activeTab === "CRITICAL" ? "active" : ""}`;
  }

  get dormantTabClass() {
    return `nav-pill ${this.activeTab === "DORMANT" ? "active" : ""}`;
  }

  get inactiveTabClass() {
    return `nav-pill ${this.activeTab === "INACTIVE" ? "active" : ""}`;
  }

  get redundantTabClass() {
    return `nav-pill ${this.activeTab === "REDUNDANT" ? "active" : ""}`;
  }

  get scoreNumber() {
    return this.summary ? this.summary.overallScore : 0;
  }

  get healthGrade() {
    return this.summary ? this.summary.healthGrade : "Assessing...";
  }

  get scoreVariantClass() {
    if (!this.summary) return "variant-info";
    return `variant-${this.summary.scoreVariant}`;
  }

  get totalCriticalCount() {
    return this.summary ? this.summary.criticalRisksCount : 0;
  }

  get totalHighCount() {
    return this.summary ? this.summary.highRisksCount : 0;
  }

  get totalDormantCount() {
    return this.summary ? this.summary.dormantPermissionSetsCount : 0;
  }

  get totalInactiveCount() {
    return this.summary ? this.summary.inactiveUsersWithAssignmentsCount : 0;
  }

  get totalRedundantCount() {
    return this.summary ? this.summary.redundantAssignmentsCount : 0;
  }

  // --- Filtered Data Lists ---

  get filteredCriticalFindings() {
    if (!this.summary || !this.summary.criticalFindings) return [];
    return this.summary.criticalFindings
      .filter((f) => {
        if (!this.searchTerm) return true;
        return (
          f.permissionLabel.toLowerCase().includes(this.searchTerm) ||
          f.permissionApiName.toLowerCase().includes(this.searchTerm) ||
          f.severity.toLowerCase().includes(this.searchTerm) ||
          f.description.toLowerCase().includes(this.searchTerm)
        );
      })
      .map((f) => ({
        ...f,
        severityClass: `severity-badge ${f.severity.toLowerCase()}`,
        hasNonAdminWarning: f.nonAdminUsersCount > 0
      }));
  }

  get filteredDormantSets() {
    if (!this.summary || !this.summary.dormantSets) return [];
    return this.summary.dormantSets.filter((ps) => {
      if (!this.searchTerm) return true;
      return (
        ps.label.toLowerCase().includes(this.searchTerm) ||
        ps.name.toLowerCase().includes(this.searchTerm) ||
        (ps.description &&
          ps.description.toLowerCase().includes(this.searchTerm))
      );
    });
  }

  get filteredInactiveAssignments() {
    if (!this.summary || !this.summary.inactiveAssignments) return [];
    return this.summary.inactiveAssignments.filter((ia) => {
      if (!this.searchTerm) return true;
      return (
        (ia.userFullName &&
          ia.userFullName.toLowerCase().includes(this.searchTerm)) ||
        (ia.username && ia.username.toLowerCase().includes(this.searchTerm)) ||
        (ia.profileName &&
          ia.profileName.toLowerCase().includes(this.searchTerm)) ||
        (ia.permissionSetLabel &&
          ia.permissionSetLabel.toLowerCase().includes(this.searchTerm))
      );
    });
  }

  get filteredRedundantAssignments() {
    if (!this.summary || !this.summary.redundantAssignments) return [];
    return this.summary.redundantAssignments.filter((ra) => {
      if (!this.searchTerm) return true;
      return (
        (ra.userName && ra.userName.toLowerCase().includes(this.searchTerm)) ||
        (ra.permissionSetLabel &&
          ra.permissionSetLabel.toLowerCase().includes(this.searchTerm)) ||
        (ra.redundantPermission &&
          ra.redundantPermission.toLowerCase().includes(this.searchTerm))
      );
    });
  }

  // --- Modal Handlers ---

  handleViewUsers(event) {
    const permName = event.currentTarget.dataset.id;
    if (this.summary && this.summary.criticalFindings) {
      const finding = this.summary.criticalFindings.find(
        (f) => f.id === permName
      );
      if (finding) {
        this.selectedFinding = finding;
        this.modalSearchTerm = "";
        this.isModalOpen = true;
      }
    }
  }

  handleCloseModal() {
    this.isModalOpen = false;
    this.selectedFinding = null;
    this.modalSearchTerm = "";
  }

  handleModalSearch(event) {
    this.modalSearchTerm = event.target.value.toLowerCase();
  }

  get filteredModalUsers() {
    if (!this.selectedFinding || !this.selectedFinding.users) return [];
    return this.selectedFinding.users
      .filter((u) => {
        if (!this.modalSearchTerm) return true;
        return (
          u.name.toLowerCase().includes(this.modalSearchTerm) ||
          u.username.toLowerCase().includes(this.modalSearchTerm) ||
          u.profileName.toLowerCase().includes(this.modalSearchTerm) ||
          u.grantSource.toLowerCase().includes(this.modalSearchTerm)
        );
      })
      .map((u) => ({
        ...u,
        badgeClass: u.isAdminProfile ? "admin-badge" : "non-admin-badge",
        badgeLabel: u.isAdminProfile ? "Sys Admin" : "Non-Admin (Elevated)"
      }));
  }

  // --- CSV Export Handler ---

  handleExportCsv() {
    if (!this.summary) return;

    let columns = [];
    let rows = [];
    let fileName = "";
    const dateStr = new Date().toISOString().slice(0, 10);

    if (this.isCriticalTab) {
      columns = [
        { label: "Privilege Name", fieldName: "permissionLabel" },
        { label: "API Name", fieldName: "permissionApiName" },
        { label: "Severity", fieldName: "severity" },
        { label: "Affected Users Count", fieldName: "affectedUsersCount" },
        { label: "Non-Admin Users Count", fieldName: "nonAdminUsersCount" },
        { label: "Description", fieldName: "description" }
      ];
      rows = this.filteredCriticalFindings;
      fileName = `SecurityAudit_CriticalPrivileges_${dateStr}.csv`;
    } else if (this.isDormantTab) {
      columns = [
        { label: "Permission Set Label", fieldName: "label" },
        { label: "API Name", fieldName: "name" },
        { label: "Description", fieldName: "description" },
        { label: "Created Date", fieldName: "createdDate" }
      ];
      rows = this.filteredDormantSets;
      fileName = `SecurityAudit_DormantPermissionSets_${dateStr}.csv`;
    } else if (this.isInactiveTab) {
      columns = [
        { label: "User Name", fieldName: "userFullName" },
        { label: "Username", fieldName: "username" },
        { label: "Profile", fieldName: "profileName" },
        { label: "Permission Set Label", fieldName: "permissionSetLabel" },
        { label: "Permission Set API Name", fieldName: "permissionSetName" }
      ];
      rows = this.filteredInactiveAssignments;
      fileName = `SecurityAudit_InactiveUserAssignments_${dateStr}.csv`;
    } else if (this.isRedundantTab) {
      columns = [
        { label: "Admin User", fieldName: "userName" },
        { label: "Profile", fieldName: "profileName" },
        { label: "Permission Set", fieldName: "permissionSetLabel" },
        { label: "Redundant Permissions", fieldName: "redundantPermission" },
        { label: "Reason", fieldName: "reason" }
      ];
      rows = this.filteredRedundantAssignments;
      fileName = `SecurityAudit_RedundantAssignments_${dateStr}.csv`;
    }

    if (!rows || rows.length === 0) {
      this.showToast(
        "Export Notice",
        "No data to export for current view.",
        "info"
      );
      return;
    }

    exportToCsv(columns, rows, fileName);
    this.showToast(
      "Export Successful",
      `Exported ${rows.length} rows to ${fileName}`,
      "success"
    );
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
