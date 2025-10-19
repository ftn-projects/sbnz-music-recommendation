package com.ftn.repository;

import com.ftn.model.TraitEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface TraitRepository extends JpaRepository<TraitEntity, UUID> {
}

