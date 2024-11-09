public with sharing class Dependency {
  Type actual;
  Type mock;

  public Dependency(Type actual) {
    this.actual = actual;
  }

  public void setMock(Type mock) {
    this.mock = mock;
  }

  public Object newInstance() {
    if (mock != null) {
      return mock.newInstance();
    }
    return actual.newInstance();
  }
}
