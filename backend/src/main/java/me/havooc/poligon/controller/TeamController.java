/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.controller;

import lombok.RequiredArgsConstructor;
import me.havooc.poligon.model.Team;
import me.havooc.poligon.repository.TeamRepository;
import me.havooc.poligon.security.AppWebSocketHandler;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@RestController
@RequestMapping("/api/teams")
@RequiredArgsConstructor
public class TeamController {
    private final TeamRepository teamRepository;
    private final AppWebSocketHandler ws;

    @GetMapping
    public ResponseEntity<List<Team>> getAll(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastUpdated) {
        if (lastUpdated != null && !teamRepository.existsUpdatedAfter(lastUpdated))
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        return ResponseEntity.ok(getSortedTeams());
    }

    @PostMapping
    public Team saveOrUpdate(@RequestBody Team team) {
        if (team.getId() == null || !teamRepository.existsById(team.getId())) {
            team.setId(null);
            Team t = teamRepository.save(team);
            ws.broadcast(getSortedTeams(), "teams");
            return t;
        } else {
            return teamRepository.findById(team.getId())
                    .map(existing -> {
                        existing.setName(team.getName());
                        existing.setCaptainName(team.getCaptainName());
                        existing.setMembers(team.getMembers());
                        existing.setImageUrl(team.getImageUrl());
                        existing.setPoints(team.getPoints());
                        existing.setLastModified(LocalDateTime.now());
                        Team t = teamRepository.save(existing);
                        ws.broadcast(getSortedTeams(), "teams");
                        return t;
                    })
                    .orElseGet(() -> {
                        // Jeśli nie ma w bazie — utwórz nową BEZ ID
                        Team newTeam = Team.builder()
                                .name(team.getName())
                                .captainName(team.getCaptainName())
                                .members(team.getMembers())
                                .imageUrl(team.getImageUrl())
                                .points(team.getPoints())
                                .lastModified(LocalDateTime.now())
                                .build();
                        Team t = teamRepository.save(newTeam);
                        ws.broadcast(getSortedTeams(), "teams");
                        return t;
                    });
        }
    }


    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        teamRepository.deleteById(id);
        ws.broadcast(getSortedTeams(), "teams");
    }

    private List<Team> getSortedTeams() {
        List<Team> teams = teamRepository.findAll();
        teams.sort(Comparator.comparing(
                (Team t) -> !t.getName().equals("Lotnicy")
        ).thenComparing(Team::getName));
        return teams;
    }
} 