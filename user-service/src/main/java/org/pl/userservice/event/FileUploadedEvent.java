package org.pl.userservice.event;

import lombok.Builder;
import lombok.Getter;
import org.pl.userservice.event.Event;

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
