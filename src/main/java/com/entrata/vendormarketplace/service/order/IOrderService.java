package com.entrata.vendormarketplace.service.order;

import com.entrata.vendormarketplace.dto.OrderDto;
import com.entrata.vendormarketplace.model.Order;

import java.util.List;

public interface IOrderService {
    Order placeOrder(Long userId);
    Order getOrder(Long orderId);

    List<Order> getUserOrders(Long userId);

    OrderDto convertToDto(Order order);
}
