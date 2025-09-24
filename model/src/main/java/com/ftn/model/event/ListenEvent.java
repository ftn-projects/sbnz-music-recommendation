package com.ftn.model.event;

import java.io.Serializable;
import java.time.Instant;

import org.kie.api.definition.type.Expires;
import org.kie.api.definition.type.Role;
import org.kie.api.definition.type.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Data;

@Role(Role.Type.EVENT)
@Timestamp("timestamp")
@Expires("3h")
@Data
@AllArgsConstructor
public class ListenEvent implements Serializable {

    private static final long serialVersionUID = 1L;

    private String userId;
    private String trackId;
    private Integer duration;
    private Instant timestamp;
}
