public with sharing class CommonController {
  @AuraEnabled(cacheable=true)
  public static List<ComboboxOption> getPermissionSetOptions() {
    List<ComboboxOption> options = new List<ComboboxOption>();
    for (PermissionSet ps : [
      SELECT Id, label
      FROM PermissionSet
      WHERE IsCustom = TRUE
    ]) {
      ComboboxOption option = new ComboboxOption();
      option.value = ps.Id;
      option.label = ps.label;
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
