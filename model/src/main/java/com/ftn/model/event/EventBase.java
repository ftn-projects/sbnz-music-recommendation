package com.ftn.model.event;

import java.time.Instant;
import java.util.UUID;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public abstract class EventBase {
    protected UUID userId;
    protected long timestamp;

    public EventBase(UUID userId) {
        this.userId = userId;
        this.timestamp = Instant.now().toEpochMilli();
    }
}
