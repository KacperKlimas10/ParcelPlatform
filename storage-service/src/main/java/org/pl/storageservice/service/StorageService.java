package org.pl.storageservice.service;

import lombok.RequiredArgsConstructor;
import org.pl.storageservice.event.Event;
import org.pl.storageservice.event.EventPublisher;
import org.pl.storageservice.event.FileUploadedEvent;
import org.pl.storageservice.storage.StorageRepository;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@Service
@RequiredArgsConstructor
public class StorageService {

    private final StorageRepository storageRepository;
    private final EventPublisher eventPublisher;

    @Async
    public void uploadFileRequest(String filename) {
        CompletableFuture.completedFuture(
            eventPublisher.publish(
                FileUploadedEvent.builder()
                    .putSignedUrl(storageRepository.putSignedUrl(filename + UUID.randomUUID(), 5))
                    .getSignedUrl(storageRepository.getSignedUrl(filename, 5))
                    .fileUUID(UUID.randomUUID())
                    .fileName(filename)
                    .build()
            )
        );
    }
}
