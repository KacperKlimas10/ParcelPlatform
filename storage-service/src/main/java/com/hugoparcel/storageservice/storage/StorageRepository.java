package com.hugoparcel.storageservice.storage;

import java.net.URL;

public interface StorageRepository {
    URL getSignedUrl(String filename);
    URL putSignedUrl(String filename);
}
