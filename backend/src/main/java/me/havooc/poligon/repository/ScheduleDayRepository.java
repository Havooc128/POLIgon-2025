/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.repository;

import me.havooc.poligon.model.ScheduleDay;
import me.havooc.poligon.model.TrainingPath;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface ScheduleDayRepository extends JpaRepository<ScheduleDay, Long> {
    List<ScheduleDay> findBySchedulePath(TrainingPath path);

    @Query("SELECT COUNT(i) > 0 FROM ScheduleDay i WHERE i.lastModified > :lastUpdated")
    boolean existsUpdatedAfter(@Param("lastUpdated") LocalDateTime lastUpdated);
}