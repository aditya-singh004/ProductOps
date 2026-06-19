package com.productops.riskengine.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public record RiskCalculationRequest(
        Long sprintId,
        Long releaseId,
        List<Long> criticalPathTaskIds,
        @Valid @NotEmpty List<RiskTaskRequest> tasks
) {
}
