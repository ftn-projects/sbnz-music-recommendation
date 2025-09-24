package com.ftn.model.event;

import java.io.Serializable;
import java.util.UUID;

import org.kie.api.definition.type.Expires;
import org.kie.api.definition.type.Role;
import org.kie.api.definition.type.Timestamp;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Role(Role.Type.EVENT)
@Timestamp("timestamp")
@Expires("3h")
@Data
@EqualsAndHashCode(callSuper = true)
public class GenreDislikedEvent extends EventBase implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID genreId;

    public GenreDislikedEvent(UUID userId, UUID genreId) {
        super(userId);
        this.genreId = genreId;
    }
}
