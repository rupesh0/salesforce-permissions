import { LightningElement, track } from "lwc";
import { debounce } from "c/utils";
import searchUsers from "@salesforce/apex/CompareUsersController.searchUsers";
import getUserPermissionDetails from "@salesforce/apex/CompareUsersController.getUserPermissionDetails";
import { ALL_PERMISSION_KEYS } from "c/permissionVisibilityFilter";

export default class CompareUsers extends LightningElement {
  // User 1 state
  user1SearchTerm = "";
  user1Options = [];
  user1Selected = null;
  showUser1Dropdown = false;
  isUser1Loading = false;

  // User 2 state
  user2SearchTerm = "";
  user2Options = [];
  user2Selected = null;
  showUser2Dropdown = false;
  isUser2Loading = false;

  // Single instance of search and permission selection applying to both users
  searchTerm = "";
  @track visiblePermissions = [...ALL_PERMISSION_KEYS];

  connectedCallback() {
    this.fetchInitialUsers();
  }

  async fetchInitialUsers() {
    try {
      const users = await searchUsers({ searchTerm: "" });
      this.user1Options = users || [];
      this.user2Options = users || [];
    } catch {
      // Ignore initial query error
    }
  }

  // --- Search & Visibility Handlers ---
  handleSearchChange(event) {
    this.searchTerm = event.target.value;
  }

  handleVisibilityChange(event) {
    this.visiblePermissions = event.detail.visiblePermissions;
  }

  // --- User 1 Event Handlers ---
  handleUser1SearchInput(event) {
    const term = event.target.value;
    this.user1SearchTerm = term;
    this.showUser1Dropdown = true;
    debounce(async () => {
      try {
        this.user1Options = await searchUsers({ searchTerm: term });
      } catch {
        this.user1Options = [];
      }
    }, 300)();
  }

  handleUser1Focus() {
    this.showUser1Dropdown = true;
  }

  handleUser1Blur() {
    debounce(() => {
      this.showUser1Dropdown = false;
    })();
  }

  async handleUser1Select(event) {
    const userId = event.currentTarget.dataset.id;
    this.showUser1Dropdown = false;
    this.isUser1Loading = true;
    try {
      const details = await getUserPermissionDetails({ userId });
      this.user1Selected = details;
    } catch {
      this.user1Selected = null;
    } finally {
      this.isUser1Loading = false;
    }
  }

  handleUser1Clear() {
    this.user1Selected = null;
    this.user1SearchTerm = "";
  }

  // --- User 2 Event Handlers ---
  handleUser2SearchInput(event) {
    const term = event.target.value;
    this.user2SearchTerm = term;
    this.showUser2Dropdown = true;
    debounce(async () => {
      try {
        this.user2Options = await searchUsers({ searchTerm: term });
      } catch {
        this.user2Options = [];
      }
    }, 300)();
  }

  handleUser2Focus() {
    this.showUser2Dropdown = true;
  }

  handleUser2Blur() {
    debounce(() => {
      this.showUser2Dropdown = false;
    })();
  }

  async handleUser2Select(event) {
    const userId = event.currentTarget.dataset.id;
    this.showUser2Dropdown = false;
    this.isUser2Loading = true;
    try {
      const details = await getUserPermissionDetails({ userId });
      this.user2Selected = details;
    } catch {
      this.user2Selected = null;
    } finally {
      this.isUser2Loading = false;
    }
  }

  handleUser2Clear() {
    this.user2Selected = null;
    this.user2SearchTerm = "";
  }

  get user1Title() {
    return this.user1Selected
      ? `${this.user1Selected.userName}'s Permissions`
      : "User 1";
  }

  get user2Title() {
    return this.user2Selected
      ? `${this.user2Selected.userName}'s Permissions`
      : "User 2";
  }

  get user1ProfileIds() {
    return this.user1Selected?.profileId ? [this.user1Selected.profileId] : [];
  }

  get user1PermissionSetIds() {
    return this.user1Selected?.permissionSetIds || [];
  }

  get user2ProfileIds() {
    return this.user2Selected?.profileId ? [this.user2Selected.profileId] : [];
  }

  get user2PermissionSetIds() {
    return this.user2Selected?.permissionSetIds || [];
  }
}
