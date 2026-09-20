import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMigratableProfiles from '@salesforce/apex/ProfileMigrationController.getMigratableProfiles';
import analyzeProfilePermissions from '@salesforce/apex/ProfileMigrationController.analyzeProfilePermissions';
import generatePermissionSet from '@salesforce/apex/ProfileMigrationController.generatePermissionSet';
import previewUserMigration from '@salesforce/apex/ProfileMigrationController.previewUserMigration';
import executeUserMigration from '@salesforce/apex/ProfileMigrationController.executeUserMigration';
import rollbackUserAssignments from '@salesforce/apex/ProfileMigrationController.rollbackUserAssignments';
import { exportToCsv } from 'c/csvExportUtil';

export default class ProfileMigration extends LightningElement {
  // Navigation State
  @track currentStep = 'deconstruct'; // 'deconstruct' | 'generate' | 'migrate'
  @track isLoading = false;
  @track error = null;

  // Profile Selection & Analysis
  @track profileOptions = [];
  @track selectedProfileId = '';
  @track selectedProfileName = '';
  @track analysisData = null;
  @track activeTab = 'OBJECTS';

  // Category Table Search Filters
  @track objectSearchTerm = '';
  @track fieldSearchTerm = '';
  @track systemSearchTerm = '';
  @track apexSearchTerm = '';

  // Selective Object Unbundling
  @track selectedObjectsMap = {}; // objectName -> boolean
  @track selectAllObjects = true;

  // Generator Configuration (Step 2)
  @track targetType = 'PERMISSION_SET'; // 'PERMISSION_SET' | 'PERMISSION_SET_GROUP'
  @track targetLabel = '';
  @track targetName = '';
  @track targetDescription = '';
  @track includeObjects = true;
  @track includeFields = true;
  @track includeSystemPerms = true;
  @track includeApexClasses = true;

  // Generation Results
  @track migrationResult = null;

  // User Migration (Step 3)
  @track userPreview = null;
  @track userSearchTerm = '';
  @track selectedUserIds = [];
  @track selectAllUsers = true;
  @track executionResult = null;
  @track isRollbackLoading = false;

  // ====================================================
  // Lifecycle & Initial Data
  // ====================================================

  connectedCallback() {
    this.loadProfiles();
  }

  loadProfiles() {
    this.isLoading = true;
    getMigratableProfiles()
      .then((data) => {
        this.profileOptions = data.map((p) => {
          const customTag = p.isCustom ? ' [Custom]' : '';
          return {
            label: `${p.name} (${p.activeUserCount} active users)${customTag}`,
            value: p.id,
            name: p.name,
            activeCount: p.activeUserCount,
            totalCount: p.totalUserCount,
            licenseName: p.licenseName
          };
        });
        if (this.profileOptions.length > 0 && !this.selectedProfileId) {
          // Pre-select first profile with active users or standard user
          const preferred =
            this.profileOptions.find((p) => p.name === 'Standard User') ||
            this.profileOptions.find((p) => p.activeCount > 0) ||
            this.profileOptions[0];
          this.selectedProfileId = preferred.value;
          this.selectedProfileName = preferred.name;
          this.handleAnalyzeProfile();
        } else {
          this.isLoading = false;
        }
      })
      .catch((err) => {
        this.isLoading = false;
        this.showToast('Error', 'Failed to load profiles: ' + this.getErrMsg(err), 'error');
      });
  }

  // ====================================================
  // Step 1: Deconstruction & Analysis
  // ====================================================

  handleProfileChange(event) {
    this.selectedProfileId = event.detail.value;
    const selected = this.profileOptions.find((p) => p.value === this.selectedProfileId);
    if (selected) {
      this.selectedProfileName = selected.name;
    }
    this.handleAnalyzeProfile();
  }

