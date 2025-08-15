/**
 * @Author Łukasz Piętka (FUT 2025)
 */
package me.havooc.poligon.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Team {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String captainName;
    @ElementCollection(fetch = FetchType.EAGER)
    private List<String> members;
    private String imageUrl;
    private int points;
    @UpdateTimestamp
    private LocalDateTime lastModified;
}