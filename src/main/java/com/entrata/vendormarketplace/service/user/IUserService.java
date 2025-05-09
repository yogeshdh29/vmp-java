package com.entrata.vendormarketplace.service.user;

import com.entrata.vendormarketplace.dto.UserDto;
import com.entrata.vendormarketplace.model.User;
import com.entrata.vendormarketplace.request.CreateUserRequest;
import com.entrata.vendormarketplace.request.UserUpdateRequest;

public interface IUserService {
    User getUserById(Long userId);
    User createUser(CreateUserRequest request);
    User updateUser(UserUpdateRequest request, Long userId);
    void deleteUser(Long userId);

    UserDto convertUserToDto(User user);
}
