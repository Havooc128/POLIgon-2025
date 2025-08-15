/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import lombok.RequiredArgsConstructor;
import me.havooc.poligon.model.Crew;
import me.havooc.poligon.repository.CrewRepository;
import me.havooc.poligon.security.AppWebSocketHandler;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/crew")
@RequiredArgsConstructor
public class CrewController {
    private final CrewRepository crewRepository;
    private final AppWebSocketHandler ws;

    @GetMapping
    public ResponseEntity<List<Crew>> getAll(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastUpdated) {
        if (lastUpdated != null && !crewRepository.existsUpdatedAfter(lastUpdated))
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        return ResponseEntity.ok(crewRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Crew> createOrUpdateCrew(@RequestBody Crew crew) {
        if (crew.getId() == null || !crewRepository.existsById(crew.getId())) {
            Crew saved = crewRepository.save(crew);
            ws.broadcast(crewRepository.findAll(), "crew");
            return ResponseEntity.ok(saved);
        } else {
            return crewRepository.findById(crew.getId())
                    .map(existing -> {
                        existing.setName(crew.getName());
                        existing.setRoom(crew.getRoom());
                        existing.setRole(crew.getRole());
                        existing.setImageUrl(crew.getImageUrl());
                        existing.setEmail(crew.getEmail());
                        existing.setSobrietyDay(crew.getSobrietyDay());
                        existing.setDescription(crew.getDescription());
                        existing.setCrewQuest(crew.getCrewQuest());
                        existing.setPhoneNumber(crew.getPhoneNumber());
                        existing.setSuperAdmin(crew.isSuperAdmin());
                        existing.setLastModified(LocalDateTime.now());
                        existing.setImageAlignmentY(crew.getImageAlignmentY());
                        Crew updated = crewRepository.save(existing);
                        ws.broadcast(crewRepository.findAll(), "crew");
                        return ResponseEntity.ok(updated);
                    })
                    .orElseGet(() -> ResponseEntity.notFound().build());
        }
    }

    @GetMapping("/me")
    public ResponseEntity<Crew> getMe(Authentication authentication) {
        String email = authentication.getName();

        Crew crew = crewRepository.findAll().stream()
                .filter(c -> c.getEmail().equalsIgnoreCase(email))
                .findAny().orElse(null);
        if (crew == null) {
            crew = Crew.builder()
                    .name("Imię i Nazwisko")
                    .room("B/D")
                    .role("B/D")
                    .isSuperAdmin(false)
                    .imageUrl("assets/placeholder.webp")
                    .sobrietyDay(java.time.LocalDate.now())
                    .description("B/D")
                    .crewQuest("B/D")
                    .phoneNumber("B/D")
                    .email(email)
                    .lastModified(LocalDateTime.now())
                    .imageAlignmentY(0.0)
                    .build();
            crewRepository.save(crew);
            ws.broadcast(crewRepository.findAll(), "crew");
        }
        return ResponseEntity.ok(crew);
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        crewRepository.deleteById(id);
        ws.broadcast(crewRepository.findAll(), "crew");
        return ResponseEntity.ok().build();
    }
} 