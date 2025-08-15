/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import lombok.RequiredArgsConstructor;
import me.havooc.poligon.model.Crew;
import me.havooc.poligon.model.DailyQuest;
import me.havooc.poligon.repository.CrewRepository;
import me.havooc.poligon.repository.DailyQuestRepository;
import me.havooc.poligon.security.AppWebSocketHandler;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/daily")
@RequiredArgsConstructor
public class DailyQuestController {
    private final DailyQuestRepository dailyQuestRepository;
    private final CrewRepository crewRepository;
    private final AppWebSocketHandler ws;

    @GetMapping
    public ResponseEntity<List<DailyQuest>> getAll(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastUpdated) {
        if (lastUpdated != null && !dailyQuestRepository.existsUpdatedAfter(lastUpdated))
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        return ResponseEntity.ok(dailyQuestRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> createOrUpdateDailyQuest(@RequestBody DailyQuest dailyQuest) {
        if (dailyQuest.getAddedBy() == null || dailyQuest.getAddedBy().getId() == null) {
            return ResponseEntity.badRequest().body("Author must be specified with valid id");
        }

        // Sprawdź, czy autor istnieje
        Optional<Crew> authorOpt = crewRepository.findById(dailyQuest.getAddedBy().getId());
        if (authorOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Author with given id does not exist");
        }

        if (dailyQuest.getId() == null || !dailyQuestRepository.existsById(dailyQuest.getId())) {
            dailyQuest = DailyQuest.builder()
                    .message(dailyQuest.getMessage())
                    .addedBy(authorOpt.get())
                    .day(dailyQuest.getDay())
                    .lastModified(LocalDateTime.now())
                    .build();
            DailyQuest saved = dailyQuestRepository.save(dailyQuest);
            ws.broadcast(dailyQuestRepository.findAll(), "daily");
            return ResponseEntity.ok(saved);
        } else {
            DailyQuest finalAnnouncement = dailyQuest;
            return dailyQuestRepository.findById(dailyQuest.getId())
                    .map(existing -> {
                        existing.setMessage(finalAnnouncement.getMessage());
                        existing.setAddedBy(authorOpt.get());
                        existing.setDay(finalAnnouncement.getDay());
                        existing.setLastModified(LocalDateTime.now());
                        DailyQuest updated = dailyQuestRepository.save(existing);
                        ws.broadcast(dailyQuestRepository.findAll(), "daily");
                        return ResponseEntity.ok(updated);
                    })
                    .orElseGet(() -> ResponseEntity.notFound().build());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        dailyQuestRepository.deleteById(id);
        ws.broadcast(dailyQuestRepository.findAll(), "daily");
        return ResponseEntity.ok().build();
    }
} 