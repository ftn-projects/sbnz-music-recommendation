package com.ftn.service;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import org.kie.api.runtime.rule.EntryPoint;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ftn.model.event.LikeEvent;
import com.ftn.model.event.ListenEvent;
import com.ftn.model.event.SkipEvent;
import com.ftn.service.dto.LikeDTO;
import com.ftn.service.dto.ListenDTO;
import com.ftn.service.dto.SkipDTO;

@RestController
@RequestMapping("/user-activity")
public class UserActivityController {
    private final EntryPoint ep;

    public UserActivityController(EntryPoint musicEventsEntryPoint) {
        this.ep = musicEventsEntryPoint;
    }

    @PostMapping("/listen")
    public ResponseEntity<Void> listen(@RequestBody ListenDTO d) {
        ep.insert(new ListenEvent(d.userId, d.trackId, d.duration, Instant.now()));
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/like")
    public ResponseEntity<Void> like(@RequestBody LikeDTO d) {
        ep.insert(new LikeEvent(d.userId, d.trackId, Instant.now()));
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/skip")
    public ResponseEntity<Void> skip(@RequestBody SkipDTO d) {
        ep.insert(new SkipEvent(d.userId, d.trackId, d.duration, Instant.now()));
        return ResponseEntity.accepted().build();
    }

    @GetMapping("/facts/{userId}")
    public ResponseEntity<Set<?>> getFacts(@PathVariable UUID userId) {
        return ResponseEntity.ok(new HashSet<>(ep.getObjects(o -> {
            if (o instanceof ListenEvent) {
                ListenEvent le = (ListenEvent) o;
                return le.getUserId().equals(userId);
            } else if (o instanceof LikeEvent) {
                LikeEvent lie = (LikeEvent) o;
                return lie.getUserId().equals(userId);
            } else if (o instanceof SkipEvent) {
                SkipEvent se = (SkipEvent) o;
                return se.getUserId().equals(userId);
            }
            return false;
        })));
    }
}