package com.ftn.config;

import com.ftn.mapper.GenreMapper;
import com.ftn.mapper.TrackMapper;
import com.ftn.repository.GenreRepository;
import com.ftn.repository.TrackRepository;
import org.drools.template.ObjectDataCompiler;
import org.kie.api.KieBase;
import org.kie.api.KieServices;
import org.kie.api.builder.KieBuilder;
import org.kie.api.builder.KieFileSystem;
import org.kie.api.builder.KieScanner;
import org.kie.api.builder.Message;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import jakarta.annotation.PreDestroy;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@Configuration
public class DroolsConfiguration {
    private static final Logger log = LoggerFactory.getLogger(DroolsConfiguration.class);

    private KieSession cepSession;
    private final TrackRepository trackRepository;
    private KieSession backwardsSession;
    private final GenreRepository genreRepository;

    public DroolsConfiguration(TrackRepository trackRepository, GenreRepository genreRepository) {
        this.trackRepository = trackRepository;
        this.genreRepository = genreRepository;
    }

    @Bean
    public KieContainer kieContainer() {
        var ks = KieServices.Factory.get();
        var container = ks.newKieContainer(
                ks.newReleaseId("com.ftn.sbnz", "kjar", "0.0.1-SNAPSHOT")
        );
        var scanner = ks.newKieScanner(container);
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
    public KieSession backwardsKsession(KieContainer container) {
        this.backwardsSession = container.newKieSession("backwardsKsession");
        log.info("Initialized backwardsKsession, ready for genre population.");
        return backwardsSession;
    }

    @Bean(destroyMethod = "dispose")
    public KieSession appKsession(KieContainer container) {
        var session = container.newKieSession("appKsession");
        log.info("Initialized appKsession (classic rules).");
        return session;
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
    public ApplicationRunner populateCepTracksAsync(KieSession musicCepKsession,
                                                    TrackMapper trackMapper) {
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
            log.info("Finished populating CEP session with all tracks.");
        };
    }

    @Bean
    public ApplicationRunner populateBackwardsGenresAsync(KieSession backwardsKsession,
                                                          GenreMapper genreMapper) {
        return args -> {
            var genres = genreRepository.findAll();
            var total = genres.size();
            log.info("Populating Backwards session with {} genres", total);
            for (var genreEntity : genres) {
                backwardsKsession.insert(genreMapper.toGenre(genreEntity));
            }
            log.info("Finished populating Backwards session with all genres.");
        };
    }

    @Bean
    public KieBase appRulesKieBase(KieContainer container) {
        if (container == null) {
            throw new IllegalStateException("KieContainer is not initialized.");
        }
        try {
            // Get the base KieBase from kjar
            var baseKieBase = container.getKieBase("appRulesKBase");
            if (baseKieBase == null) {
                throw new IllegalStateException("KieBase 'appRulesKBase' is not found in the KieContainer. Check your kmodule.xml configuration.");
            }

            log.info("Base KieBase loaded with {} packages and {} rules",
                    baseKieBase.getKiePackages().size(),
                    baseKieBase.getKiePackages().stream().mapToInt(pkg -> pkg.getRules().size()).sum());

            // Try to load and merge template-generated rules
            try {
                var combinedKieBase = mergeTemplateRulesIntoKieBase(baseKieBase);
                log.info("Successfully merged template rules into appRulesKieBase");
                return combinedKieBase;
            } catch (Exception e) {
                log.warn("Failed to load template rules: {}. Using base KieBase without templates.", e.getMessage());
                log.debug("Template loading error details:", e);
                return baseKieBase;
            }

        } catch (NullPointerException e) {
            throw new IllegalStateException("NullPointerException when accessing KieBase 'appRulesKBase'. " +
                    "This usually means the kmodule.xml file is missing or doesn't define this KieBase. " +
                    "Check that kjar module has META-INF/kmodule.xml with <kbase name='appRulesKBase'>", e);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to load KieBase 'appRulesKieBase': " + e.getMessage(), e);
        }
    }

    /**
     * Merge template-generated rules into the base KieBase.
     * This creates a new KieBase that contains both the kjar rules and template-generated rules.
     */
    private KieBase mergeTemplateRulesIntoKieBase(KieBase baseKieBase) throws Exception {
        log.info("Loading template rules and merging with base KieBase...");

        var ks = KieServices.Factory.get();
        var kfs = ks.newKieFileSystem();

        // Generate rules from templates
        var featureScoringRules = compileTemplate(
                "rules/templates/featureScoring/featureScoring.csv",
                "rules/templates/featureScoring/featureScoring.drt",
                new ObjectDataCompiler(),
                "featureScoring"
        );
        log.debug("Generated featureScoring rules:\n{}", featureScoringRules);
        kfs.write("src/main/resources/templates/featureScoring.drl", featureScoringRules);

        var featureSimilarityRules = compileTemplate(
                "rules/templates/featureSimilarity/featureSimilarity.csv",
                "rules/templates/featureSimilarity/featureSimilarity.drt",
                new ObjectDataCompiler(),
                "featureSimilarity"
        );
        log.debug("Generated featureSimilarity rules:\n{}", featureSimilarityRules);
        kfs.write("src/main/resources/templates/featureSimilarity.drl", featureSimilarityRules);

        // Write base KieBase packages to the file system (to merge them)
        for (var pkg : baseKieBase.getKiePackages()) {
            var pkgName = pkg.getName();
            log.debug("Adding base package to merge: {} ({} rules)", pkgName, pkg.getRules().size());

            // Write a placeholder for each package (the actual rules are already compiled in baseKieBase)
            // We just need to reference them
            var pkgPath = "src/main/resources/base/" + pkgName.replace('.', '/') + "/package-info.drl";
            kfs.write(pkgPath, "package " + pkgName + ";\n// Base package from kjar\n");
        }

        // Build the combined KieBase
        var kieBuilder = ks.newKieBuilder(kfs);
        kieBuilder.buildAll();

        if (kieBuilder.getResults().hasMessages(Message.Level.ERROR)) {
            var errors = kieBuilder.getResults().getMessages(Message.Level.ERROR);
            log.error("Errors building combined KieBase with templates: {}", errors);
            throw new RuntimeException("Failed to compile template-generated rules: " + errors);
        }

        if (kieBuilder.getResults().hasMessages(Message.Level.WARNING)) {
            log.warn("Warnings building combined KieBase: {}",
                    kieBuilder.getResults().getMessages(Message.Level.WARNING));
        }

        var combinedContainer = ks.newKieContainer(kieBuilder.getKieModule().getReleaseId());
        var combinedKieBase = combinedContainer.getKieBase();

        var totalRules = combinedKieBase.getKiePackages().stream()
                .mapToInt(pkg -> pkg.getRules().size())
                .sum();

        log.info("Combined KieBase created with {} packages and {} total rules (base + templates)",
                combinedKieBase.getKiePackages().size(), totalRules);

        return combinedKieBase;
    }

    /**
     * Load and compile all template rules into the given KieFileSystem
     */
    private void loadTemplateRulesIntoFileSystem(KieFileSystem kfs) throws Exception {
        // Load and compile featureScoring template
        var featureScoringRules = compileTemplate(
                "rules/templates/featureScoring/featureScoring.csv",
                "rules/templates/featureScoring/featureScoring.drt",
                new ObjectDataCompiler(),
                "featureScoring"
        );
        kfs.write("src/main/resources/templates/featureScoring.drl", featureScoringRules);

        // Load and compile featureSimilarity template
        var featureSimilarityRules = compileTemplate(
                "rules/templates/featureSimilarity/featureSimilarity.csv",
                "rules/templates/featureSimilarity/featureSimilarity.drt",
                new ObjectDataCompiler(),
                "featureSimilarity"
        );
        kfs.write("src/main/resources/templates/featureSimilarity.drl", featureSimilarityRules);
    }

    /**
     * Compile a single template with its CSV data
     */
    private String compileTemplate(String csvPath, String templatePath, ObjectDataCompiler compiler, String templateName) throws Exception {
        log.info("Compiling template: {}", templateName);
        log.debug("  CSV path: {}", csvPath);
        log.debug("  Template path: {}", templatePath);

        var data = loadCsvData(csvPath);
        log.info("  Loaded {} rows from CSV (including header)", data.size());

        var template = loadTemplateContent(templatePath);
        log.debug("  Template content loaded ({} chars)", template.length());

        var compiledRules = compiler.compile(data, template);

        var ruleCount = data.size() - 1; // Subtract header row
        log.info("  Generated {} rules from {} template", ruleCount, templateName);

        return compiledRules;
    }

    private List<String[]> loadCsvData(String csvPath) throws Exception {
        var data = new ArrayList<String[]>();
        var content = readResourceFile(csvPath);

        var lines = content.split("\n");
        for (var line : lines) {
            var trimmed = line.trim();
            if (!trimmed.isEmpty()) {
                data.add(trimmed.split(","));
            }
        }

        log.debug("Loaded {} rows from CSV: {}", data.size(), csvPath);
        return data;
    }

    private String loadTemplateContent(String templatePath) throws Exception {
        var content = readResourceFile(templatePath);
        log.debug("Loaded template: {}", templatePath);
        return content;
    }

    /**
     * Read a resource file from classpath and return its content as a String
     */
    private String readResourceFile(String resourcePath) throws Exception {
        try (var is = new ClassPathResource(resourcePath).getInputStream();
             var reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {

            var content = new StringBuilder();
            var buffer = new char[1024];
            int read;
            while ((read = reader.read(buffer)) != -1) {
                content.append(buffer, 0, read);
            }

            return content.toString();
        }
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
