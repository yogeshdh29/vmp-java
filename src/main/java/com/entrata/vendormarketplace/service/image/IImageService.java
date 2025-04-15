package com.entrata.vendormarketplace.service.image;

import com.entrata.vendormarketplace.dto.ImageDto;
import com.entrata.vendormarketplace.model.Image;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface IImageService {
    Image getImageById(Long id);
    void deleteImageById(Long id);
    List<ImageDto> saveImages(List<MultipartFile> files, Long productId);
    void updateImage(MultipartFile file, Long imageId);
}
