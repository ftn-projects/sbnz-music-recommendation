package com.ftn.config;

import com.ftn.model.event.GenreAffinity;
import com.ftn.service.UserActivityService;
import org.kie.api.event.rule.DefaultAgendaEventListener;
import org.kie.api.event.rule.AfterMatchFiredEvent;
import org.kie.api.runtime.KieSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Wire CEP events to UserActivityService.
 */
@Configuration
public class CepEventListenerConfiguration {
    private static final Logger log = LoggerFactory.getLogger(CepEventListenerConfiguration.class);

    @Bean
    public ApplicationRunner registerUserActivityListener(KieSession musicCepKsession,
                                                          UserActivityService service) {
        return args -> {
            musicCepKsession.addEventListener(new DefaultAgendaEventListener() {
                @Override
                public void afterMatchFired(AfterMatchFiredEvent event) {
                    // Log rule firing and objects
                    log.info("[CEP] Rule fired: {} - {}", event.getMatch().getRule().getName(), event.getMatch().getObjects());

                    for (Object obj : event.getMatch().getObjects()) {
                        if (obj instanceof GenreAffinity) {
                            service.onGenreLikedEvent((GenreAffinity) obj);
                        } else if (obj instanceof GenreAffinity) {
                            service.onGenreDislikedEvent((GenreAffinity) obj);
                        }
                    }
                }
            });
        };
    }
}
