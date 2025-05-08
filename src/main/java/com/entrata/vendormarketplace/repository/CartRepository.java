package com.entrata.vendormarketplace.repository;

import com.entrata.vendormarketplace.model.Cart;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CartRepository extends JpaRepository<Cart, Long> {
}
