package com.ftn.service;

import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/recommendations")
public class RecommendationController {

    private final KieSession session;

    public RecommendationController(KieContainer kieContainer) {
        this.session = kieContainer.newKieSession();
    }
}
