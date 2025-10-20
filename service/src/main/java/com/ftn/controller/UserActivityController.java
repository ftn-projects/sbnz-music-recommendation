package com.ftn.controller;

import com.ftn.dto.LikeDTO;
import com.ftn.dto.ListenDTO;
import com.ftn.dto.SkipDTO;
import com.ftn.model.event.LikeEvent;
import com.ftn.model.event.ListenEvent;
import com.ftn.model.event.SkipEvent;
import com.ftn.service.UserActivityService;
import org.kie.api.runtime.KieSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;

@RestController
@RequestMapping("/api/activity")
public class UserActivityController {
    private static final Logger log = LoggerFactory.getLogger(UserActivityController.class);

    private final KieSession musicCepKsession;
    private final UserActivityService userActivityService;

    public UserActivityController(KieSession musicCepKsession, UserActivityService userActivityService) {
        this.musicCepKsession = musicCepKsession;
        this.userActivityService = userActivityService;
    }

    @PostMapping("/listen")
    public ResponseEntity<Void> listen(@RequestBody ListenDTO dto) {
        log.info("Inserting ListenEvent: userId={}, trackId={}, duration={}", dto.userId, dto.trackId, dto.duration);

        var event = new ListenEvent(dto.userId, dto.trackId, dto.duration);
        userActivityService.onListenEvent(event);
        musicCepKsession.insert(event);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/like")
    public ResponseEntity<Void> like(@RequestBody LikeDTO dto) {
        log.info("Inserting LikeEvent: userId={}, trackId={}", dto.userId, dto.trackId);

        var event = new LikeEvent(dto.userId, dto.trackId);
        musicCepKsession.insert(event);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/skip")
    public ResponseEntity<Void> skip(@RequestBody SkipDTO dto) {
        log.info("Inserting SkipEvent: userId={}, trackId={}, duration={}", dto.userId, dto.trackId, dto.duration);

        var event = new SkipEvent(dto.userId, dto.trackId, dto.duration);
        musicCepKsession.insert(event);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
}
