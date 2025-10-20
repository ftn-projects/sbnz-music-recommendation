package com.ftn.config;

import com.ftn.mapper.GenreMapper;
import com.ftn.mapper.TrackMapper;
import com.ftn.mapper.TraitMapper;
import com.ftn.repository.GenreRepository;
import com.ftn.repository.TrackRepository;
import com.ftn.repository.TraitRepository;
import com.ftn.util.DebugAgendaEventListener;
import com.ftn.util.DebugRuleRuntimeEventListener;

import jakarta.annotation.PreDestroy;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.drools.template.ObjectDataCompiler;
import org.kie.api.KieBase;
import org.kie.api.KieServices;
import org.kie.api.builder.*;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.util.Collection;

@Configuration
public class DroolsConfiguration {
    private static final Logger log = LoggerFactory.getLogger(DroolsConfiguration.class);

    private KieSession cepSession;

    private final TrackRepository trackRepository;
    private final GenreRepository genreRepository;

    public DroolsConfiguration(TrackRepository trackRepository, GenreRepository genreRepository) {
        this.trackRepository = trackRepository;
        this.genreRepository = genreRepository;
    }

    // =============================================================================================
    // Base container with compiled templates added directly
    // =============================================================================================

    @Getter
    @Setter
    @AllArgsConstructor
    public static class FeatureTemplateData {
        private String featureName;
        private String featureGetter;
    }

    @Bean
    public KieContainer kieContainer() {
        var ks = KieServices.Factory.get();

        // Start with base kjar
        var baseContainer = ks.newKieContainer(
                ks.newReleaseId("com.ftn.sbnz", "kjar", "0.0.1-SNAPSHOT")
        );

        // Create a new KieFileSystem to add compiled templates
        var kfs = ks.newKieFileSystem();

        // Compile and add templates directly as DRL resources
        try {
            var featureScoringDrl = compileTemplate(
                    "rules/templates/featureScoring/featureScoring.drt",
                    createFeatureData()
            );
            kfs.write("src/main/resources/rules/templates/featureScoring.drl", featureScoringDrl);
            log.info("Compiled featureScoring template -> {} chars", featureScoringDrl.length());

            var featureSimilarityDrl = compileTemplate(
                    "rules/templates/featureSimilarity/featureSimilarity.drt",
                    createFeatureData()
            );
            kfs.write("src/main/resources/rules/templates/featureSimilarity.drl", featureSimilarityDrl);
            log.info("Compiled featureSimilarity template -> {} chars", featureSimilarityDrl.length());

            // Build the templates
            var kieBuilder = ks.newKieBuilder(kfs);
            kieBuilder.buildAll();

            var results = kieBuilder.getResults();
            if (results.hasMessages(Message.Level.ERROR)) {
                log.error("Template compilation errors: {}", results.getMessages(Message.Level.ERROR));
                throw new IllegalStateException("Failed to compile template rules");
            }
            if (results.hasMessages(Message.Level.WARNING)) {
                log.warn("Template compilation warnings: {}", results.getMessages(Message.Level.WARNING));
            }

            log.info("Successfully compiled and built template rules");

        } catch (Exception e) {
            log.error("Failed to compile templates", e);
            throw new RuntimeException("Template compilation failed", e);
        }

        // Start scanner for hot reload
        var scanner = ks.newKieScanner(baseContainer);
        scanner.start(10_000);
        log.info("KieContainer initialized with scanner polling every 10s");

        return baseContainer;
    }

    @Bean
    @Qualifier("appRulesKieBase")
    public KieBase kieBase(KieContainer kieContainer) {
        var kieBase = kieContainer.getKieBase("appRulesKBase");
        log.info("Initialized KieBase from appRulesKBase");
        return kieBase;
    }

    private Collection<FeatureTemplateData> createFeatureData() {
        return java.util.Arrays.asList(
                new FeatureTemplateData("danceability", "getDanceability"),
                new FeatureTemplateData("energy", "getEnergy"),
                new FeatureTemplateData("speechiness", "getSpeechiness"),
                new FeatureTemplateData("acousticness", "getAcousticness"),
                new FeatureTemplateData("instrumentalness", "getInstrumentalness"),
                new FeatureTemplateData("liveness", "getLiveness"),
                new FeatureTemplateData("valence", "getValence")
        );
    }

    private String compileTemplate(String drtClasspath, Collection<FeatureTemplateData> data) {
        try (var drtStream = new ClassPathResource(drtClasspath).getInputStream()) {
            var compiler = new ObjectDataCompiler();
            return compiler.compile(data, drtStream);
        } catch (Exception e) {
            throw new IllegalStateException("Error compiling template " + drtClasspath, e);
        }
    }

    // =============================================================================================
    // Sessions
    // =============================================================================================

    @Bean(destroyMethod = "dispose")
    public KieSession appKsession(KieContainer kieContainer) {
        var session = kieContainer.newKieSession("appKsession");
        log.info("Initialized appKsession");
        return session;
    }

    @Bean(destroyMethod = "dispose")
    public KieSession musicCepKsession(KieContainer kieContainer) {
        this.cepSession = kieContainer.newKieSession("musicCepKsession");
        log.info("Initialized musicCepKsession (STREAM/realtime)");
        return cepSession;
    }

    @Bean(destroyMethod = "dispose")
    public KieSession backwardsKsession(KieContainer kieContainer) {
        var backwardsSession = kieContainer.newKieSession("backwardsKsession");
        backwardsSession.addEventListener(new DebugAgendaEventListener());
        backwardsSession.addEventListener(new DebugRuleRuntimeEventListener());
        log.info("Initialized backwardsKsession");
        return backwardsSession;
    }

    // =============================================================================================
    // Populate sessions
    // =============================================================================================

    @Bean
    public ApplicationRunner startCepLoop(KieSession musicCepKsession) {
        return args -> {
            var t = new Thread(musicCepKsession::fireUntilHalt, "drools-cep-fireUntilHalt");
            t.setDaemon(true);
            t.start();
            log.info("Started Drools CEP loop (fireUntilHalt)");
        };
    }

    @Bean
    public ApplicationRunner populateCepTracksAsync(KieSession musicCepKsession, TrackMapper trackMapper) {
        return args -> {
            final var batchSize = 1000;
            var total = trackRepository.getTotal();
            log.info("Populating CEP session with {} tracks in batches of {}...", total, batchSize);
            for (var offset = 0L; offset < total; offset += batchSize) {
                var batch = trackRepository.findAllPaginated(offset, batchSize);
                for (var trackEntity : batch) {
                    musicCepKsession.insert(trackMapper.toTrack(trackEntity));
                }
                log.info("Inserted batch: {} - {} / {}", offset + 1, Math.min(offset + batchSize, total), total);
            }
            log.info("Finished populating CEP session with all tracks");
        };
    }

    @Bean
    public ApplicationRunner populateBackwardsAsync(
            KieSession backwardsKsession,
            GenreMapper genreMapper,
            TraitRepository traitRepository,
            TraitMapper traitMapper
    ) {
        return args -> {
            var genres = genreRepository.findAll();
            log.info("Populating Backwards session with {} genres", genres.size());
            for (var genreEntity : genres) {
                backwardsKsession.insert(genreMapper.toGenre(genreEntity));
            }
            log.info("Finished populating Backwards session with all genres");

            var traits = traitRepository.findAll();
            log.info("Populating Backwards session with {} traits", traits.size());
            for (var traitEntity : traits) {
                backwardsKsession.insert(traitMapper.toTrait(traitEntity));
            }
            log.info("Finished populating Backwards session with all traits");
        };
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
