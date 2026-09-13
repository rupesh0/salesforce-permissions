import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSearchableSObjects from "@salesforce/apex/RecordAccessController.getSearchableSObjects";
import searchRecords from "@salesforce/apex/RecordAccessController.searchRecords";
import searchUsers from "@salesforce/apex/RecordAccessController.searchUsers";
import checkRecordAccess from "@salesforce/apex/RecordAccessController.checkRecordAccess";
import getRecordSharingDetails from "@salesforce/apex/RecordAccessController.getRecordSharingDetails";
import { reduceErrors } from "c/utils";

export default class RecordAccess extends LightningElement {
  // sObject options
  @track allSObjectOptions = [];
  sObjectFilter = "";
  selectedSObject = "Account";
  isSObjectsLoading = false;

  // Record Search & Selection
  recordSearchTerm = "";
  @track recordSearchResults = [];
  isRecordSearching = false;
  showRecordDropdown = false;
  @track selectedRecords = [];

  // User Search & Selection
  userSearchTerm = "";
  @track userSearchResults = [];
  isUserSearching = false;
  showUserDropdown = false;
  @track selectedUsers = [];

  // Matrix State
  isLoading = false;
  hasEvaluated = false;
  errorMessage = "";
  @track matrixUsers = [];
  @track matrixRows = [];

  // Sharing Details Modal State
  isModalOpen = false;
  isModalLoading = false;
  @track modalData = null;

  // Timer ids for debouncing
  recordSearchTimeout;
  userSearchTimeout;

  connectedCallback() {
    this.loadSObjects();
    this.fetchInitialUsers();
  }

  async loadSObjects() {
    this.isSObjectsLoading = true;
    try {
      const results = await getSearchableSObjects();
      this.allSObjectOptions = (results || []).map((opt) => ({
        label: `${opt.label} (${opt.apiName})`,
        value: opt.apiName,
        rawLabel: opt.label
      }));

      // If Account exists, keep it as default; otherwise use first
      const hasAccount = this.allSObjectOptions.some(
        (o) => o.value.toLowerCase() === "account"
      );
      if (hasAccount) {
        this.selectedSObject = "Account";
      } else if (this.allSObjectOptions.length > 0) {
        this.selectedSObject = this.allSObjectOptions[0].value;
      }
    } catch (err) {
      this.showToast("Error loading sObjects", reduceErrors(err).join(", "), "error");
    } finally {
      this.isSObjectsLoading = false;
    }
  }

  async fetchInitialUsers() {
    try {
      const results = await searchUsers({ searchTerm: "" });
      this.userSearchResults = results || [];
    } catch {
      // Ignore initial query error
    }
  }

  // --- Getters ---

  get sObjectOptions() {
    if (!this.sObjectFilter) {
      return this.allSObjectOptions;
    }
    const filter = this.sObjectFilter.toLowerCase();
    return this.allSObjectOptions.filter(
      (opt) =>
        opt.label.toLowerCase().includes(filter) ||
        opt.value.toLowerCase().includes(filter)
    );
  }

  get selectedSObjectLabel() {
    const found = this.allSObjectOptions.find(
      (o) => o.value === this.selectedSObject
    );
    return found ? found.rawLabel : this.selectedSObject;
  }

  get recordSearchPlaceholder() {
    return `Search ${this.selectedSObjectLabel} by Name or ID...`;
  }

  get selectedRecordsCount() {
    return this.selectedRecords.length;
  }

  get selectedUsersCount() {
    return this.selectedUsers.length;
  }

  get hasSelectedRecords() {
    return this.selectedRecords.length > 0;
  }

  get hasSelectedUsers() {
    return this.selectedUsers.length > 0;
  }

  get isApplyDisabled() {
    return (
      this.selectedRecords.length === 0 ||
      this.selectedUsers.length === 0 ||
      this.isLoading
    );
  }

  get hasResults() {
    return this.hasEvaluated && this.matrixRows && this.matrixRows.length > 0;
  }

  get hasNoResults() {
    return this.hasEvaluated && (!this.matrixRows || this.matrixRows.length === 0);
  }

  // --- Event Handlers: sObject ---

  handleSObjectChange(event) {
    this.selectedSObject = event.detail.value;
    this.recordSearchTerm = "";
    this.recordSearchResults = [];
    this.showRecordDropdown = false;
  }

  // --- Event Handlers: Record Search ---

  handleRecordSearchInput(event) {
    const term = event.target.value;
    this.recordSearchTerm = term;
    this.showRecordDropdown = true;
    this.isRecordSearching = true;

    clearTimeout(this.recordSearchTimeout);
    this.recordSearchTimeout = setTimeout(async () => {
      try {
        const results = await searchRecords({
          sObjectName: this.selectedSObject,
          searchTerm: term
        });
        this.recordSearchResults = results || [];
      } catch (err) {
        this.recordSearchResults = [];
      } finally {
        this.isRecordSearching = false;
      }
    }, 300);
  }

  handleRecordFocus() {
    this.showRecordDropdown = true;
    if (this.recordSearchResults.length === 0) {
      this.handleRecordSearchInput({ target: { value: this.recordSearchTerm } });
    }
  }

  handleRecordBlur() {
    setTimeout(() => {
      this.showRecordDropdown = false;
    }, 250);
  }

  handleSelectRecord(event) {
    const recordId = event.currentTarget.dataset.id;
    const found = this.recordSearchResults.find((r) => r.id === recordId);
    if (found && !this.selectedRecords.some((r) => r.id === recordId)) {
      this.selectedRecords = [...this.selectedRecords, found];
    }
    this.recordSearchTerm = "";
    this.showRecordDropdown = false;
  }

