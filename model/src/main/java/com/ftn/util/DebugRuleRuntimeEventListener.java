package com.ftn.util;

import org.kie.api.event.rule.DefaultRuleRuntimeEventListener;
import org.kie.api.event.rule.ObjectInsertedEvent;
import org.kie.api.event.rule.ObjectUpdatedEvent;
import org.kie.api.event.rule.ObjectDeletedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("unused")
public class DebugRuleRuntimeEventListener extends DefaultRuleRuntimeEventListener {
    private static final Logger LOG = LoggerFactory.getLogger(DebugRuleRuntimeEventListener.class);

    @Override
    public void objectInserted(ObjectInsertedEvent event) {
        Object o = event.getObject();
        LOG.info("Fact inserted: {}", summarizeFact(o));
    }

    @Override
    public void objectUpdated(ObjectUpdatedEvent event) {
        Object o = event.getObject();
        LOG.info("Fact updated: {}", summarizeFact(o));
    }

    @Override
    public void objectDeleted(ObjectDeletedEvent event) {
        Object o = event.getOldObject();
        LOG.info("Fact retracted: {}", summarizeFact(o));
    }

    private String summarizeFact(Object f) {
        if (f == null) return "null";
        try {
            if (f instanceof com.ftn.model.track.Track) {
                com.ftn.model.track.Track t = (com.ftn.model.track.Track) f;
                return String.format("Track[id=%s,title=%s,artist=%s,year=%s]", t.getId(), t.getTitle(), t.getArtist(), t.getReleaseYear());
            } else if (f instanceof com.ftn.model.track.RecommendationProposal) {
                com.ftn.model.track.RecommendationProposal c = (com.ftn.model.track.RecommendationProposal) f;
                return String.format("RecommendationProposal[user=%s,track=%s,score=%.3f]", c.getUserId(), c.getTrackId(), c.getScore());
            } else if (f instanceof com.ftn.model.User) {
                com.ftn.model.User u = (com.ftn.model.User) f;
                return String.format("User[id=%s,name=%s,age=%s,preferences=%s]", u.getId(), u.getName(), u.getAge(), u.getGenrePreferences());
            } else if (f instanceof com.ftn.model.Profile) {
                com.ftn.model.Profile p = (com.ftn.model.Profile) f;
                return String.format("Profile[id=%s,name=%s]", p.getId(), p.getName());
            } else if (f instanceof com.ftn.model.request.ProfileRequest) {
                com.ftn.model.request.ProfileRequest r = (com.ftn.model.request.ProfileRequest) f;
                return String.format("ProfileRequest[id=%s,user=%s,profile=%s]", r.getId(), r.getUserId(), r.getProfileId());
            } else if (f instanceof com.ftn.model.request.SeedTrackRequest) {
                com.ftn.model.request.SeedTrackRequest s = (com.ftn.model.request.SeedTrackRequest) f;
                return String.format("SeedTrackRequest[id=%s,user=%s,seedTrack=%s,yearDelta=%s]", s.getId(), s.getUserId(), s.getSeedTrackId(), s.getYearDeltaMax());
            } else {
                return f.getClass().getSimpleName() + ": " + f;
            }
        } catch (Exception ex) {
            return f.getClass().getSimpleName() + ": (error summarizing: " + ex.getMessage() + ")";
        }
    }
}
