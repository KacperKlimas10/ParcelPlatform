package org.pl.storageservice.storage;

import java.net.URL;

public interface StorageRepository {
    public URL getSignedUrl(String filename, int durationMinutes);
    public URL putSignedUrl(String filename, int durationMinutes);
}
