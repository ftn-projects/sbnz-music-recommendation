package com.ftn.mapper;

import com.ftn.model.TrackEntity;
import com.ftn.model.track.Track;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

@Mapper(componentModel = "spring")
public interface TrackMapper {
    TrackMapper INSTANCE = Mappers.getMapper(TrackMapper.class);

    Track toTrack(TrackEntity entity);

    List<Track> toTrackList(List<TrackEntity> entities);

    Track.Features toTrackFeatures(TrackEntity.Features entityFeatures);
}

