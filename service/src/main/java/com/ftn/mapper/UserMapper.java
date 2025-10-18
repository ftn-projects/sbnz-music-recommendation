package com.ftn.mapper;

import com.ftn.model.User;
import com.ftn.model.UserEntity;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper(componentModel = "spring")
public interface UserMapper {
    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);

    User toUser(UserEntity entity);

    User.Preferences toUserPreferences(UserEntity.Preferences entityPreferences);
}
