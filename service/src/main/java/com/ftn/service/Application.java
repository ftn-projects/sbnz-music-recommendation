package com.ftn.service;

import org.kie.api.KieServices;
import org.kie.api.builder.KieScanner;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.kie.api.runtime.rule.EntryPoint;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import jakarta.annotation.PreDestroy;

@SpringBootApplication
public class Application {
	private static final Logger log = LoggerFactory.getLogger(Application.class);

	private KieSession cep;

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

	@Bean
	public KieContainer kieContainer() {
		KieServices ks = KieServices.Factory.get();
		KieContainer container = ks.newKieContainer(ks.newReleaseId("com.ftn.sbnz", "music-kjar", "0.0.1-SNAPSHOT"));
		KieScanner scanner = ks.newKieScanner(container);
		scanner.start(10_000);
		return container;
	}

	@Bean(destroyMethod = "dispose")
	public KieSession musicCepKsession(KieContainer container) {
		this.cep = container.newKieSession("musicCepKsession");
		log.info("Initialized musicCepKsession (STREAM/realtime).");
		return cep;
	}

	@Bean
	public EntryPoint musicEventsEntryPoint(KieSession musicCepKsession) {
		var ep = musicCepKsession.getEntryPoint("music-events");
		if (ep == null) {
		throw new IllegalStateException(
			"Entry point 'music-events' not found. Define it in your DRL or insert directly into ksession.");
		}
		return ep;
	}

	@Bean
	public ApplicationRunner registerListeners(KieSession ksession) {
		return args -> {
			ksession.addEventListener(new org.kie.api.event.rule.DefaultRuleRuntimeEventListener() {
				@Override
				public void objectInserted(org.kie.api.event.rule.ObjectInsertedEvent e) {
					// e.getObject() instanceof GenreLiked/GenreDisliked -> persist/emit/log
					log.info("[CEP] Object inserted: {}", e.getObject());
				}
			});
			ksession.registerChannel("out", o -> log.info("CEP OUT -> {}", o));
		};
	}

	/** Keep CEP evaluating continuously */
	@Bean
	public ApplicationRunner startCepLoop(KieSession musicCepKsession) {
		return args -> {
			var t = new Thread(musicCepKsession::fireUntilHalt, "drools-fireUntilHalt");
			t.setDaemon(true);
			t.start();
			log.info("Started Drools CEP loop (fireUntilHalt).");
		};
	}

	@PreDestroy
	void shutdown() {
		if (cep != null) {
		try { cep.halt(); } catch (Exception ignore) {}
		}
	}
}