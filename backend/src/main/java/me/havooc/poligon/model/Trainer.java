/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Trainer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Enumerated(EnumType.STRING)
    private TrainingPath path;
    @Column(length = 4096)
    private String description;
    private String imageUrl;
    @Column(length = 1028)
    private String trainings;
    @UpdateTimestamp
    private LocalDateTime lastModified;
    private Double imageAlignmentY;
}