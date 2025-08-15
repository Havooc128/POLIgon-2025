/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.sql.Timestamp;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Song {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    @Column(length = 4096)
    private String songText;
    @UpdateTimestamp
    private LocalDateTime lastModified;
}