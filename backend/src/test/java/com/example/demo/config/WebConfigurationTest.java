package com.example.demo.config;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.File;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class WebConfigurationTest {

    AppConfiguration app = new AppConfiguration();
    WebConfiguration webConfig = new WebConfiguration();

    @BeforeEach
    void setup() {
        app.setUploadPath("test-uploads");
        webConfig.app = app;
    }

    @Test
    void testCreateStorageDirectoryCreatesFolder() throws Exception {
        File folder = new File(app.getUploadPath());
        if (folder.exists()) {
            folder.delete();
        }

        webConfig.createStorageDirectory().run();

        assertTrue(folder.exists() && folder.isDirectory(), "Папка должна быть создана");
        folder.delete(); // Clean up
    }
}
