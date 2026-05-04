package com.example.demo.domain.users.port;

import com.example.demo.domain.users.model.Qualification;

import java.util.List;

public interface QualificationRepositoryPort {
    List<Qualification> findAll();

    List<Qualification> findAllById(Iterable<Long> ids);
}
