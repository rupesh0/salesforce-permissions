public with sharing class CommonController {
  @AuraEnabled(cacheable=true)
  public static List<ComboboxOption> getPermissionSetOptions() {
    List<ComboboxOption> options = new List<ComboboxOption>();
    for (PermissionSet ps : [
      SELECT Id, label
      FROM PermissionSet
      WHERE IsOwnedByProfile = FALSE
    ]) {
      ComboboxOption option = new ComboboxOption();
      option.value = ps.Id;
      option.label = ps.label;
      options.add(option);
    }
    return options;
  }

  @AuraEnabled(cacheable=true)
  public static List<ComboboxOption> getProfileOptions() {
    List<ComboboxOption> options = new List<ComboboxOption>();
    List<Profile> profiles = ProfileSelector.newInstance().getAllProfiles();

    for (Profile pro : profiles) {
      ComboboxOption option = new ComboboxOption();
      option.value = pro.Id;
      option.label = pro.Name;
      options.add(option);
    }
    return options;
  }

  public with sharing class ComboboxOption {
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String label;
  }
}
