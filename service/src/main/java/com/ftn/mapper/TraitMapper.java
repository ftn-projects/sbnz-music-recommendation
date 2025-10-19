package com.ftn.mapper;

import com.ftn.model.*;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface TraitMapper {
    Trait toTrait(TraitEntity entity);
}

