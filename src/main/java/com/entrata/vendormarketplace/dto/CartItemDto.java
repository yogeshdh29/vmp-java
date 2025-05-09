package com.entrata.vendormarketplace.dto;

import com.entrata.vendormarketplace.model.Product;

import java.math.BigDecimal;

public class CartItemDto {
    private Long itemId;
    private Integer quantity;
    private BigDecimal unitPrice;
    private ProductDto product;
}
