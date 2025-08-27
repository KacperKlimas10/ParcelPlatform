package org.pl.storageservice.controller;

import lombok.RequiredArgsConstructor;
import org.pl.storageservice.event.Event;
import org.pl.storageservice.service.StorageService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping("/api/v1/storage")
@RequiredArgsConstructor
public class StorageController {

    private final StorageService storageService;

    @PostMapping("/create")
    public CompletableFuture<Event> createEvent() {
        return null;
    }
}