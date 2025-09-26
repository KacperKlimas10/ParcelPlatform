package com.hugoparcel.userservice.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import com.hugoparcel.sharedresources.event.EventPublisher;
import com.hugoparcel.userservice.model.UserModel;
import com.hugoparcel.userservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Qualifier("RabbitMQ")
    private final EventPublisher eventPublisher;

    @Transactional
    public void createUser(String username, String email) {
        userRepository.save(UserModel.builder()
                .username(username)
                .email(email)
                .build()

        );
    }
}