  handleAnalyzeProfile() {
    if (!this.selectedProfileId) return;

    this.isLoading = true;
    this.error = null;
    analyzeProfilePermissions({ profileId: this.selectedProfileId })
      .then((result) => {
        this.analysisData = result;
        // Reset selective objects selection to all
        const objMap = {};
        if (result.objectPermissions) {
          result.objectPermissions.forEach((op) => {
            objMap[op.objectName] = true;
          });
        }
        this.selectedObjectsMap = objMap;
        this.selectAllObjects = true;

        // Auto-populate default target names
        const cleanName = result.profileName.replace(/[^a-zA-Z0-9]/g, '_');
        this.targetLabel = `${result.profileName} Permissions`;
        this.targetName = `${cleanName}_PermSet`;
        this.targetDescription = `Modular Permission Set extracted from Profile ${result.profileName} on ${new Date().toLocaleDateString()}`;

        this.isLoading = false;
      })
      .catch((err) => {
        this.isLoading = false;
        this.error = this.getErrMsg(err);
        this.showToast('Analysis Error', this.error, 'error');
      });
  }

  handleTabSelect(event) {
    this.activeTab = event.target.value;
  }

  // Search filter handlers
  handleObjectSearch(event) {
    this.objectSearchTerm = event.target.value.toLowerCase();
  }

  handleFieldSearch(event) {
    this.fieldSearchTerm = event.target.value.toLowerCase();
  }

  handleSystemSearch(event) {
    this.systemSearchTerm = event.target.value.toLowerCase();
  }

  handleApexSearch(event) {
    this.apexSearchTerm = event.target.value.toLowerCase();
  }

  // Selective object check / uncheck
  handleToggleAllObjects(event) {
    const checked = event.target.checked;
    this.selectAllObjects = checked;
    const updated = { ...this.selectedObjectsMap };
    Object.keys(updated).forEach((k) => {
      updated[k] = checked;
    });
    this.selectedObjectsMap = updated;
  }

  handleObjectCheckboxChange(event) {
    const objName = event.target.dataset.object;
    const checked = event.target.checked;
    this.selectedObjectsMap = {
      ...this.selectedObjectsMap,
      [objName]: checked
    };
  }

  get filteredObjectPermissions() {
    if (!this.analysisData || !this.analysisData.objectPermissions) return [];
    return this.analysisData.objectPermissions
      .filter((op) => {
        return !this.objectSearchTerm || op.objectName.toLowerCase().includes(this.objectSearchTerm);
      })
      .map((op) => {
        return {
          ...op,
          isSelected: !!this.selectedObjectsMap[op.objectName]
        };
      });
  }

  get filteredFieldPermissions() {
    if (!this.analysisData || !this.analysisData.fieldPermissions) return [];
    return this.analysisData.fieldPermissions.filter((fp) => {
      const matchSearch =
        !this.fieldSearchTerm ||
        fp.objectName.toLowerCase().includes(this.fieldSearchTerm) ||
        fp.fieldName.toLowerCase().includes(this.fieldSearchTerm);
      return matchSearch;
    });
  }

  get filteredSystemPermissions() {
    if (!this.analysisData || !this.analysisData.systemPermissions) return [];
    return this.analysisData.systemPermissions.filter((sp) => {
      return (
        !this.systemSearchTerm ||
        (sp.label && sp.label.toLowerCase().includes(this.systemSearchTerm)) ||
        (sp.apiName && sp.apiName.toLowerCase().includes(this.systemSearchTerm))
      );
    });
  }

  get filteredApexClassPermissions() {
    if (!this.analysisData || !this.analysisData.apexClassPermissions) return [];
    return this.analysisData.apexClassPermissions.filter((ac) => {
      return !this.apexSearchTerm || ac.className.toLowerCase().includes(this.apexSearchTerm);
    });
  }

  // Navigation from Step 1 to Step 2
  handleProceedToGenerator() {
    if (!this.analysisData) {
      this.showToast('Warning', 'Please select and analyze a profile first.', 'warning');
      return;
    }
    this.currentStep = 'generate';
  }

  // ====================================================
  // Step 2: Configure & Generate Permission Set / PSG
  // ====================================================

  handleTargetTypeSelect(event) {
    this.targetType = event.currentTarget.dataset.type;
  }

