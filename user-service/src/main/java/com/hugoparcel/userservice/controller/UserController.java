package com.hugoparcel.userservice.controller;

import lombok.RequiredArgsConstructor;
import com.hugoparcel.sharedresources.dto.UserDto;
import com.hugoparcel.userservice.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<Void> createUser(@RequestBody UserDto userDto) {
        userService.createUser(userDto.getUsername(), userDto.getEmail());
        return ResponseEntity
                .noContent()
                .build();
    }
}
