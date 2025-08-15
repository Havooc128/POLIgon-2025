/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import lombok.RequiredArgsConstructor;
import me.havooc.poligon.model.ScheduleDay;
import me.havooc.poligon.model.TrainingPath;
import me.havooc.poligon.repository.ScheduleDayRepository;
import me.havooc.poligon.security.AppWebSocketHandler;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@RestController
@RequestMapping("/api/schedule")
@RequiredArgsConstructor
public class ScheduleController {
    private final ScheduleDayRepository scheduleDayRepository;
    private final AppWebSocketHandler ws;

    @GetMapping("/{id}")
    public ResponseEntity<List<ScheduleDay>> getByPath(@PathVariable("id") TrainingPath path,
                                                       @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastUpdated) {
        if (lastUpdated != null && !scheduleDayRepository.existsUpdatedAfter(lastUpdated))
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        List<ScheduleDay> days = scheduleDayRepository.findBySchedulePath(path);
        days.sort(Comparator.comparing(ScheduleDay::getDay));
        return ResponseEntity.ok(days);
    }

    @PostMapping
    public ResponseEntity<?> saveOrUpdate(@RequestBody ScheduleDay newDay) {
        if (newDay.getId() != null && scheduleDayRepository.existsById(newDay.getId())) {
            scheduleDayRepository.findById(newDay.getId()).ifPresent(existingDay -> {
                // Usuń stare elementy w bazie
                existingDay.getElements().clear();
                scheduleDayRepository.save(existingDay); // Zapamiętaj, że po clear() musisz zapisać!

                // Ustaw nowe elementy z id=null
                newDay.getElements().forEach(e -> e.setId(null));
                existingDay.getElements().addAll(newDay.getElements());

                existingDay.setDay(newDay.getDay());
                existingDay.setLastModified(LocalDateTime.now());
                existingDay.setSchedulePath(newDay.getSchedulePath());

                scheduleDayRepository.save(existingDay);
            });
        } else {
            newDay.setId(null);
            newDay.getElements().forEach(e -> e.setId(null));
            scheduleDayRepository.save(newDay);
        }

        broadcast(newDay.getSchedulePath());
        return ResponseEntity.ok().build();
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        ScheduleDay day = scheduleDayRepository.findById(id).orElse(null);
        if(day == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        TrainingPath path = day.getSchedulePath();
        scheduleDayRepository.deleteById(id);
        broadcast(path);
        return ResponseEntity.ok().build();
    }

    private void broadcast(TrainingPath path) {
        List<ScheduleDay> allForPath = scheduleDayRepository.findBySchedulePath(path);
        allForPath.sort(Comparator.comparing(ScheduleDay::getDay));
        ws.broadcast(allForPath, "schedule-" + path.name());
    }

} 