  handleLabelChange(event) {
    this.targetLabel = event.target.value;
    // Auto-generate sanitized API name if user hasn't heavily customized it
    const clean = this.targetLabel.replace(/[^a-zA-Z0-9]/g, '_').replace(/_+/g, '_');
    this.targetName = clean ? (clean.endsWith('_') ? clean + 'PermSet' : clean) : '';
  }

  handleNameChange(event) {
    this.targetName = event.target.value;
  }

  handleDescChange(event) {
    this.targetDescription = event.target.value;
  }

  handleToggleCategory(event) {
    const cat = event.currentTarget.dataset.category;
    if (cat === 'OBJECT') this.includeObjects = !this.includeObjects;
    if (cat === 'FIELD') this.includeFields = !this.includeFields;
    if (cat === 'SYSTEM') this.includeSystemPerms = !this.includeSystemPerms;
    if (cat === 'APEX') this.includeApexClasses = !this.includeApexClasses;
  }

  handleBackToDeconstruct() {
    this.currentStep = 'deconstruct';
  }

  handleExecuteGeneration() {
    if (!this.targetLabel || !this.targetName) {
      this.showToast('Missing Details', 'Please provide both Label and API Name.', 'error');
      return;
    }

    // Determine selected objects
    const selectedObjs = Object.keys(this.selectedObjectsMap).filter(
      (k) => this.selectedObjectsMap[k] === true
    );

    const req = {
      sourceProfileId: this.selectedProfileId,
      targetType: this.targetType,
      targetName: this.targetName.trim(),
      targetLabel: this.targetLabel.trim(),
      description: this.targetDescription.trim(),
      includeObjects: this.includeObjects,
      includeFields: this.includeFields,
      includeSystemPerms: this.includeSystemPerms,
      includeApexClasses: this.includeApexClasses,
      selectedObjects: selectedObjs
    };

    this.isLoading = true;
    generatePermissionSet({ request: req })
      .then((res) => {
        this.isLoading = false;
        this.migrationResult = res;
        this.showToast('Success', res.message, 'success');
        // Automatically load Step 3 Pre-Flight
        this.handleProceedToMigration();
      })
      .catch((err) => {
        this.isLoading = false;
        this.showToast('Generation Failed', this.getErrMsg(err), 'error');
      });
  }

  // ====================================================
  // Step 3: Safe User Migration & Pre-Flight Simulator
  // ====================================================

  handleProceedToMigration() {
    if (!this.migrationResult || !this.migrationResult.permissionSetId) {
      this.showToast('Error', 'Please generate a Permission Set first.', 'error');
      return;
    }
    this.currentStep = 'migrate';
    this.loadUserPreview();
  }

  loadUserPreview() {
    this.isLoading = true;
    previewUserMigration({
      profileId: this.selectedProfileId,
      targetPermissionSetId: this.migrationResult.permissionSetId,
      targetPsgId: this.migrationResult.permissionSetGroupId
    })
      .then((data) => {
        this.isLoading = false;
        this.userPreview = data;
        // Default select all READY users
        this.selectedUserIds = data.users
          .filter((u) => u.status === 'READY')
          .map((u) => u.userId);
        this.selectAllUsers = true;
      })
      .catch((err) => {
        this.isLoading = false;
        this.showToast('Preview Error', this.getErrMsg(err), 'error');
      });
  }

  handleUserSearch(event) {
    this.userSearchTerm = event.target.value.toLowerCase();
  }

  get filteredUsers() {
    if (!this.userPreview || !this.userPreview.users) return [];
    return this.userPreview.users
      .filter((u) => {
        return (
          !this.userSearchTerm ||
          u.name.toLowerCase().includes(this.userSearchTerm) ||
          u.username.toLowerCase().includes(this.userSearchTerm) ||
          (u.email && u.email.toLowerCase().includes(this.userSearchTerm))
        );
      })
      .map((u) => {
        return {
          ...u,
          isChecked: this.selectedUserIds.includes(u.userId),
          isNotSelectable: !u.isSelectable,
          badgeClass:
            u.status === 'READY'
              ? 'status-badge status-ready'
              : u.status === 'ALREADY_ASSIGNED'
              ? 'status-badge status-assigned'
              : 'status-badge status-inactive',
          badgeText:
            u.status === 'READY'
              ? 'Ready to Assign'
              : u.status === 'ALREADY_ASSIGNED'
              ? 'Already Assigned'
              : 'Inactive (Skipped)'
        };
      });
  }

