package com.ftn.repository;

import com.ftn.model.GenreEntity;
import com.ftn.model.ProfileEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface GenreRepository extends JpaRepository<GenreEntity, UUID> {
}
