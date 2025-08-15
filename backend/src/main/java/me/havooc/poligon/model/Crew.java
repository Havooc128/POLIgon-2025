/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Crew {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String room;
    private String role;
    private String imageUrl;
    private String email;
    private LocalDate sobrietyDay;
    @Column(length = 4096)
    private String description;
    @Column(length = 2048)
    private String crewQuest;
    private String phoneNumber;
    private boolean isSuperAdmin;
    @UpdateTimestamp
    private LocalDateTime lastModified;
    private Double imageAlignmentY;
}