package org.pl.storageservice.exception;

public class EventPublishException extends Exception {
    public EventPublishException(Throwable throwable) {
        super("EventPublishException: ", throwable);
    }
}
