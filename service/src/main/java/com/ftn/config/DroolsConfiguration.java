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
import org.kie.api.io.KieResources;
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

        // Create a new KieFileSystem that will include both base kjar and compiled templates
        var kfs = ks.newKieFileSystem();

        // 1. Add the base kjar's kmodule.xml
        var kmoduleRes = ks.getResources().newClassPathResource("META-INF/kmodule.xml");
        kfs.write(kmoduleRes);

        // 2. Compile and add templates as DRL resources
        try {
            var featureSimilarityDrl = compileTemplate(
                    "rules/templates/featureSimilarity/featureSimilarity.drt",
                    createFeatureData()
            );
            kfs.write("src/main/resources/rules/templates/featureSimilarity/featureSimilarity.drl", featureSimilarityDrl);
            log.info("Compiled featureSimilarity template -> {} chars", featureSimilarityDrl.length());

            var profileFeaturesDrl = compileTemplate(
                    "rules/templates/profileFeatures/profileFeatures.drt",
                    createFeatureData()
            );
            kfs.write("src/main/resources/rules/templates/profileFeatures/profileFeatures.drl", profileFeaturesDrl);
            log.info("Compiled profileFeatures template -> {} chars", profileFeaturesDrl.length());

            // 3. Add all other DRL files from the base kjar
            addBaseKjarResources(ks, kfs);

            // 4. Build everything together
            var kieBuilder = ks.newKieBuilder(kfs);
            kieBuilder.buildAll();

            var results = kieBuilder.getResults();
            if (results.hasMessages(Message.Level.ERROR)) {
                log.error("Build errors: {}", results.getMessages(Message.Level.ERROR));
                throw new IllegalStateException("Failed to build rules");
            }
            if (results.hasMessages(Message.Level.WARNING)) {
                log.warn("Build warnings: {}", results.getMessages(Message.Level.WARNING));
            }

            log.info("Successfully compiled and built all rules including templates");

        } catch (Exception e) {
            log.error("Failed to compile templates", e);
            throw new RuntimeException("Template compilation failed", e);
        }

        // Create container from the built KieFileSystem
        var kieContainer = ks.newKieContainer(ks.getRepository().getDefaultReleaseId());

        log.info("KieContainer initialized with compiled templates");

        return kieContainer;
    }

    private void addBaseKjarResources(KieServices ks, KieFileSystem kfs) throws Exception {
        // Add all DRL files from the base kjar
        var resources = ks.getResources();

        // Add each rule package
        addResourcesFromPath(resources, kfs, "rules/filterRules");
        addResourcesFromPath(resources, kfs, "rules/specificationRules");
        addResourcesFromPath(resources, kfs, "rules/affinityRules");
        addResourcesFromPath(resources, kfs, "rules/aggregationRules");
        addResourcesFromPath(resources, kfs, "rules/cep");
        addResourcesFromPath(resources, kfs, "rules/genreBackwards");
        addResourcesFromPath(resources, kfs, "rules/profileBackwards");

        log.info("Added all base kjar DRL resources to KieFileSystem");
    }

    private void addResourcesFromPath(KieResources resources, KieFileSystem kfs, String path) {
        try {
            var pathResource = new ClassPathResource(path);
            if (!pathResource.exists()) {
                log.warn("Path does not exist: {}", path);
                return;
            }

            var file = pathResource.getFile();
            if (file.isDirectory()) {
                var files = file.listFiles((dir, name) -> name.endsWith(".drl"));
                if (files != null) {
                    for (var drlFile : files) {
                        var res = resources.newFileSystemResource(drlFile);
                        var targetPath = "src/main/resources/" + path + "/" + drlFile.getName();
                        kfs.write(targetPath, res);
                        log.debug("Added resource: {}", targetPath);
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Could not add resources from path: {}", path, e);
        }
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
