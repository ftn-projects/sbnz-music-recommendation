package com.ftn.config;

import com.ftn.repository.TrackRepository;
import org.kie.api.KieBase;
import org.kie.api.KieServices;
import org.kie.api.builder.KieScanner;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.kie.api.runtime.rule.EntryPoint;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PreDestroy;

@Configuration
public class DroolsConfiguration {
    private static final Logger log = LoggerFactory.getLogger(DroolsConfiguration.class);

    private KieSession cepSession;
    private final TrackRepository trackRepository;

    public DroolsConfiguration(TrackRepository trackRepository) {
        this.trackRepository = trackRepository;
    }

    @Bean
    public KieContainer kieContainer() {
        KieServices ks = KieServices.Factory.get();
        KieContainer container = ks.newKieContainer(
                ks.newReleaseId("com.ftn.sbnz", "music-kjar", "0.0.1-SNAPSHOT")
        );
        KieScanner scanner = ks.newKieScanner(container);
        scanner.start(10_000);
        log.info("KieContainer initialized with scanner polling every 10s");
        return container;
    }

    @Bean(destroyMethod = "dispose")
    public KieSession musicCepKsession(KieContainer container) {
        this.cepSession = container.newKieSession("musicCepKsession");
        log.info("Initialized musicCepKsession (STREAM/realtime), ready for track population.");
        return cepSession;
    }

    @Bean(destroyMethod = "dispose")
    public KieSession appKsession(KieContainer container) {
        KieSession session = container.newKieSession("appKsession");
        log.info("Initialized appKsession (classic rules).");
        return session;
    }

    @Bean
    public EntryPoint musicEventsEntryPoint(KieSession musicCepKsession) {
        var ep = musicCepKsession.getEntryPoint("music-events");
        if (ep == null) {
            throw new IllegalStateException(
                    "Entry point 'music-events' not found. Define it in your DRL or insert directly into ksession."
            );
        }
        return ep;
    }

    @Bean
    public ApplicationRunner registerCepListeners(KieSession musicCepKsession) {
        return args -> {
            // Register runtime event listener
            musicCepKsession.addEventListener(new org.kie.api.event.rule.DefaultRuleRuntimeEventListener() {
                @Override
                public void objectInserted(org.kie.api.event.rule.ObjectInsertedEvent e) {
                    log.debug("[CEP] Object inserted: {}", e.getObject());
                }
            });

            // Register agenda event listener
            musicCepKsession.addEventListener(new org.kie.api.event.rule.DefaultAgendaEventListener() {
                @Override
                public void afterMatchFired(org.kie.api.event.rule.AfterMatchFiredEvent event) {
                    log.info("[CEP] Rule fired: {} - {}",
                            event.getMatch().getRule().getName(),
                            event.getMatch().getObjects());
                }
            });

            // Register output channel
            musicCepKsession.registerChannel("out", o -> log.info("CEP OUT -> {}", o));

            log.info("Registered CEP event listeners and output channel.");
        };
    }

    /**
     * Keep CEP evaluating continuously in background thread
     */
    @Bean
    public ApplicationRunner startCepLoop(KieSession musicCepKsession) {
        return args -> {
            var t = new Thread(musicCepKsession::fireUntilHalt, "drools-cep-fireUntilHalt");
            t.setDaemon(true);
            t.start();
            log.info("Started Drools CEP loop (fireUntilHalt) in background thread.");
        };
    }

    /**
     * Asynchronously populate the CEP session with tracks from the database in batches after startup.
     */
    @Bean
    public ApplicationRunner populateCepTracksAsync(KieSession musicCepKsession) {
        return args -> {
            final int batchSize = 1000;
            long total = trackRepository.getTotal();
            log.info("Populating CEP session with {} tracks in batches of {}...", total, batchSize);
            for (long offset = 0; offset < total; offset += batchSize) {
                var batch = trackRepository.findAllPaginated(offset, batchSize);
                for (var track : batch) {
                    musicCepKsession.insert(track);
                }
                log.info("Inserted batch: {} - {} / {}", offset + 1, Math.min(offset + batchSize, total), total);
            }
            log.info("Finished populating CEP session with all tracks.");
        };
    }

    @Bean
    public KieBase appRulesKieBase(KieContainer container) {
        return container.getKieBase("appRulesKBase");
    }

    @PreDestroy
    public void shutdown() {
        if (cepSession != null) {
            try {
                log.info("Halting CEP session...");
                cepSession.halt();
            } catch (Exception e) {
                log.warn("Error halting CEP session", e);
            }
        }
    }
}
