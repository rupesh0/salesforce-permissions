import { LightningElement, track } from "lwc";
import { debounce } from "c/utils";
import searchUsers from "@salesforce/apex/CompareUsersController.searchUsers";
import getUserPermissionDetails from "@salesforce/apex/CompareUsersController.getUserPermissionDetails";

export default class CompareUsers extends LightningElement {
  // User 1 state
  user1SearchTerm = "";
  user1Options = [];
  user1Selected = null;
  @track user1DefaultFilters = null;
  @track user1CurrentFilters = null;
  @track user1AppliedFilters = null;
  showUser1Dropdown = false;
  isUser1Loading = false;

  // User 2 state
  user2SearchTerm = "";
  user2Options = [];
  user2Selected = null;
  @track user2DefaultFilters = null;
  @track user2CurrentFilters = null;
  @track user2AppliedFilters = null;
  showUser2Dropdown = false;
  isUser2Loading = false;

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
      const filters = {
        profileIds: [details.profileId],
        permissionSetIds: details.permissionSetIds || []
      };
      this.user1DefaultFilters = { ...filters };
      this.user1CurrentFilters = { ...filters };
      this.user1AppliedFilters = { ...filters };
    } catch {
      this.user1Selected = null;
      this.user1DefaultFilters = null;
      this.user1CurrentFilters = null;
      this.user1AppliedFilters = null;
    } finally {
      this.isUser1Loading = false;
    }
  }

  handleUser1Clear() {
    this.user1Selected = null;
    this.user1DefaultFilters = null;
    this.user1CurrentFilters = null;
    this.user1AppliedFilters = null;
    this.user1SearchTerm = "";
  }

  handleUser1Search(event) {
    this.user1SearchTerm = event.detail;
  }

  handleUser1FilterChange(event) {
    this.user1CurrentFilters = event.detail;
  }

  handleUser1Apply() {
    this.user1AppliedFilters = { ...this.user1CurrentFilters };
  }

  handleUser1ClearFilters() {
    this.user1CurrentFilters = { profileIds: [], permissionSetIds: [] };
    this.user1AppliedFilters = { profileIds: [], permissionSetIds: [] };
  }

  handleUser1ResetFilters() {
    this.user1CurrentFilters = { ...this.user1DefaultFilters };
    this.user1AppliedFilters = { ...this.user1DefaultFilters };
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
      const filters = {
        profileIds: [details.profileId],
        permissionSetIds: details.permissionSetIds || []
      };
      this.user2DefaultFilters = { ...filters };
      this.user2CurrentFilters = { ...filters };
      this.user2AppliedFilters = { ...filters };
    } catch {
      this.user2Selected = null;
      this.user2DefaultFilters = null;
      this.user2CurrentFilters = null;
      this.user2AppliedFilters = null;
    } finally {
      this.isUser2Loading = false;
    }
  }

  handleUser2Clear() {
    this.user2Selected = null;
    this.user2DefaultFilters = null;
    this.user2CurrentFilters = null;
    this.user2AppliedFilters = null;
    this.user2SearchTerm = "";
  }

  handleUser2Search(event) {
    this.user2SearchTerm = event.detail;
  }

  handleUser2FilterChange(event) {
    this.user2CurrentFilters = event.detail;
  }

  handleUser2Apply() {
    this.user2AppliedFilters = { ...this.user2CurrentFilters };
  }

  handleUser2ClearFilters() {
    this.user2CurrentFilters = { profileIds: [], permissionSetIds: [] };
    this.user2AppliedFilters = { profileIds: [], permissionSetIds: [] };
  }

  handleUser2ResetFilters() {
    this.user2CurrentFilters = { ...this.user2DefaultFilters };
    this.user2AppliedFilters = { ...this.user2DefaultFilters };
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

  get user1AppliedProfileIds() {
    return this.user1AppliedFilters?.profileIds || [];
  }

  get user1AppliedPermissionSetIds() {
    return this.user1AppliedFilters?.permissionSetIds || [];
  }

  get user2AppliedProfileIds() {
    return this.user2AppliedFilters?.profileIds || [];
  }

  get user2AppliedPermissionSetIds() {
    return this.user2AppliedFilters?.permissionSetIds || [];
  }
}
