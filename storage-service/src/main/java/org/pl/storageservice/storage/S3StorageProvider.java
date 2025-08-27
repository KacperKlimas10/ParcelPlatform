package org.pl.storageservice.storage;

import io.awspring.cloud.s3.S3Template;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.net.URL;
import java.time.Duration;

@Component
@RequiredArgsConstructor
public class S3StorageProvider implements StorageRepository {

   private final S3Template s3Template;

   @Value("${env.aws.bucket.name}")
   private String bucketName;

   @Override
   public URL getSignedUrl(String filename, int durationMinutes) {
      return s3Template.createSignedGetURL(
         bucketName,
         filename,
         Duration.ofMinutes(durationMinutes)
       );
   }

   @Override
   public URL putSignedUrl(String filename, int durationMinutes) {
      return s3Template.createSignedPutURL(
         bucketName,
         filename,
         Duration.ofMinutes(durationMinutes)
       );
   }
}
