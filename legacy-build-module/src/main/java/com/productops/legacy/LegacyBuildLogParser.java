package com.productops.legacy;

public class LegacyBuildLogParser {
    public String status(String log) {
        if (log == null || log.isBlank()) {
            return "failed";
        }
        return log.toUpperCase().contains("BUILD SUCCESSFUL") ? "success" : "failed";
    }

    public int failedTestCount(String log) {
        if (log == null) {
            return 0;
        }
        int count = 0;
        String normalized = log.toLowerCase();
        int index = normalized.indexOf("failed");
        while (index >= 0) {
            count++;
            index = normalized.indexOf("failed", index + 1);
        }
        return count;
    }
}
