package com.example.demo.config;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.example.demo.jwt.config.JwtRequestFilter;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpMethod;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.io.File;
import java.io.FileOutputStream;

@SpringBootTest
@AutoConfigureMockMvc
public class WebSecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void whenAccessSwaggerWithoutAuth_thenOk() throws Exception {
        mockMvc.perform(MockMvcRequestBuilders.get("/swagger-ui/index.html"))
                .andExpect(status().isOk());
    }




    @Test
    void whenAccessUserWithoutAuth_thenUnauthorized() throws Exception {
        mockMvc.perform(MockMvcRequestBuilders.get("/api/user"))
                .andExpect(status().isUnauthorized());
    }

}
