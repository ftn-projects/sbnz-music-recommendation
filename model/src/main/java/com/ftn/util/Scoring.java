package com.ftn.util;

import java.util.List;
import java.util.UUID;

public final class Scoring {
    public static Double distance(List<UUID> first, List<UUID> second)
    {
        if (first == null || second == null || first.isEmpty() && second.isEmpty()) return 1.0;
        int inter = 0;
        for (UUID x : first) if (second.contains(x)) inter++;
        int union = first.size() + second.size() - inter;
        return union == 0 ? 1.0 : 1.0 - (double) inter / union;
    }
}
