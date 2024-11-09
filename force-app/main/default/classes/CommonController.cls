public with sharing class CommonController {
  @AuraEnabled(cacheable=true)
  public static List<ComboboxOption> getPermissionSetOptions() {
    List<ComboboxOption> options = new List<ComboboxOption>();
    List<PermissionSet> permissionSets = PermissionSetSelector.newInstance()
      .getAllPermissionSets();

    for (PermissionSet ps : permissionSets) {
      ComboboxOption option = new ComboboxOption(ps.Id, ps.label);
      options.add(option);
    }
    return options;
  }

  @AuraEnabled(cacheable=true)
  public static List<ComboboxOption> getProfileOptions() {
    List<ComboboxOption> options = new List<ComboboxOption>();
    List<Profile> profiles = ProfileSelector.newInstance().getAllProfiles();

    for (Profile pro : profiles) {
      ComboboxOption option = new ComboboxOption(pro.Id, pro.Name);
      options.add(option);
    }
    return options;
  }

  public with sharing class ComboboxOption {
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String label;

    public ComboboxOption(String value, String label) {
      this.value = value;
      this.label = label;
    }
  }
}
