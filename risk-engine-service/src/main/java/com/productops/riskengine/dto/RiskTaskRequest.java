package com.productops.riskengine.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record RiskTaskRequest(
        @NotNull Long id,
        @NotBlank String title,
        @Min(0) double estimateHours,
        @Min(0) double actualHours,
        @NotBlank String status,
        @NotBlank String priority,
        boolean blocked,
        boolean overdue,
        List<Long> dependencies
) {
    public boolean highPriority() {
        return "HIGH".equalsIgnoreCase(priority) || "CRITICAL".equalsIgnoreCase(priority);
    }

    public boolean pending() {
        return !"DONE".equalsIgnoreCase(status);
    }
}
