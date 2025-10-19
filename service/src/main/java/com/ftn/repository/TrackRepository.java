package com.ftn.repository;

import com.ftn.model.TrackEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface TrackRepository extends JpaRepository<TrackEntity, UUID> {
    @Query(value = "SELECT * FROM tracks ORDER BY id OFFSET :offset LIMIT :limit", nativeQuery = true)
    List<TrackEntity> findAllPaginated(@Param("offset") long offset, @Param("limit") long limit);

    @Query("SELECT COUNT(t) FROM TrackEntity t")
    long getTotal();
}
