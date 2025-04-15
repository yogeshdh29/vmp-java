package com.entrata.vendormarketplace.repository;

import com.entrata.vendormarketplace.model.Image;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ImageRepository extends JpaRepository<Image, Long> {
}
