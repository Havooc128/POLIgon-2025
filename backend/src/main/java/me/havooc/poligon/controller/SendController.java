/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/send")
public class SendController {
    @PostMapping
    public ResponseEntity<?> send(@RequestParam String message) {
        // TODO: Implement SMS sending via SMSAPI
        return ResponseEntity.ok().body("Message sent: " + message);
    }
} 