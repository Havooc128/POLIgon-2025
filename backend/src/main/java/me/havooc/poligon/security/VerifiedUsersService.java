package me.havooc.poligon.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;

@Service
public class VerifiedUsersService {
    private final Set<String> allowedEmails = new HashSet<>();

    @PostConstruct
    public void loadAllowedEmails() throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("verified_users.json")) {
            if (is != null) {
                JsonNode root = mapper.readTree(is);
                for (JsonNode emailNode : root.path("allowedEmails")) {
                    allowedEmails.add(emailNode.asText());
                }
            }
        }
    }

    public boolean isEmailAllowed(String email) {
        return allowedEmails.contains(email);
    }
} 