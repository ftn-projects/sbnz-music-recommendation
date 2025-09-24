package com.ftn.service;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.kie.api.event.rule.DefaultAgendaEventListener;
import org.kie.api.event.rule.AfterMatchFiredEvent;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;

import com.ftn.model.Genre;
import com.ftn.model.User;
import com.ftn.model.User.Preferences;
import com.ftn.model.request.SeedTrackRequest;
import com.ftn.model.track.Track;
import com.ftn.model.track.TrackCandidate;
import com.ftn.util.CsvRepository;
import com.ftn.util.KnowledgeSessionHelper;


public class Test{
    public static void main() {
        try{
            // instanciranje
            KieContainer kc = KnowledgeSessionHelper.createRuleBase();
            KieSession kSession = KnowledgeSessionHelper.getStatefulKnowledgeSession(kc, "k-session");

            // Add this listener to print rule names as they fire
            kSession.addEventListener(new DefaultAgendaEventListener() {
                @Override
                public void afterMatchFired(AfterMatchFiredEvent event) {
                    System.out.println("Rule fired: " + event.getMatch().getRule().getName());
                }
            });

            CsvRepository csvRepository = new CsvRepository();
            var tracks = csvRepository.loadTracks();
            Map<UUID, Track> trackMap = tracks.stream()
                .collect(Collectors.toMap(Track::getId, track -> track));
            var genres = csvRepository.loadGenres();

            for (Track track : tracks) {
                kSession.insert(track);
            }
            for (Genre genre : genres) {
                kSession.insert(genre);
            }

            var userId = UUID.fromString("e8b7c2a1-4f3d-4e2b-9c8a-7d6f5e4c3b2a");
            Map<UUID, Double> genrePreferences = csvRepository.loadGenrePreferences(userId);
            Preferences preferences = new Preferences(false, true, true);
            User user = new User(UUID.randomUUID(), "Nikola Nikolic", 23, genrePreferences, preferences);

            Track superMassiveBlackHole = tracks.get(0);
            SeedTrackRequest request = new SeedTrackRequest(UUID.randomUUID(), user.getId(), superMassiveBlackHole.getId(), 10);

            kSession.insert(user);
            kSession.insert(request);

            for (Track track : tracks) {
                var candidate = new TrackCandidate(userId, track.getId());
                kSession.insert(candidate);
            }

            var result = kSession.fireAllRules();
            System.out.println("Number of fired rules: " + result);

            kSession.getObjects().forEach(obj -> {
                if (obj instanceof TrackCandidate) {
                    var candidate = (TrackCandidate) obj;
                    var title = trackMap.get(candidate.getTrackId()).getTitle();
                    var artist = trackMap.get(candidate.getTrackId()).getArtist();
                    System.out.println("Recommended track: " + title + " by " + artist);
                }
            });

        }catch(Throwable t){
            t.printStackTrace();
        }
    }
}


