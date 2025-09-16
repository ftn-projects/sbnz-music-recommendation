package com.ftn.service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

//import org.kie.api.definition.type.FactType;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
//import org.kie.api.runtime.rule.FactHandle;

import com.ftn.model.Genre;
import com.ftn.model.User;
import com.ftn.model.User.Preferences;
import com.ftn.model.request.SeedTrackRequest;
import com.ftn.model.track.Track;
import com.ftn.model.track.Track.Features;
import com.ftn.util.KnowledgeSessionHelper;


public class Test{
    public static void main(){
        try{
            // instanciranje
            KieContainer kc = KnowledgeSessionHelper.createRuleBase();
            KieSession kSession = KnowledgeSessionHelper.getStatefulKnowledgeSession(kc, "k-session");
            
            Genre metal = new Genre(UUID.randomUUID(), "metal");
            Genre britpop = new Genre(UUID.randomUUID(), "britpop");
            Genre hardcore = new Genre(UUID.randomUUID(), "hardcore");
            Genre alternative_rock = new Genre(UUID.randomUUID(), "alternative_rock");

            Map<UUID, Double> genrePreferences = new HashMap<>(Map.of(
                metal.getId(), 0.9,
                britpop.getId(), 0.6,
                hardcore.getId(), 0.2,
                alternative_rock.getId(), 0.4
            ));

            Preferences preferences = new Preferences(true, true, true);
            User user = new User(UUID.randomUUID(), "Nikola Nikolic", 23, genrePreferences, preferences);

            Features features = new Features(0.6, 0.89, -5.1, 0.04, 0.04, 0.01, 0.28, 0.84);
            Track track = new Track(UUID.randomUUID(), "Supermassive Black Hole", "Muse", 2006, List.of(alternative_rock.getId()), features, false);
            SeedTrackRequest request = new SeedTrackRequest(UUID.randomUUID(), user.getId(), track.getId(), 10);

            kSession.insert(metal);
            kSession.insert(britpop);
            kSession.insert(hardcore);
            kSession.insert(alternative_rock);
            kSession.insert(user);
            kSession.insert(track);
            kSession.insert(request);
            //dodati track candidates
            kSession.fireAllRules();

        }catch(Throwable t){
            t.printStackTrace();
        }
    }
}


            