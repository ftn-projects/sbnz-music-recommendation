package com.ftn.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
public class RequestContext {
    private final Set<UUID> libraryTrackIds;
    private final Set<UUID> recentTrackIds;
}
