/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import lombok.RequiredArgsConstructor;
import me.havooc.poligon.model.Song;
import me.havooc.poligon.repository.SongRepository;
import me.havooc.poligon.security.AppWebSocketHandler;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/songbook")
@RequiredArgsConstructor
public class SongController {
    private final SongRepository songRepository;
    private final AppWebSocketHandler ws;

    @GetMapping
    public ResponseEntity<List<Song>> getAll(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastUpdated) {
        if (lastUpdated != null && !songRepository.existsUpdatedAfter(lastUpdated))
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        return ResponseEntity.ok(songRepository.findAll());
    }

    @PostMapping
    public Song saveOrUpdate(@RequestBody Song song) {
        if (song.getId() == null || !songRepository.existsById(song.getId())) {
            // Nowa piosenka — insert
            song.setId(null);
            Song s = songRepository.save(song);
            ws.broadcast(songRepository.findAll(), "songbook");
            return s;
        } else {
            // Sprawdź, czy istnieje
            return songRepository.findById(song.getId())
                    .map(existing -> {
                        existing.setTitle(song.getTitle());
                        existing.setSongText(song.getSongText());
                        existing.setLastModified(LocalDateTime.now());
                        Song updated = songRepository.save(existing);
                        ws.broadcast(songRepository.findAll(), "songbook");
                        return updated;
                    })
                    .orElseGet(() -> {
                        // Jeśli nie istnieje, utwórz nową BEZ ID
                        Song newSong = Song.builder()
                                .title(song.getTitle())
                                .songText(song.getSongText())
                                .lastModified(LocalDateTime.now())
                                .build();
                        Song updated = songRepository.save(newSong);
                        ws.broadcast(songRepository.findAll(), "songbook");
                        return updated;
                    });
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        songRepository.deleteById(id);
        ws.broadcast(songRepository.findAll(), "songbook");
        return ResponseEntity.ok().build();
    }
} 