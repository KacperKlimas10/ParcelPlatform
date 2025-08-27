package org.pl.storageservice.storage;

import java.net.URL;

public interface StorageRepository {
    URL getSignedUrl(String filename, int durationMinutes);
    URL putSignedUrl(String filename, int durationMinutes);
}
