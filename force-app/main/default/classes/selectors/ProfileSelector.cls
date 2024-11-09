public with sharing class ProfileSelector implements IProfileSelector {
  public static final Dependency impl = new Dependency(ProfileSelector.class);

  public static IProfileSelector newInstance() {
    return (IProfileSelector) impl.newInstance();
  }

  public List<Profile> getAllProfiles() {
    return [SELECT Id, Name FROM Profile];
  }
}
