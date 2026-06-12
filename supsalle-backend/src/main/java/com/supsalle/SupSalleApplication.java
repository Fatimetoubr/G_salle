package com.supsalle;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SupSalleApplication {
    public static void main(String[] args) {
        SpringApplication.run(SupSalleApplication.class, args);
    }
}
