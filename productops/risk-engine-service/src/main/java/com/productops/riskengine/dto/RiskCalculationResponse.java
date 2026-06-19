package com.productops.riskengine.dto;

import java.util.List;

public record RiskCalculationResponse(
        int riskScore,
        String riskLevel,
        List<String> reasons,
        List<String> suggestedActions
) {
}
