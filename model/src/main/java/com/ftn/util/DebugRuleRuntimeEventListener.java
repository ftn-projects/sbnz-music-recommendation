package com.ftn.util;

import org.kie.api.event.rule.DefaultRuleRuntimeEventListener;
import org.kie.api.event.rule.ObjectInsertedEvent;
import org.kie.api.event.rule.ObjectUpdatedEvent;
import org.kie.api.event.rule.ObjectDeletedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DebugRuleRuntimeEventListener extends DefaultRuleRuntimeEventListener {
    private static final Logger log = LoggerFactory.getLogger(DebugRuleRuntimeEventListener.class);

    @Override
    public void objectInserted(ObjectInsertedEvent event) {
        Object o = event.getObject();
        log.info("Fact inserted: {}", summarizeFact(o));
    }

    @Override
    public void objectUpdated(ObjectUpdatedEvent event) {
        Object o = event.getObject();
        log.info("Fact updated: {}", summarizeFact(o));
    }

    @Override
    public void objectDeleted(ObjectDeletedEvent event) {
        Object o = event.getOldObject();
        log.info("Fact retracted: {}", summarizeFact(o));
    }

    private String summarizeFact(Object f) {
        if (f == null) return "null";
        try {
            return f.getClass().getSimpleName() + ": " + f;
        } catch (Exception ex) {
            return f.getClass().getSimpleName() + ": (error summarizing: " + ex.getMessage() + ")";
        }
    }
}