  handleRemoveRecord(event) {
    const recordId = event.currentTarget.dataset.id;
    this.selectedRecords = this.selectedRecords.filter((r) => r.id !== recordId);
  }

  handleClearAllRecords() {
    this.selectedRecords = [];
  }

  // --- Event Handlers: User Search ---

  handleUserSearchInput(event) {
    const term = event.target.value;
    this.userSearchTerm = term;
    this.showUserDropdown = true;
    this.isUserSearching = true;

    clearTimeout(this.userSearchTimeout);
    this.userSearchTimeout = setTimeout(async () => {
      try {
        const results = await searchUsers({ searchTerm: term });
        this.userSearchResults = results || [];
      } catch (err) {
        this.userSearchResults = [];
      } finally {
        this.isUserSearching = false;
      }
    }, 300);
  }

  handleUserFocus() {
    this.showUserDropdown = true;
    if (this.userSearchResults.length === 0) {
      this.handleUserSearchInput({ target: { value: this.userSearchTerm } });
    }
  }

  handleUserBlur() {
    setTimeout(() => {
      this.showUserDropdown = false;
    }, 250);
  }

  handleSelectUser(event) {
    const userId = event.currentTarget.dataset.id;
    const found = this.userSearchResults.find((u) => u.id === userId);
    if (found && !this.selectedUsers.some((u) => u.id === userId)) {
      this.selectedUsers = [...this.selectedUsers, found];
    }
    this.userSearchTerm = "";
    this.showUserDropdown = false;
  }

  handleRemoveUser(event) {
    const userId = event.currentTarget.dataset.id;
    this.selectedUsers = this.selectedUsers.filter((u) => u.id !== userId);
  }

  handleClearAllUsers() {
    this.selectedUsers = [];
  }

  // --- Action: Apply Evaluation ---

  async handleApply() {
    if (this.selectedRecords.length === 0 || this.selectedUsers.length === 0) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = "";

    const recordIds = this.selectedRecords.map((r) => r.id);
    const userIds = this.selectedUsers.map((u) => u.id);

    try {
      const matrixResult = await checkRecordAccess({
        recordIds: recordIds,
        userIds: userIds
      });

      this.matrixUsers = (matrixResult.users || []).map((u) => ({
        ...u,
        readKey: `${u.userId}_read`,
        editKey: `${u.userId}_edit`
      }));

      // Transform rows for template iteration
      this.matrixRows = (matrixResult.rows || []).map((row) => {
        const userCells = this.matrixUsers.map((u) => {
          const acc = (row.userAccess && row.userAccess[u.userId]) || {
            hasReadAccess: false,
            hasEditAccess: false,
            maxAccessLevel: "None"
          };
          return {
            userId: u.userId,
            readKey: `${row.recordId}_${u.userId}_read`,
            editKey: `${row.recordId}_${u.userId}_edit`,
            hasReadAccess: acc.hasReadAccess,
            hasEditAccess: acc.hasEditAccess,
            maxAccessLevel: acc.maxAccessLevel
          };
        });

        return {
          recordId: row.recordId,
          recordName: row.recordName,
          sObjectName: row.sObjectName,
          sObjectLabel: row.sObjectLabel,
          cells: userCells
        };
      });

      this.hasEvaluated = true;
    } catch (err) {
      this.errorMessage = reduceErrors(err).join(", ");
      this.showToast("Error evaluating record access", this.errorMessage, "error");
    } finally {
      this.isLoading = false;
    }
  }

  handleReset() {
    this.selectedRecords = [];
    this.selectedUsers = [];
    this.matrixRows = [];
    this.matrixUsers = [];
    this.hasEvaluated = false;
    this.errorMessage = "";
    this.recordSearchTerm = "";
    this.userSearchTerm = "";
  }

  // --- Sharing Details Modal ---

  async handleOpenDetails(event) {
    const recordId = event.currentTarget.dataset.recordId;
    if (!recordId) return;

    this.isModalOpen = true;
    this.isModalLoading = true;
    this.modalData = null;

    const userIds = this.selectedUsers.map((u) => u.id);

    try {
      const details = await getRecordSharingDetails({
        recordId: recordId,
        userIds: userIds
      });

      // Enhance user explanations with badge themes and unique reason keys
      if (details && details.userExplanations) {
        details.userExplanations = details.userExplanations.map((ue) => {
          let badgeClass = "slds-badge";
          if (ue.overallAccess.includes("Full Access")) {
            badgeClass = "slds-badge slds-theme_success";
          } else if (ue.overallAccess.includes("Read/Write")) {
            badgeClass = "slds-badge slds-theme_info";
          } else if (ue.overallAccess.includes("Read Only")) {
            badgeClass = "slds-badge";
          } else {
            badgeClass = "slds-badge slds-theme_error";
          }
          const reasonsWithKeys = (ue.reasons || []).map((r, index) => ({
            ...r,
            key: `${ue.userId}_reason_${index}`
          }));
          return {
            ...ue,
            badgeClass,
            reasons: reasonsWithKeys
          };
        });
      }

      this.modalData = details;
    } catch (err) {
      this.showToast(
        "Error retrieving sharing details",
        reduceErrors(err).join(", "),
        "error"
      );
      this.handleCloseModal();
    } finally {
      this.isModalLoading = false;
    }
  }

  handleCloseModal() {
    this.isModalOpen = false;
    this.modalData = null;
    this.isModalLoading = false;
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