package org.pl.storageservice.event;

import lombok.Builder;
import lombok.Getter;

import java.net.URL;
import java.util.UUID;

@Getter
@Builder
public class FileUploadedEvent extends Event {
    private final URL putSignedUrl;
    private final URL getSignedUrl;
    private final UUID fileUUID;
    private final String fileName;
}
