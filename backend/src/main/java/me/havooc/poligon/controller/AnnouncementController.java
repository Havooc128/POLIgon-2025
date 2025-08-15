/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import lombok.RequiredArgsConstructor;
import me.havooc.poligon.model.Announcement;
import me.havooc.poligon.model.Crew;
import me.havooc.poligon.repository.AnnouncementRepository;
import me.havooc.poligon.repository.CrewRepository;
import me.havooc.poligon.security.AppWebSocketHandler;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementRepository announcementRepository;
    private final CrewRepository crewRepository;
    private final AppWebSocketHandler ws;

    @GetMapping
    public ResponseEntity<List<Announcement>> getAll(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastUpdated) {
        if (lastUpdated != null && !announcementRepository.existsUpdatedAfter(lastUpdated))
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        return ResponseEntity.ok(announcementRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> createOrUpdateAnnouncement(@RequestBody Announcement announcement) {
        if (announcement.getAuthor() == null || announcement.getAuthor().getId() == null) {
            return ResponseEntity.badRequest().body("Author must be specified with valid id");
        }

        // Sprawdź, czy autor istnieje
        Optional<Crew> authorOpt = crewRepository.findById(announcement.getAuthor().getId());
        if (authorOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Author with given id does not exist");
        }

        if (announcement.getId() == null || !announcementRepository.existsById(announcement.getId())) {
            announcement = Announcement.builder()
                    .text(announcement.getText())
                    .author(authorOpt.get())
                    .publishDate(announcement.getPublishDate())
                    .lastModified(LocalDateTime.now())
                    .build();
            Announcement saved = announcementRepository.save(announcement);
            ws.broadcast(getSortedAnnouncements(), "announcements");
            return ResponseEntity.ok(saved);
        } else {
            Announcement finalAnnouncement = announcement;
            return announcementRepository.findById(announcement.getId())
                    .map(existing -> {
                        existing.setText(finalAnnouncement.getText());
                        existing.setAuthor(authorOpt.get());
                        existing.setPublishDate(finalAnnouncement.getPublishDate());
                        existing.setLastModified(LocalDateTime.now());
                        Announcement updated = announcementRepository.save(existing);
                        ws.broadcast(getSortedAnnouncements(), "announcements");
                        return ResponseEntity.ok(updated);
                    })
                    .orElseGet(() -> ResponseEntity.notFound().build());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        announcementRepository.deleteById(id);
        ws.broadcast(getSortedAnnouncements(), "announcements");
        return ResponseEntity.ok().build();
    }

    public List<Announcement> getSortedAnnouncements() {
        List<Announcement> announcements = announcementRepository.findAll();
        announcements.sort((a1, a2) -> a2.getPublishDate().compareTo(a1.getPublishDate()));
        return announcements;
    }
}
