package org.pl.storageservice.event;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class RabbitEventPublisher implements EventPublisher {

    private final RabbitTemplate rabbitTemplate;
    private final Map<Class<? extends Event>, Map<String, String>> configMap = Map.of(
        FileUploadedEvent.class, Map.of("exchange","storage.events",
                                        "routingKey", "file.uploaded")
    );
    @Override
    public Event publish(Event event) {
        try {
            rabbitTemplate.convertAndSend(
                    configMap.get(event.getClass()).get("exchange"),
                    configMap.get(event.getClass()).get("routingKey"),
                    event
            );
            return event;
        } catch (AmqpException amqpException) {
            log.error("RabbitEventPublisher: ", amqpException.getCause());
        } return null;
    }
}
