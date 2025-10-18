package com.ftn.controller;

import java.net.URI;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.kie.api.runtime.KieSession;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ftn.model.event.EventBase;
import com.ftn.model.event.LikeEvent;
import com.ftn.model.event.ListenEvent;
import com.ftn.model.event.SkipEvent;
import com.ftn.dto.LikeDTO;
import com.ftn.dto.ListenDTO;
import com.ftn.dto.SkipDTO;

@RestController
@RequestMapping("/user-activity")
public class UserActivityController {
    private final KieSession ksession;

    public UserActivityController(@Qualifier("musicCepKsession") KieSession musicCepKsession) {
        this.ksession = musicCepKsession;
    }

    @PostMapping("/listen")
    public ResponseEntity<Void> listen(@RequestBody ListenDTO d) {
        ksession.insert(new ListenEvent(d.userId, d.trackId, d.duration));
        return ResponseEntity.created(URI.create("/user-activity/facts/" + d.userId)).build();
    }

    @PostMapping("/like")
    public ResponseEntity<Void> like(@RequestBody LikeDTO d) {
        ksession.insert(new LikeEvent(d.userId, d.trackId));
        return ResponseEntity.created(URI.create("/user-activity/facts/" + d.userId)).build();
    }

    @PostMapping("/skip")
    public ResponseEntity<Void> skip(@RequestBody SkipDTO d) {
        ksession.insert(new SkipEvent(d.userId, d.trackId, d.duration));
        return ResponseEntity.created(URI.create("/user-activity/facts/" + d.userId)).build();
    }

    @GetMapping("/facts/{userId}")
    public ResponseEntity<Set<Object>> getFacts(@PathVariable UUID userId) {
        Set<Object> result = new HashSet<>();

        // Query the main session for rule-generated facts
        ksession.getObjects(o -> {
            if (o instanceof EventBase) {
                EventBase event = (EventBase) o;
                return event.getUserId().equals(userId);
            }
            // Also include GenreAffinity facts
            if (o.getClass().getSimpleName().equals("GenreAffinity")) {
                try {
                    java.lang.reflect.Field userIdField = o.getClass().getDeclaredField("userId");
                    userIdField.setAccessible(true);
                    UUID objectUserId = (UUID) userIdField.get(o);
                    return objectUserId.equals(userId);
                } catch (Exception e) {
                    return false;
                }
            }
            return false;
        }).forEach(obj -> {
            Map<String, Object> wrapper = new HashMap<>();
            wrapper.put("event", obj.getClass().getSimpleName());
            wrapper.put("data", obj);
            result.add(wrapper);
        });

        return ResponseEntity.ok(result);
    }
}