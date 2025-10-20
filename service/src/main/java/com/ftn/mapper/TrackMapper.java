package com.ftn.mapper;

import com.ftn.dto.TrackDTO;
import com.ftn.model.AudioFeatures;
import com.ftn.model.AudioFeaturesEntity;
import com.ftn.model.TrackEntity;
import com.ftn.model.track.Track;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface TrackMapper {
    Track toTrack(TrackEntity entity);

    List<Track> toTrackList(List<TrackEntity> entities);

    AudioFeatures toTrackFeatures(AudioFeaturesEntity entityFeatures);

    TrackDTO toDTO(TrackEntity entity);
}

