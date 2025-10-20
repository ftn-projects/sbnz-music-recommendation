package com.ftn.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
public class LibraryUpdateDTO {
    public UUID userId;
    public UUID trackId;
    public Boolean add;
}
