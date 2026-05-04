package com.example.demo.domain.users.repo;


import com.example.demo.domain.users.model.Qualification;
import com.example.demo.domain.users.port.QualificationRepositoryPort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface QualificationRepository extends JpaRepository<Qualification, Long>, QualificationRepositoryPort {

}
