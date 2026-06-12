package com.supsalle.service;

import com.supsalle.dto.UserDto;
import com.supsalle.entity.User;
import com.supsalle.exception.GlobalExceptionHandler.BadRequestException;
import com.supsalle.exception.GlobalExceptionHandler.ResourceNotFoundException;
import com.supsalle.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public List<UserDto.Response> getAllUsers() {
        return userRepository.findByRole(User.Role.user)
                .stream()
                .map(UserDto.Response::fromEntity)
                .collect(Collectors.toList());
    }

    public UserDto.Response getUserById(Integer id) {
        return UserDto.Response.fromEntity(findUserOrThrow(id));
    }

    // ✅ UPDATE SANS EMAIL
    @Transactional
    public UserDto.Response updateUser(Integer id, UserDto.UpdateRequest request) {
        User user = findUserOrThrow(id);

        user.setFullname(request.getFullname());

        // ❌ suppression modification email
        // user.setEmail(request.getEmail());

        if (request.getIsActive() != null) {
            user.setIsActive(request.getIsActive());
        }

        if (request.getRole() != null) {
            try {
                user.setRole(User.Role.valueOf(request.getRole()));
            } catch (IllegalArgumentException e) {
                throw new BadRequestException("Role invalide : " + request.getRole());
            }
        }

        userRepository.save(user);
        return UserDto.Response.fromEntity(user);
    }

    //  désactiver utilisateur
    @Transactional
    public UserDto.Response deactivateUser(Integer id) {
        User user = findUserOrThrow(id);
        user.setIsActive(false);
        userRepository.save(user);
        return UserDto.Response.fromEntity(user);
    }

    //  SUPPRESSION utilisateur
    @Transactional
    public void deleteUser(Integer id) {
        User user = findUserOrThrow(id);
        userRepository.delete(user);
    }

    public UserDto.Response getMyProfile(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouve."));
        return UserDto.Response.fromEntity(user);
    }

    private User findUserOrThrow(Integer id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouve : " + id));
    }
}