  handleToggleSelectAllUsers(event) {
    const checked = event.target.checked;
    this.selectAllUsers = checked;
    if (checked) {
      this.selectedUserIds = this.userPreview.users
        .filter((u) => u.status === 'READY')
        .map((u) => u.userId);
    } else {
      this.selectedUserIds = [];
    }
  }

  handleUserCheckboxChange(event) {
    const uId = event.target.dataset.id;
    const checked = event.target.checked;
    if (checked) {
      if (!this.selectedUserIds.includes(uId)) {
        this.selectedUserIds = [...this.selectedUserIds, uId];
      }
    } else {
      this.selectedUserIds = this.selectedUserIds.filter((id) => id !== uId);
    }
  }

  handleExecuteUserMigration() {
    if (!this.selectedUserIds || this.selectedUserIds.length === 0) {
      this.showToast('No Users Selected', 'Please select at least one ready user to assign.', 'warning');
      return;
    }

    this.isLoading = true;
    executeUserMigration({
      profileId: this.selectedProfileId,
      targetPermissionSetId: this.migrationResult.permissionSetId,
      targetPsgId: this.migrationResult.permissionSetGroupId,
      userIds: this.selectedUserIds
    })
      .then((res) => {
        this.isLoading = false;
        this.executionResult = res;
        if (res.success) {
          this.showToast('Migration Complete', res.message, 'success');
        } else {
          this.showToast('Partial Success', res.message, 'warning');
        }
        // Refresh preview to show updated status
        this.loadUserPreview();
      })
      .catch((err) => {
        this.isLoading = false;
        this.showToast('Execution Error', this.getErrMsg(err), 'error');
      });
  }

  handleRollbackAssignments() {
    if (
      !this.executionResult ||
      !this.executionResult.createdAssignmentIds ||
      this.executionResult.createdAssignmentIds.length === 0
    ) {
      this.showToast('Warning', 'No created assignments found to rollback.', 'warning');
      return;
    }

    this.isRollbackLoading = true;
    rollbackUserAssignments({
      assignmentIds: this.executionResult.createdAssignmentIds
    })
      .then((res) => {
        this.isRollbackLoading = false;
        this.executionResult = null;
        this.showToast('Rollback Successful', res.message, 'success');
        this.loadUserPreview();
      })
      .catch((err) => {
        this.isRollbackLoading = false;
        this.showToast('Rollback Failed', this.getErrMsg(err), 'error');
      });
  }

  // ====================================================
  // CSV Export Utility
  // ====================================================

  handleExportCSV() {
    if (!this.analysisData) return;

    const columns = [
      { label: 'Category', fieldName: 'category' },
      { label: 'Item Name', fieldName: 'itemName' },
      { label: 'Field / Detail', fieldName: 'detail' },
      { label: 'Access Summary', fieldName: 'access' }
    ];

    const rows = [];

    // Objects
    if (this.analysisData.objectPermissions) {
      this.analysisData.objectPermissions.forEach((op) => {
        const perms = [];
        if (op.permissionsRead) perms.push('Read');
        if (op.permissionsCreate) perms.push('Create');
        if (op.permissionsEdit) perms.push('Edit');
        if (op.permissionsDelete) perms.push('Delete');
        if (op.permissionsViewAllRecords) perms.push('ViewAll');
        if (op.permissionsModifyAllRecords) perms.push('ModifyAll');
        rows.push({
          category: 'Object Permission',
          itemName: op.objectName,
          detail: 'SObject CRUD',
          access: perms.join(' | ') || 'None'
        });
      });
    }

    // Fields
    if (this.analysisData.fieldPermissions) {
      this.analysisData.fieldPermissions.forEach((fp) => {
        const perms = [];
        if (fp.permissionsRead) perms.push('Read');
        if (fp.permissionsEdit) perms.push('Edit');
        rows.push({
          category: 'Field Permission',
          itemName: fp.objectName,
          detail: fp.fieldName,
          access: perms.join(' | ') || 'None'
        });
      });
    }

    // System Permissions
    if (this.analysisData.systemPermissions) {
      this.analysisData.systemPermissions.forEach((sp) => {
        rows.push({
          category: 'System Permission',
          itemName: sp.label || sp.apiName,
          detail: sp.apiName,
          access: sp.enabled ? 'Enabled' : 'Disabled'
        });
      });
    }

    // Apex Classes
    if (this.analysisData.apexClassPermissions) {
      this.analysisData.apexClassPermissions.forEach((ac) => {
        rows.push({
          category: 'Apex Class Access',
          itemName: ac.className,
          detail: ac.classId,
          access: 'Enabled'
        });
      });
    }

    const fileName = `Profile_Breakdown_${this.selectedProfileName.replace(/\s+/g, '_')}.csv`;
    exportToCsv(columns, rows, fileName);
    this.showToast('Exported', `Profile breakdown exported to ${fileName}`, 'info');
  }

