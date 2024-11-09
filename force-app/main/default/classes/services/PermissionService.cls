public with sharing class PermissionService {
  public static final Dependency impl = new Dependency(
    PermissionServiceImpl.class
  );

  public static API newInstance() {
    return (API) impl.newInstance();
  }

  public interface API {
  }
}
