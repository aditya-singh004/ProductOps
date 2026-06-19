package com.productops.legacy;

public class LegacyBuildLogParserTest {
    public static void main(String[] args) {
        LegacyBuildLogParser parser = new LegacyBuildLogParser();
        if (!"success".equals(parser.status("BUILD SUCCESSFUL"))) {
            throw new IllegalStateException("Expected success status");
        }
        if (!"failed".equals(parser.status("BUILD FAILED"))) {
            throw new IllegalStateException("Expected failed status");
        }
        if (parser.failedTestCount("FAILED testA\nFAILED testB") != 2) {
            throw new IllegalStateException("Expected failed test count");
        }
        System.out.println("LegacyBuildLogParserTest passed");
    }
}
