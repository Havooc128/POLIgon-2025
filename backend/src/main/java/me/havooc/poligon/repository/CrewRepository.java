/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.repository;

import me.havooc.poligon.model.Crew;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;

public interface CrewRepository extends JpaRepository<Crew, Long> {
    @Query("SELECT COUNT(i) > 0 FROM Crew i WHERE i.lastModified > :lastUpdated")
    boolean existsUpdatedAfter(@Param("lastUpdated") LocalDateTime lastUpdated);
}