  // ====================================================
  // UI Helpers & Computed Properties
  // ====================================================

  get isStepDeconstruct() {
    return this.currentStep === 'deconstruct';
  }

  get isStepGenerate() {
    return this.currentStep === 'generate';
  }

  get isStepMigrate() {
    return this.currentStep === 'migrate';
  }

  get isObjectsTab() {
    return this.activeTab === 'OBJECTS';
  }

  get isFieldsTab() {
    return this.activeTab === 'FIELDS';
  }

  get isSystemTab() {
    return this.activeTab === 'SYSTEM';
  }

  get isApexTab() {
    return this.activeTab === 'APEX';
  }

  get isPsMode() {
    return this.targetType === 'PERMISSION_SET';
  }

  get isPsgMode() {
    return this.targetType === 'PERMISSION_SET_GROUP';
  }

  get hasWarnings() {
    return (
      this.migrationResult &&
      this.migrationResult.warnings &&
      this.migrationResult.warnings.length > 0
    );
  }

  get selectedUserCount() {
    return this.selectedUserIds ? this.selectedUserIds.length : 0;
  }

  get hasCreatedAssignments() {
    return (
      this.executionResult &&
      this.executionResult.createdAssignmentIds &&
      this.executionResult.createdAssignmentIds.length > 0
    );
  }

  get modePsClass() {
    return this.targetType === 'PERMISSION_SET' ? 'mode-card selected' : 'mode-card';
  }

  get modePsgClass() {
    return this.targetType === 'PERMISSION_SET_GROUP' ? 'mode-card selected' : 'mode-card';
  }

  get pillObjectClass() {
    return this.includeObjects ? 'category-pill active' : 'category-pill';
  }

  get pillObjectVariant() {
    return this.includeObjects ? 'inverse' : '';
  }

  get pillFieldClass() {
    return this.includeFields ? 'category-pill active' : 'category-pill';
  }

  get pillFieldVariant() {
    return this.includeFields ? 'inverse' : '';
  }

  get pillSystemClass() {
    return this.includeSystemPerms ? 'category-pill active' : 'category-pill';
  }

  get pillSystemVariant() {
    return this.includeSystemPerms ? 'inverse' : '';
  }

  get pillApexClass() {
    return this.includeApexClasses ? 'category-pill active' : 'category-pill';
  }

  get pillApexVariant() {
    return this.includeApexClasses ? 'inverse' : '';
  }

  get executeButtonLabel() {
    return `Assign ${this.selectedUserCount} Users (Zero-Downtime)`;
  }

  get isExportDisabled() {
    return !this.analysisData;
  }

  get isRefreshDisabled() {
    return !this.selectedProfileId;
  }

  get isExecuteDisabled() {
    return !this.selectedUserCount;
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  getErrMsg(error) {
    if (error && error.body && error.body.message) {
      return error.body.message;
    }
    if (error && error.message) {
      return error.message;
    }
    return JSON.stringify(error);
  }
}
