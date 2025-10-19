package com.ftn.util;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public final class Page {
    private final long offset;
    private final long limit;
}
