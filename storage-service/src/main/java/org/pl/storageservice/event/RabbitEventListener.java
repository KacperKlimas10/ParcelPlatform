package org.pl.storageservice.event;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.pl.storageservice.service.StorageService;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class RabbitEventListener {

    private final StorageService storageService;

    @RabbitListener()
    public void consume(Event event) {}
}
