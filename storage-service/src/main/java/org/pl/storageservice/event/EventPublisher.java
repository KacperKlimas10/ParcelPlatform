package org.pl.storageservice.event;

public interface EventPublisher {
    Event publish(Event event);
}
