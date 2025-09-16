package com.ftn.service;
import java.util.UUID;

//import org.kie.api.definition.type.FactType;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
//import org.kie.api.runtime.rule.FactHandle;

import com.ftn.model.track.Track;
import com.ftn.util.KnowledgeSessionHelper;


public class Test{
    public static void main(){
        try{
            // instanciranje
            KieContainer kc = KnowledgeSessionHelper.createRuleBase();
            KieSession kSession = KnowledgeSessionHelper.getStatefulKnowledgeSession(kc, "k-session");
        
            Track track = new Track();
            track.setId(UUID.randomUUID());
            track.setTitle("Track 1");
            kSession.insert(track);

            kSession.fireAllRules();

        }catch(Throwable t){
            t.printStackTrace();
        }
    }
}


            