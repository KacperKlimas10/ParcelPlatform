package com.hugoparcel.userservice.event;

import com.hugoparcel.sharedresources.event.Event;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.hugoparcel.userservice.service.UserService;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class RabbitEventListener {

    private final UserService userService;

    @RabbitListener(queues = "storage-user")
    public void consume(Event event) {
        System.out.println(event.getEventUUID() + "\n" + event.getLocalDateTime());
    }
}
