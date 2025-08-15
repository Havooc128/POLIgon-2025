/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import lombok.RequiredArgsConstructor;
import me.havooc.poligon.model.Trainer;
import me.havooc.poligon.repository.TrainerRepository;
import me.havooc.poligon.security.AppWebSocketHandler;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/trainers")
@RequiredArgsConstructor
public class TrainerController {
    private final TrainerRepository trainerRepository;
    private final AppWebSocketHandler ws;

    @GetMapping
    public ResponseEntity<List<Trainer>> getAll(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastUpdated) {
        if (lastUpdated != null && !trainerRepository.existsUpdatedAfter(lastUpdated))
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        return ResponseEntity.ok(trainerRepository.findAll());
    }

    @PostMapping
    public Trainer saveOrUpdate(@RequestBody Trainer trainer) {
        if (trainer.getId() == null || !trainerRepository.existsById(trainer.getId())) {
            trainer.setId(null);
            Trainer newTrainer = trainerRepository.save(trainer);
            ws.broadcast(trainerRepository.findAll(), "trainers");
            return newTrainer;
        } else {
            return trainerRepository.findById(trainer.getId())
                    .map(existing -> {
                        existing.setName(trainer.getName());
                        existing.setPath(trainer.getPath());
                        existing.setDescription(trainer.getDescription());
                        existing.setImageUrl(trainer.getImageUrl());
                        existing.setTrainings(trainer.getTrainings());
                        existing.setLastModified(LocalDateTime.now());
                        existing.setImageAlignmentY(trainer.getImageAlignmentY());
                        Trainer updated = trainerRepository.save(existing);
                        ws.broadcast(trainerRepository.findAll(), "trainers");
                        return updated;
                    })
                    .orElseGet(() -> {
                        // Jeśli nie ma w bazie — utwórz nowy BEZ ID
                        Trainer newTrainer = Trainer.builder()
                                .name(trainer.getName())
                                .path(trainer.getPath())
                                .description(trainer.getDescription())
                                .imageUrl(trainer.getImageUrl())
                                .trainings(trainer.getTrainings())
                                .lastModified(LocalDateTime.now())
                                .imageAlignmentY(trainer.getImageAlignmentY())
                                .build();
                        Trainer saved = trainerRepository.save(newTrainer);
                        ws.broadcast(trainerRepository.findAll(), "trainers");
                        return saved;
                    });
        }
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        trainerRepository.deleteById(id);
        ws.broadcast(trainerRepository.findAll(), "trainers");
    }
} 