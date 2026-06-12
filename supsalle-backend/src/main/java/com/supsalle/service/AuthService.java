package com.supsalle.service;

import com.supsalle.dto.AuthDto;
import com.supsalle.entity.User;
import com.supsalle.exception.GlobalExceptionHandler.BadRequestException;
import com.supsalle.exception.GlobalExceptionHandler.ConflictException;
import com.supsalle.repository.UserRepository;
import com.supsalle.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    // ── INSCRIPTION directe (sans OTP) ──────────────────────
    @Transactional
    public Map<String, String> register(AuthDto.RegisterRequest request) {

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Cet email est deja utilise.");
        }

        User user = new User();
        user.setFullname(request.getFullname());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(User.Role.user);
        user.setIsActive(true);

        userRepository.save(user);

        return Map.of(
            "message", "Compte cree avec succes. Vous pouvez maintenant vous connecter.",
            "email", request.getEmail()
        );
    }

    // ── CONNEXION directe (sans verification OTP) ───────────
    public AuthDto.LoginResponse login(AuthDto.LoginRequest request) {

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadRequestException("Email ou mot de passe incorrect."));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BadRequestException("Email ou mot de passe incorrect.");
        }

        if (!Boolean.TRUE.equals(user.getIsActive())) {
            throw new BadRequestException("Votre compte est desactive. Contactez l'administrateur.");
        }

        String token = jwtUtil.generateToken(
                user.getEmail(),
                user.getRole().name(),
                user.getId()
        );

        return new AuthDto.LoginResponse(
                token,
                user.getRole().name(),
                user.getId(),
                user.getEmail(),
                user.getFullname()
        );
    }
}
