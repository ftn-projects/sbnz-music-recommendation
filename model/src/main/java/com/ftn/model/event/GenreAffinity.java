package com.ftn.model.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.kie.api.definition.type.Expires;
import org.kie.api.definition.type.Role;
import org.kie.api.definition.type.Timestamp;

import java.io.Serializable;
import java.util.UUID;

@Role(Role.Type.EVENT)
@Timestamp("timestamp")
@Expires("2d")
@Data
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class GenreAffinity extends EventBase implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID userId;
    private UUID genreId;
    private int score;
    private long timestamp;
}
