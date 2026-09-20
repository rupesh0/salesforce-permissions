public without sharing class DescribeCacheService {
  // In-memory static cache for the transaction
  private static Map<String, Object> memoryCache = new Map<String, Object>();
  private static final String PARTITION_NAME = 'local.PermissionsPartition';

  /**
   * Retrieves an object from cache (Memory -> Platform Cache).
   */
  public static Object get(String key) {
    if (memoryCache.containsKey(key)) {
      return memoryCache.get(key);
    }
    try {
      Cache.OrgPartition part = Cache.Org.getPartition(PARTITION_NAME);
      if (part != null && part.contains(key)) {
        Object val = part.get(key);
        memoryCache.put(key, val);
        return val;
      }
    } catch (Exception e) {
      // Platform cache partition not provisioned or configured in this org;
      // safely falls back to memory cache.
    }
    return null;
  }

  /**
   * Stores an object into cache (Memory -> Platform Cache if available).
   */
  public static void put(String key, Object value, Integer ttlSeconds) {
    if (key == null || value == null)
      return;
    memoryCache.put(key, value);
    try {
      Cache.OrgPartition part = Cache.Org.getPartition(PARTITION_NAME);
      if (part != null) {
        part.put(key, value, ttlSeconds != null ? ttlSeconds : 3600);
      }
    } catch (Exception e) {
      // Graceful fallback to memory cache
    }
  }

  /**
   * Clears the in-memory cache and platform cache for a key.
   */
  public static void remove(String key) {
    memoryCache.remove(key);
    try {
      Cache.OrgPartition part = Cache.Org.getPartition(PARTITION_NAME);
      if (part != null) {
        part.remove(key);
      }
    } catch (Exception e) {
      // Ignored
    }
  }
}
