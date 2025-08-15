/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyQuest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(length = 4096)
    private String message;
    private LocalDate day;
    @ManyToOne
    private Crew addedBy;
    @UpdateTimestamp
    private LocalDateTime lastModified;
}