package org.pl.userservice.service;

import lombok.RequiredArgsConstructor;
import org.pl.userservice.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

}
