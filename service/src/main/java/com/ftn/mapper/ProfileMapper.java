package com.ftn.mapper;

import com.ftn.model.*;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ProfileMapper {
    @Mapping(target = "alignedGenres", expression = "java(new java.util.HashSet<>())")
    Profile toProfile(ProfileEntity entity);

    AudioFeatures toProfileFeatures(AudioFeaturesEntity entityFeatures);
}
