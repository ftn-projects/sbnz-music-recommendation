package com.ftn.mapper;

import com.ftn.model.Profile;
import com.ftn.model.ProfileEntity;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper(componentModel = "spring")
public interface ProfileMapper {
    ProfileMapper INSTANCE = Mappers.getMapper(ProfileMapper.class);

    Profile toProfile(ProfileEntity entity);
}

