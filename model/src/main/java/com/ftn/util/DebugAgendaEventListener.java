package com.ftn.util;

import org.kie.api.definition.rule.Rule;
import org.kie.api.event.rule.AfterMatchFiredEvent;
import org.kie.api.event.rule.DefaultAgendaEventListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DebugAgendaEventListener extends DefaultAgendaEventListener {
   private final static Logger LOGGER = LoggerFactory.getLogger(DebugAgendaEventListener.class);

   @Override
   public void afterMatchFired(AfterMatchFiredEvent event) {
      Rule rule = event.getMatch().getRule();
      LOGGER.info("Rule fired: {}", rule.getName());
   }
}